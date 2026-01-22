require 'fileutils'
require 'json'

class RubyCodeParser
  module Services
    # PullRequestAnalyzer orchestrates the analysis of pull requests
    # It fetches PRs, downloads files, runs analysis, and generates reports
    class PullRequestAnalyzer
      # Result of analyzing a single PR
      PRAnalysisResult = Struct.new(
        :pr_info,
        :file_results,
        :summary,
        :violations,
        :analysis_metadata,
        keyword_init: true
      ) do
        def to_h
          {
            pull_request: {
              repo: pr_info.repo,
              number: pr_info.number,
              title: pr_info.title,
              author: pr_info.author,
              url: pr_info.url,
              state: pr_info.state,
              merged: pr_info.merged
            },
            summary: summary,
            files_analyzed: file_results.count,
            total_violations: violations.count,
            violations: violations.map(&:to_h),
            file_details: file_results.map { |fr| fr.to_h },
            metadata: analysis_metadata
          }
        end

        def to_json(*args)
          JSON.pretty_generate(to_h, *args)
        end
      end

      # Result of analyzing a single file in the PR
      FileAnalysisResult = Struct.new(
        :filename,
        :status,
        :diff_analysis,
        :violations,
        :local_path,
        keyword_init: true
      ) do
        def to_h
          {
            filename: filename,
            status: status,
            diff_summary: diff_analysis&.summary,
            changes_analysis: diff_analysis ? {
              lines_added: diff_analysis.total_additions,
              lines_deleted: diff_analysis.total_deletions
            } : nil,
            violations_count: violations.count,
            violations: violations.map(&:to_h)
          }
        end
      end

      def initialize(
        github_service:,
        diff_analyzer:,
        facade:,
        config: {}
      )
        @github_service = github_service
        @diff_analyzer = diff_analyzer
        @facade = facade
        @config = default_config.merge(config)
      end

      # Analyzes a pull request by URL
      # @param pr_url [String] GitHub PR URL
      # @return [PRAnalysisResult]
      def analyze_by_url(pr_url)
        parsed = Services::GitHubService.parse_pr_url(pr_url)
        raise ArgumentError, "Invalid PR URL: #{pr_url}" unless parsed

        analyze(repo: parsed[:repo], pr_number: parsed[:pr_number])
      end

      # Analyzes a pull request
      # @param repo [String] Repository in "owner/repo" format
      # @param pr_number [Integer] PR number
      # @return [PRAnalysisResult]
      def analyze(repo:, pr_number:)
        log "Fetching PR ##{pr_number} from #{repo}..."
        pr_info = @github_service.fetch_pull_request(repo: repo, pr_number: pr_number)

        ruby_files = pr_info.ruby_files
        log "Found #{ruby_files.count} Ruby file(s) to analyze"

        file_results = analyze_files(ruby_files, pr_info)
        all_violations = file_results.flat_map(&:violations)

        PRAnalysisResult.new(
          pr_info: pr_info,
          file_results: file_results,
          summary: build_summary(pr_info, file_results, all_violations),
          violations: all_violations,
          analysis_metadata: {
            analyzed_at: Time.now.iso8601,
            analyzer_version: '1.0.0',
            config: @config.slice(:analyze_only_diff, :min_confidence)
          }
        )
      ensure
        cleanup_temp_files if @config[:cleanup_temp]
      end

      private

      def default_config
        {
          temp_dir: File.join(Dir.pwd, 'temp_downloads'),
          # When true, only report violations in/near changed lines
          # The full file is still analyzed for proper context
          report_only_changed: true,
          # How many lines from a change to consider "near" the diff
          changed_line_tolerance: 10,
          min_confidence: 0.6,
          cleanup_temp: true,
          verbose: true
        }
      end

      def analyze_files(file_changes, pr_info)
        FileUtils.mkdir_p(@config[:temp_dir])

        file_changes.map do |file_change|
          analyze_single_file(file_change, pr_info)
        end.compact
      end

      def analyze_single_file(file_change, pr_info)
        log "  Analyzing: #{file_change.filename}"

        # Parse the diff first
        diff_analysis = @diff_analyzer.parse(file_change.patch, filename: file_change.filename)
        changes_info = @diff_analyzer.analyze_changes(diff_analysis)

        # Skip removed files
        if file_change.removed?
          log "    (Skipped: file was removed)"
          return FileAnalysisResult.new(
            filename: file_change.filename,
            status: 'removed',
            diff_analysis: diff_analysis,
            violations: [],
            local_path: nil
          )
        end

        # Download and analyze the file
        local_path = download_file(file_change)
        violations = run_analysis(local_path, file_change, diff_analysis)

        # Enrich violations with diff context
        enriched_violations = enrich_with_diff_context(violations, diff_analysis, changes_info)

        FileAnalysisResult.new(
          filename: file_change.filename,
          status: file_change.status,
          diff_analysis: diff_analysis,
          violations: enriched_violations,
          local_path: local_path
        )
      rescue => e
        log "    [ERROR] #{e.message}"
        FileAnalysisResult.new(
          filename: file_change.filename,
          status: 'error',
          diff_analysis: nil,
          violations: [],
          local_path: nil
        )
      end

      def download_file(file_change)
        clean_name = file_change.filename.gsub('/', '_')
        local_path = File.join(@config[:temp_dir], clean_name)

        @github_service.download_file(
          raw_url: file_change.raw_url,
          local_path: local_path
        )

        local_path
      end

      def run_analysis(local_path, file_change, diff_analysis)
        # Run the full analysis pipeline
        @facade.run_analysis(local_path)
      rescue => e
        log "    [WARN] Analysis failed: #{e.message}"
        []
      end

      def enrich_with_diff_context(violations, diff_analysis, changes_info)
        return violations if diff_analysis.nil?

        changed_lines = diff_analysis.changed_line_numbers.to_set
        tolerance = @config[:changed_line_tolerance] || 10

        enriched_violations = violations.map do |violation|
          # Check if the violation is in or near a changed line
          violation_line = violation.to_h.dig(:location, :line) || 0
          in_changed_code = changed_lines.include?(violation_line) ||
                           changed_lines.any? { |l| (l - tolerance..l + tolerance).cover?(violation_line) }

          # Also check if the violation's class/method was modified
          violation_context = violation.to_h[:context].to_s
          in_modified_method = changes_info[:methods_added].any? { |m| violation_context.include?("def #{m}") } ||
                              changes_info[:methods_added].any? { |m| violation.to_h[:reason].to_s.include?("`#{m}`") }

          is_relevant = in_changed_code || in_modified_method

          # Add diff context to the violation
          enriched = violation.to_h.merge(
            in_changed_code: is_relevant,
            near_changed_line: in_changed_code,
            in_modified_method: in_modified_method,
            diff_context: {
              lines_added: diff_analysis.total_additions,
              lines_deleted: diff_analysis.total_deletions,
              methods_added: changes_info[:methods_added],
              methods_removed: changes_info[:methods_removed]
            }
          )

          EnrichedViolation.new(violation, enriched)
        end

        # Filter to only violations in changed code if configured
        if @config[:report_only_changed]
          enriched_violations.select { |v| v.to_h[:in_changed_code] }
        else
          enriched_violations
        end
      end

      def build_summary(pr_info, file_results, all_violations)
        by_type = all_violations.group_by { |v| v.to_h[:type] }

        {
          pr_title: pr_info.title,
          files_analyzed: file_results.count,
          files_with_violations: file_results.count { |fr| fr.violations.any? },
          total_violations: all_violations.count,
          violations_in_changed_code: all_violations.count { |v| v.to_h[:in_changed_code] },
          violations_by_type: by_type.transform_values(&:count),
          high_severity_count: all_violations.count { |v| (v.to_h[:confidence] || 0) >= 0.8 },
          report_mode: @config[:report_only_changed] ? 'changed_code_only' : 'all_violations'
        }
      end

      def cleanup_temp_files
        return unless @config[:cleanup_temp] && Dir.exist?(@config[:temp_dir])

        Dir.glob(File.join(@config[:temp_dir], '*.rb')).each do |file|
          File.delete(file) if File.exist?(file)
        end
      end

      def log(message)
        puts message if @config[:verbose]
      end
    end

    # Wrapper that adds diff context to a violation
    class EnrichedViolation
      def initialize(original, enriched_hash)
        @original = original
        @enriched = enriched_hash
      end

      def to_h
        @enriched
      end

      def method_missing(method, *args, &block)
        if @original.respond_to?(method)
          @original.send(method, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(method, include_private = false)
        @original.respond_to?(method) || super
      end
    end
  end
end

