
# Ruby Code Parser - Design Principles Analyzer
#
# A modular static analysis pipeline for Ruby codebases that detects
# violations of design principles (SOLID, DRY, Law of Demeter, etc.)
#
# Key Components:
# - Parser Layer: Wraps syntax_tree for AST generation
# - Semantic Layer: Enriches AST with semantic metadata
# - Detector Layer: Rule-specific violation detection
# - Analyzer Layer: LLM or heuristic-based validation
# - Reporter Layer: Multi-format report generation
# - Services Layer: GitHub integration and PR analysis

# Load the bundled gems
require 'syntax_tree'
require 'dry-container'
require 'dry-auto_inject'

begin
  require 'ruby/openai'
rescue LoadError
  # OpenAI gem is optional
end

# 1. Load data models and shared helpers
require_relative 'ruby_code_parser/data_models'
require_relative 'ruby_code_parser/support/text_metrics'

# 2. Core services
require_relative 'ruby_code_parser/parser'
require_relative 'ruby_code_parser/semantic_model_builder'
require_relative 'ruby_code_parser/detector_pipeline'
require_relative 'ruby_code_parser/analyzer'
require_relative 'ruby_code_parser/reporter'

# 3. Visitors and strategies
require_relative 'ruby_code_parser/visitors/enricher_visitor'
require_relative 'ruby_code_parser/strategies/type_inference/llm_type_strategy'
require_relative 'ruby_code_parser/strategies/validation/prompt_strategies'

# 4. Detector visitors per principle
require_relative 'ruby_code_parser/detectors/base_detector'
require_relative 'ruby_code_parser/detectors/srp_detector'
require_relative 'ruby_code_parser/detectors/ocp_detector'
require_relative 'ruby_code_parser/detectors/lsp_detector'
require_relative 'ruby_code_parser/detectors/dip_detector'
require_relative 'ruby_code_parser/detectors/isp_detector'
require_relative 'ruby_code_parser/detectors/law_of_demeter_detector'
require_relative 'ruby_code_parser/detectors/dry_detector'
require_relative 'ruby_code_parser/detectors/information_expert_detector'
require_relative 'ruby_code_parser/detectors/encapsulation_detector'
require_relative 'ruby_code_parser/detectors/overuse_class_methods_detector'

# 5. Container and facade
require_relative 'ruby_code_parser/container'
require_relative 'ruby_code_parser/facade'

# 6. Configuration
require_relative 'ruby_code_parser/config'

# 7. Services (for PR analysis)
require_relative 'ruby_code_parser/services/github_service'
require_relative 'ruby_code_parser/services/diff_analyzer'
require_relative 'ruby_code_parser/services/pull_request_analyzer'

# 8. PR Report generation
require_relative 'ruby_code_parser/reporters/pr_report_formatter'
require_relative 'ruby_code_parser/reporters/pr_report_service'

# Module-level convenience methods
class RubyCodeParser
  class << self
    # Analyze one or more Ruby files
    # @param paths [String, Array<String>] File path(s) to analyze
    # @return [Array<ValidatedViolation>] Detected violations
    def analyze(paths)
      Facade.new.run_analysis(paths)
    end

    # Analyze a pull request
    # @param pr_url [String] GitHub PR URL
    # @param config [Hash] Optional configuration overrides
    # @return [Services::PullRequestAnalyzer::PRAnalysisResult]
    def analyze_pr(pr_url, config: {})
      github_service = Services::GitHubService.new
      diff_analyzer = Services::DiffAnalyzer.new
      facade = Facade.new

      analyzer = Services::PullRequestAnalyzer.new(
        github_service: github_service,
        diff_analyzer: diff_analyzer,
        facade: facade,
        config: config
      )

      analyzer.analyze_by_url(pr_url)
    end

    # Analyze a pull request and generate reports
    # @param pr_url [String] GitHub PR URL
    # @param output_dir [String] Report output directory
    # @return [Hash] Paths to generated reports
    def analyze_pr_with_report(pr_url, output_dir: 'reports')
      result = analyze_pr(pr_url)

      report_service = Reporters::PRReportService.new
      report_service.generate(result, output_dir: output_dir)
    end

    # Load configuration from file
    # @param path [String] Path to config file (YAML or JSON)
    # @return [Config] Configuration object
    def load_config(path = nil)
      Config.new(config_file: path)
    end
  end
end
