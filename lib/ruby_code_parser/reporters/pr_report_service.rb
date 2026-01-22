require 'fileutils'
require_relative 'pr_report_formatter'

class RubyCodeParser
  module Reporters
    # Service for generating and saving PR analysis reports
    class PRReportService
      def initialize(formatter: PRReportFormatter.new, config: {})
        @formatter = formatter
        @config = default_config.merge(config)
      end

      # Generate and save reports
      # @param result [PRAnalysisResult] The analysis result
      # @param output_dir [String] Override output directory
      # @return [Hash] Paths to generated reports
      def generate(result, output_dir: nil)
        dir = output_dir || @config[:output_dir]
        FileUtils.mkdir_p(dir)

        # Generate a unique prefix for this PR
        prefix = "pr_#{result.pr_info.repo.gsub('/', '_')}_#{result.pr_info.number}"

        paths = {}

        if @config[:formats].include?('json')
          path = File.join(dir, "#{prefix}.json")
          File.write(path, @formatter.to_json(result))
          paths[:json] = path
        end

        if @config[:formats].include?('md')
          path = File.join(dir, "#{prefix}.md")
          File.write(path, @formatter.to_markdown(result))
          paths[:markdown] = path
        end

        if @config[:formats].include?('html')
          path = File.join(dir, "#{prefix}.html")
          File.write(path, @formatter.to_html(result))
          paths[:html] = path
        end

        log_summary(result)
        paths
      end

      # Generate a combined report for multiple PRs
      # @param results [Array<PRAnalysisResult>] Analysis results
      # @param output_path [String] Output file path
      def generate_combined(results, output_path:)
        combined = {
          generated_at: Time.now.iso8601,
          total_prs: results.count,
          total_violations: results.sum { |r| r.violations.count },
          results: results.map(&:to_h)
        }

        File.write(output_path, JSON.pretty_generate(combined))
        puts "\n=== Combined Report ==="
        puts "Analyzed #{results.count} PRs with #{combined[:total_violations]} total violations"
        puts "Report saved to: #{output_path}"
      end

      private

      def default_config
        {
          output_dir: 'reports',
          formats: %w[json md html],
          verbose: true
        }
      end

      def log_summary(result)
        return unless @config[:verbose]

        puts "\n=== Analysis Complete ==="
        puts "PR: #{result.pr_info.repo}##{result.pr_info.number} - #{result.pr_info.title}"
        puts "Files Analyzed: #{result.summary[:files_analyzed]}"
        puts "Total Violations: #{result.summary[:total_violations]}"
        puts "  - In Changed Code: #{result.summary[:violations_in_changed_code]}"
        puts "  - High Severity: #{result.summary[:high_severity_count]}"

        if result.summary[:violations_by_type].any?
          puts "\nBy Principle:"
          result.summary[:violations_by_type].each do |type, count|
            puts "  - #{type.to_s.upcase}: #{count}"
          end
        end

        puts ""
      end
    end
  end
end

