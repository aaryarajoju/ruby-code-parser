require 'json'
require 'erb'

class RubyCodeParser
  module Reporters
    # Formats PR analysis results into various output formats
    class PRReportFormatter
      # Generate a detailed Markdown report
      def to_markdown(result)
        lines = []
        lines << "# Design Principles Analysis Report"
        lines << ""
        lines << "## Pull Request Information"
        lines << ""
        lines << "| Property | Value |"
        lines << "|----------|-------|"
        lines << "| **Repository** | #{result.pr_info.repo} |"
        lines << "| **PR Number** | ##{result.pr_info.number} |"
        lines << "| **Title** | #{result.pr_info.title} |"
        lines << "| **Author** | #{result.pr_info.author} |"
        lines << "| **URL** | [#{result.pr_info.url}](#{result.pr_info.url}) |"
        lines << "| **State** | #{result.pr_info.state} |"
        lines << "| **Merged** | #{result.pr_info.merged ? 'Yes' : 'No'} |"
        lines << ""
        lines << "## Summary"
        lines << ""
        lines << "| Metric | Count |"
        lines << "|--------|-------|"
        lines << "| Files Analyzed | #{result.summary[:files_analyzed]} |"
        lines << "| Files with Violations | #{result.summary[:files_with_violations]} |"
        lines << "| Total Violations | #{result.summary[:total_violations]} |"
        lines << "| Violations in Changed Code | #{result.summary[:violations_in_changed_code]} |"
        lines << "| High Severity Violations | #{result.summary[:high_severity_count]} |"
        lines << ""

        if result.summary[:violations_by_type].any?
          lines << "### Violations by Design Principle"
          lines << ""
          lines << "| Principle | Count |"
          lines << "|-----------|-------|"
          result.summary[:violations_by_type].each do |type, count|
            lines << "| #{format_principle_name(type)} | #{count} |"
          end
          lines << ""
        end

        lines << "## Detailed Findings"
        lines << ""

        result.file_results.each do |file_result|
          lines << "### #{file_result.filename}"
          lines << ""
          lines << "**Status:** #{file_result.status}"

          if file_result.diff_analysis
            lines << "**Changes:** +#{file_result.diff_analysis.total_additions} / -#{file_result.diff_analysis.total_deletions}"
          end
          lines << ""

          if file_result.violations.empty?
            lines << "> No design principle violations detected."
            lines << ""
          else
            file_result.violations.each_with_index do |violation, idx|
              v = violation.to_h
              lines << "#### #{idx + 1}. #{format_principle_name(v[:type])}"
              lines << ""
              lines << "- **Class/Module:** `#{v[:class]}`"
              lines << "- **Line:** #{v.dig(:location, :line)}"
              lines << "- **Confidence:** #{format_confidence(v[:confidence])}"
              lines << "- **Reason:** #{v[:reason]}"

              if v[:in_changed_code]
                lines << "- **Note:** This violation is in code that was changed in this PR"
              end

              if v[:justification]
                lines << ""
                lines << "**Analysis:** #{v[:justification]}"
              end

              if v[:suggestion]
                lines << ""
                lines << "**Suggestion:** #{v[:suggestion]}"
              end

              if v[:context]
                lines << ""
                lines << "**Code Context:**"
                lines << "```ruby"
                lines << v[:context].to_s.lines.first(8).join.strip
                lines << "```"
              end
              lines << ""
            end
          end
        end

        lines << "---"
        lines << ""
        lines << "*Report generated at #{result.analysis_metadata[:analyzed_at]}*"

        lines.join("\n")
      end

      # Generate HTML report
      def to_html(result)
        template = <<~HTML
          <!DOCTYPE html>
          <html lang="en">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Design Principles Analysis - PR #<%= result.pr_info.number %></title>
            <style>
              :root {
                --bg-primary: #0d1117;
                --bg-secondary: #161b22;
                --bg-tertiary: #21262d;
                --text-primary: #c9d1d9;
                --text-secondary: #8b949e;
                --accent-blue: #58a6ff;
                --accent-green: #3fb950;
                --accent-yellow: #d29922;
                --accent-red: #f85149;
                --accent-purple: #a371f7;
                --border-color: #30363d;
              }
              
              * { box-sizing: border-box; margin: 0; padding: 0; }
              
              body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
                background: var(--bg-primary);
                color: var(--text-primary);
                line-height: 1.6;
                padding: 2rem;
              }
              
              .container { max-width: 1200px; margin: 0 auto; }
              
              h1 {
                font-size: 2rem;
                margin-bottom: 1.5rem;
                color: var(--text-primary);
                border-bottom: 1px solid var(--border-color);
                padding-bottom: 0.5rem;
              }
              
              h2 {
                font-size: 1.4rem;
                margin: 2rem 0 1rem;
                color: var(--accent-blue);
              }
              
              h3 {
                font-size: 1.1rem;
                margin: 1.5rem 0 0.75rem;
                color: var(--text-primary);
              }
              
              .pr-info {
                background: var(--bg-secondary);
                border: 1px solid var(--border-color);
                border-radius: 6px;
                padding: 1.5rem;
                margin-bottom: 2rem;
              }
              
              .pr-info a {
                color: var(--accent-blue);
                text-decoration: none;
              }
              
              .pr-info a:hover { text-decoration: underline; }
              
              .stats-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 1rem;
                margin: 1rem 0;
              }
              
              .stat-card {
                background: var(--bg-secondary);
                border: 1px solid var(--border-color);
                border-radius: 6px;
                padding: 1rem;
                text-align: center;
              }
              
              .stat-card .value {
                font-size: 2rem;
                font-weight: bold;
                color: var(--accent-blue);
              }
              
              .stat-card .label {
                font-size: 0.85rem;
                color: var(--text-secondary);
                margin-top: 0.25rem;
              }
              
              .stat-card.warning .value { color: var(--accent-yellow); }
              .stat-card.danger .value { color: var(--accent-red); }
              .stat-card.success .value { color: var(--accent-green); }
              
              .file-section {
                background: var(--bg-secondary);
                border: 1px solid var(--border-color);
                border-radius: 6px;
                margin: 1rem 0;
                overflow: hidden;
              }
              
              .file-header {
                background: var(--bg-tertiary);
                padding: 0.75rem 1rem;
                border-bottom: 1px solid var(--border-color);
                display: flex;
                justify-content: space-between;
                align-items: center;
              }
              
              .file-name { font-family: monospace; font-weight: bold; }
              
              .badge {
                display: inline-block;
                padding: 0.2rem 0.6rem;
                border-radius: 12px;
                font-size: 0.75rem;
                font-weight: 600;
              }
              
              .badge-added { background: rgba(63, 185, 80, 0.2); color: var(--accent-green); }
              .badge-modified { background: rgba(210, 153, 34, 0.2); color: var(--accent-yellow); }
              .badge-removed { background: rgba(248, 81, 73, 0.2); color: var(--accent-red); }
              
              .violation {
                padding: 1rem;
                border-bottom: 1px solid var(--border-color);
              }
              
              .violation:last-child { border-bottom: none; }
              
              .violation-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 0.5rem;
              }
              
              .violation-type {
                font-weight: bold;
                color: var(--accent-purple);
              }
              
              .confidence {
                padding: 0.2rem 0.6rem;
                border-radius: 4px;
                font-size: 0.8rem;
                font-weight: bold;
              }
              
              .confidence-high { background: rgba(248, 81, 73, 0.2); color: var(--accent-red); }
              .confidence-medium { background: rgba(210, 153, 34, 0.2); color: var(--accent-yellow); }
              .confidence-low { background: rgba(63, 185, 80, 0.2); color: var(--accent-green); }
              
              .violation-meta {
                font-size: 0.85rem;
                color: var(--text-secondary);
                margin-bottom: 0.5rem;
              }
              
              .violation-reason { margin: 0.75rem 0; }
              
              .code-block {
                background: var(--bg-primary);
                border: 1px solid var(--border-color);
                border-radius: 4px;
                padding: 0.75rem;
                font-family: monospace;
                font-size: 0.85rem;
                overflow-x: auto;
                white-space: pre-wrap;
                margin-top: 0.75rem;
              }
              
              .changed-indicator {
                background: rgba(88, 166, 255, 0.2);
                color: var(--accent-blue);
                padding: 0.2rem 0.5rem;
                border-radius: 4px;
                font-size: 0.75rem;
                margin-left: 0.5rem;
              }
              
              .no-violations {
                padding: 1rem;
                color: var(--accent-green);
                text-align: center;
              }
              
              .suggestion {
                background: rgba(163, 113, 247, 0.1);
                border-left: 3px solid var(--accent-purple);
                padding: 0.75rem;
                margin-top: 0.75rem;
                font-size: 0.9rem;
              }
              
              footer {
                margin-top: 3rem;
                padding-top: 1rem;
                border-top: 1px solid var(--border-color);
                text-align: center;
                color: var(--text-secondary);
                font-size: 0.85rem;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <h1>Design Principles Analysis Report</h1>
              
              <div class="pr-info">
                <h2 style="margin-top: 0;">Pull Request #<%= result.pr_info.number %></h2>
                <p><strong><%= result.pr_info.title %></strong></p>
                <p>
                  <strong>Repository:</strong> <%= result.pr_info.repo %> |
                  <strong>Author:</strong> <%= result.pr_info.author %> |
                  <strong>State:</strong> <%= result.pr_info.state %>
                  <% if result.pr_info.merged %> (Merged) <% end %>
                </p>
                <p><a href="<%= result.pr_info.url %>" target="_blank">View on GitHub →</a></p>
              </div>
              
              <div class="stats-grid">
                <div class="stat-card">
                  <div class="value"><%= result.summary[:files_analyzed] %></div>
                  <div class="label">Files Analyzed</div>
                </div>
                <div class="stat-card <%= result.summary[:total_violations] > 10 ? 'danger' : result.summary[:total_violations] > 0 ? 'warning' : 'success' %>">
                  <div class="value"><%= result.summary[:total_violations] %></div>
                  <div class="label">Total Violations</div>
                </div>
                <div class="stat-card <%= result.summary[:violations_in_changed_code] > 0 ? 'warning' : 'success' %>">
                  <div class="value"><%= result.summary[:violations_in_changed_code] %></div>
                  <div class="label">In Changed Code</div>
                </div>
                <div class="stat-card <%= result.summary[:high_severity_count] > 0 ? 'danger' : 'success' %>">
                  <div class="value"><%= result.summary[:high_severity_count] %></div>
                  <div class="label">High Severity</div>
                </div>
              </div>
              
              <% if result.summary[:violations_by_type].any? %>
              <h2>Violations by Principle</h2>
              <div class="stats-grid">
                <% result.summary[:violations_by_type].each do |type, count| %>
                <div class="stat-card">
                  <div class="value"><%= count %></div>
                  <div class="label"><%= format_principle_name(type) %></div>
                </div>
                <% end %>
              </div>
              <% end %>
              
              <h2>Detailed Findings</h2>
              
              <% result.file_results.each do |file_result| %>
              <div class="file-section">
                <div class="file-header">
                  <span class="file-name"><%= file_result.filename %></span>
                  <span>
                    <span class="badge badge-<%= file_result.status %>"><%= file_result.status %></span>
                    <% if file_result.diff_analysis %>
                    <span style="color: var(--accent-green)">+<%= file_result.diff_analysis.total_additions %></span>
                    <span style="color: var(--accent-red)">-<%= file_result.diff_analysis.total_deletions %></span>
                    <% end %>
                  </span>
                </div>
                
                <% if file_result.violations.empty? %>
                <div class="no-violations">✓ No design principle violations detected</div>
                <% else %>
                <% file_result.violations.each do |violation| %>
                <% v = violation.to_h %>
                <div class="violation">
                  <div class="violation-header">
                    <span>
                      <span class="violation-type"><%= format_principle_name(v[:type]) %></span>
                      <% if v[:in_changed_code] %>
                      <span class="changed-indicator">Changed Code</span>
                      <% end %>
                    </span>
                    <span class="confidence <%= confidence_class(v[:confidence]) %>">
                      <%= format_confidence(v[:confidence]) %>
                    </span>
                  </div>
                  <div class="violation-meta">
                    <strong>Class:</strong> <code><%= v[:class] %></code> |
                    <strong>Line:</strong> <%= v.dig(:location, :line) %>
                  </div>
                  <div class="violation-reason"><%= v[:reason] %></div>
                  <% if v[:suggestion] %>
                  <div class="suggestion"><strong>💡 Suggestion:</strong> <%= v[:suggestion] %></div>
                  <% end %>
                  <% if v[:context] %>
                  <div class="code-block"><%= h(v[:context].to_s.lines.first(8).join) %></div>
                  <% end %>
                </div>
                <% end %>
                <% end %>
              </div>
              <% end %>
              
              <footer>
                Report generated at <%= result.analysis_metadata[:analyzed_at] %>
              </footer>
            </div>
          </body>
          </html>
        HTML

        ERB.new(template, trim_mode: '-').result(binding)
      end

      # Generate JSON report
      def to_json(result)
        result.to_json
      end

      private

      def format_principle_name(type)
        case type.to_s.upcase
        when 'SRP' then 'Single Responsibility Principle'
        when 'OCP' then 'Open/Closed Principle'
        when 'LSP' then 'Liskov Substitution Principle'
        when 'DIP' then 'Dependency Inversion Principle'
        when 'ISP' then 'Interface Segregation Principle'
        when 'LAW_OF_DEMETER' then 'Law of Demeter'
        when 'DRY' then "Don't Repeat Yourself"
        when 'INFORMATION_EXPERT' then 'Information Expert'
        when 'ENCAPSULATION' then 'Encapsulation'
        when 'OVERUSE_CLASS_METHODS' then 'Overuse of Class Methods'
        else type.to_s.gsub('_', ' ').split.map(&:capitalize).join(' ')
        end
      end

      def format_confidence(confidence)
        return "N/A" if confidence.nil?
        "#{(confidence * 100).round}%"
      end

      def confidence_class(confidence)
        return 'confidence-low' if confidence.nil?
        if confidence >= 0.8
          'confidence-high'
        elsif confidence >= 0.6
          'confidence-medium'
        else
          'confidence-low'
        end
      end

      def h(text)
        ERB::Util.html_escape(text.to_s)
      end
    end
  end
end

