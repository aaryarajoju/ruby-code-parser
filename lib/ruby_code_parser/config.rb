require 'yaml'
require 'json'

class RubyCodeParser
  # Configuration management for the analyzer
  # Supports loading from YAML/JSON files and environment variables
  class Config
    DEFAULT_CONFIG = {
      # GitHub settings
      github: {
        token: nil,  # ENV['GITHUB_TOKEN']
        per_page: 100
      },

      # Analysis settings
      analysis: {
        temp_dir: 'temp_downloads',
        cleanup_temp: true,
        verbose: true,
        min_confidence: 0.6,
        analyze_only_diff: false
      },

      # Detector thresholds (can be overridden per-detector)
      detectors: {
        srp: {
          enabled: true,
          max_methods: 7,
          max_instantiations: 5
        },
        ocp: {
          enabled: true,
          max_conditionals: 2
        },
        lsp: {
          enabled: true
        },
        dip: {
          enabled: true,
          max_concretions: 3
        },
        isp: {
          enabled: true,
          max_interface_methods: 6
        },
        law_of_demeter: {
          enabled: true,
          max_chain: 3
        },
        dry: {
          enabled: true,
          min_duplicates: 2,
          max_reports: 5
        },
        information_expert: {
          enabled: true,
          min_external_calls: 4,
          tolerance: 1
        },
        encapsulation: {
          enabled: true,
          max_attr_accessors: 3,
          max_public_ratio: 0.85,
          min_methods: 5
        },
        overuse_class_methods: {
          enabled: true,
          min_class_methods: 4,
          max_instance_methods: 1
        }
      },

      # LLM settings (for validation and future analysis)
      llm: {
        enabled: false,
        provider: 'openai',
        model: 'gpt-4o-mini',
        temperature: 0.2,
        api_key: nil  # ENV['OPENAI_API_KEY']
      },

      # Report settings
      reports: {
        output_dir: 'reports',
        formats: %w[json md html],
        include_context: true,
        max_context_lines: 10
      }
    }.freeze

    attr_reader :settings

    def initialize(config_file: nil, overrides: {})
      @settings = deep_merge(DEFAULT_CONFIG.dup, load_from_file(config_file))
      @settings = deep_merge(@settings, load_from_env)
      @settings = deep_merge(@settings, overrides)
    end

    # Access nested config with dot notation
    # e.g., config[:detectors, :srp, :max_methods]
    def [](*keys)
      keys.reduce(@settings) do |hash, key|
        hash.is_a?(Hash) ? hash[key.to_sym] : nil
      end
    end

    # Get detector config
    def detector_config(name)
      detector = @settings.dig(:detectors, name.to_sym) || {}
      return nil unless detector[:enabled] != false

      detector.except(:enabled)
    end

    # Get all enabled detectors
    def enabled_detectors
      @settings[:detectors].select { |_, v| v[:enabled] != false }.keys
    end

    # Export config for serialization
    def to_h
      @settings
    end

    def to_yaml
      YAML.dump(deep_stringify_keys(@settings))
    end

    def to_json(*args)
      JSON.pretty_generate(@settings, *args)
    end

    private

    def load_from_file(path)
      return {} unless path && File.exist?(path)

      content = File.read(path)
      case File.extname(path).downcase
      when '.yml', '.yaml'
        deep_symbolize_keys(YAML.safe_load(content, permitted_classes: [Symbol]) || {})
      when '.json'
        deep_symbolize_keys(JSON.parse(content))
      else
        {}
      end
    rescue => e
      warn "[Config] Failed to load #{path}: #{e.message}"
      {}
    end

    def load_from_env
      {
        github: {
          token: ENV['GITHUB_TOKEN']
        },
        llm: {
          api_key: ENV['OPENAI_API_KEY'],
          model: ENV['OPENAI_MODEL']
        }.compact
      }
    end

    def deep_merge(base, override)
      base.merge(override) do |_key, old_val, new_val|
        if old_val.is_a?(Hash) && new_val.is_a?(Hash)
          deep_merge(old_val, new_val)
        else
          new_val.nil? ? old_val : new_val
        end
      end
    end

    def deep_symbolize_keys(hash)
      return hash unless hash.is_a?(Hash)

      hash.each_with_object({}) do |(key, value), result|
        result[key.to_sym] = deep_symbolize_keys(value)
      end
    end

    def deep_stringify_keys(hash)
      return hash unless hash.is_a?(Hash)

      hash.each_with_object({}) do |(key, value), result|
        result[key.to_s] = deep_stringify_keys(value)
      end
    end
  end
end

