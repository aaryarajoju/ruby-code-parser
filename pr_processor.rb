#!/usr/bin/env ruby
# frozen_string_literal: true

# PR Processor - Batch Analysis Script
#
# This script reads PR URLs from a CSV file and analyzes them for design
# principle violations. It's a thin wrapper around the PullRequestAnalyzer
# service for backwards compatibility.
#
# Usage:
#   ruby pr_processor.rb [filter_term]
#
# Examples:
#   ruby pr_processor.rb                    # Analyze all PRs in CSV
#   ruby pr_processor.rb "E2541"           # Only analyze rows containing "E2541"
#
# Environment Variables:
#   GITHUB_TOKEN  - GitHub personal access token for API access
#
# For more options, use the newer CLI:
#   ./bin/analyze_pr --help

require 'bundler/setup'
require 'csv'
require 'fileutils'
require_relative 'lib/ruby_code_parser'

# Configuration
CSV_FILE = ENV.fetch('CSV_FILE', 'submissions.csv')
OUTPUT_DIR = ENV.fetch('OUTPUT_DIR', 'reports')
TEMP_DIR = ENV.fetch('TEMP_DIR', File.join(Dir.pwd, 'temp_downloads'))
LINKS_COLUMN = ENV.fetch('LINKS_COLUMN', 'links')

class LegacyPRProcessor
  def initialize(csv_file:, output_dir:, filter_term: nil)
    @csv_file = csv_file
    @output_dir = output_dir
    @filter_term = filter_term
    @results = []
  end

  def run
    validate_setup
    print_header

    github_service = RubyCodeParser::Services::GitHubService.new
    diff_analyzer = RubyCodeParser::Services::DiffAnalyzer.new
    facade = RubyCodeParser::Facade.new

    analyzer = RubyCodeParser::Services::PullRequestAnalyzer.new(
      github_service: github_service,
      diff_analyzer: diff_analyzer,
      facade: facade,
      config: {
        temp_dir: TEMP_DIR,
        cleanup_temp: true,
        verbose: true
      }
    )

    report_service = RubyCodeParser::Reporters::PRReportService.new(
      config: {
        output_dir: @output_dir,
        formats: %w[json md html],
        verbose: true
      }
    )

    process_csv(analyzer, report_service)
    generate_combined_report(report_service)

    print_summary
  end

  private

  def validate_setup
    unless File.exist?(@csv_file)
      puts "Error: #{@csv_file} not found."
      exit 1
    end

    FileUtils.mkdir_p(@output_dir)
    FileUtils.mkdir_p(TEMP_DIR)
  end

  def print_header
    puts "=" * 60
    puts "Design Principles PR Analyzer"
    puts "=" * 60
    puts "CSV File: #{@csv_file}"
    puts "Output: #{@output_dir}"

    if @filter_term
      puts "Filter: Only processing rows containing '#{@filter_term}'"
    end

    puts "=" * 60
    puts
  end

  def process_csv(analyzer, report_service)
    require 'csv'

    CSV.foreach(@csv_file, headers: true) do |row|
      raw_text = row[LINKS_COLUMN].to_s

      # Apply filter if specified
      next if @filter_term && !raw_text.include?(@filter_term)

      # Extract PR URLs from the row
      pr_infos = RubyCodeParser::Services::GitHubService.extract_pr_urls(raw_text)
      next if pr_infos.empty?

      puts "\n--- Processing Row ---"

      pr_infos.each do |pr_info|
        process_single_pr(analyzer, report_service, pr_info)
      end
    end
  end

  def process_single_pr(analyzer, report_service, pr_info)
    puts "  PR: #{pr_info[:repo]}##{pr_info[:pr_number]}"

    result = analyzer.analyze(
      repo: pr_info[:repo],
      pr_number: pr_info[:pr_number]
    )

    report_service.generate(result, output_dir: @output_dir)
    @results << result

    puts "  [OK] Found #{result.violations.count} violation(s)"

  rescue RubyCodeParser::Services::GitHubService::PullRequestNotFound => e
    puts "  [SKIP] #{e.message}"
  rescue RubyCodeParser::Services::GitHubService::RateLimitExceeded => e
    puts "  [ERROR] #{e.message}"
    puts "  Waiting 60 seconds before retrying..."
    sleep 60
    retry
  rescue StandardError => e
    puts "  [ERROR] #{e.message}"
  end

  def generate_combined_report(report_service)
    return if @results.empty?

    combined_path = File.join(@output_dir, 'combined_analysis.json')
    report_service.generate_combined(@results, output_path: combined_path)
  end

  def print_summary
    puts "\n" + "=" * 60
    puts "ANALYSIS COMPLETE"
    puts "=" * 60

    total_violations = @results.sum { |r| r.violations.count }
    total_files = @results.sum { |r| r.file_results.count }

    puts "PRs Analyzed: #{@results.count}"
    puts "Files Analyzed: #{total_files}"
    puts "Total Violations: #{total_violations}"
    puts
    puts "Reports saved to: #{@output_dir}/"
  end
end

# Run the processor
if __FILE__ == $PROGRAM_NAME
  filter_term = ARGV[0]

  processor = LegacyPRProcessor.new(
    csv_file: CSV_FILE,
    output_dir: OUTPUT_DIR,
    filter_term: filter_term
  )

  processor.run
end
