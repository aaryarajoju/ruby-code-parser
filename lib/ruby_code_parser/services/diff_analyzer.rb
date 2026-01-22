class RubyCodeParser
  module Services
    # DiffAnalyzer parses and analyzes unified diff patches
    # Extracts meaningful information about what changed
    class DiffAnalyzer
      # Represents a hunk (section) of changes in a diff
      DiffHunk = Struct.new(
        :old_start,
        :old_count,
        :new_start,
        :new_count,
        :changes,      # Array of DiffLine
        :context,      # Context lines before/after
        keyword_init: true
      ) do
        def added_lines
          changes.select(&:addition?)
        end

        def removed_lines
          changes.select(&:removal?)
        end

        def modified_lines_count
          [added_lines.count, removed_lines.count].max
        end
      end

      # Represents a single line in a diff
      DiffLine = Struct.new(
        :type,         # :context, :addition, :removal
        :content,
        :old_line_no,
        :new_line_no,
        keyword_init: true
      ) do
        def addition?
          type == :addition
        end

        def removal?
          type == :removal
        end

        def context?
          type == :context
        end
      end

      # Parsed diff result for a file
      ParsedDiff = Struct.new(
        :filename,
        :hunks,
        :summary,
        keyword_init: true
      ) do
        def total_additions
          hunks.sum { |h| h.added_lines.count }
        end

        def total_deletions
          hunks.sum { |h| h.removed_lines.count }
        end

        def changed_line_numbers
          hunks.flat_map do |hunk|
            hunk.changes.select(&:addition?).map(&:new_line_no)
          end.compact
        end

        def added_content
          hunks.flat_map { |h| h.added_lines.map(&:content) }.join("\n")
        end

        def removed_content
          hunks.flat_map { |h| h.removed_lines.map(&:content) }.join("\n")
        end
      end

      # Parses a unified diff patch string
      # @param patch [String] Unified diff content
      # @param filename [String] Filename for reference
      # @return [ParsedDiff]
      def parse(patch, filename: nil)
        return empty_diff(filename) if patch.nil? || patch.empty?

        hunks = []
        current_hunk = nil
        old_line = 0
        new_line = 0

        patch.each_line do |line|
          if line.start_with?('@@')
            # Save previous hunk
            hunks << current_hunk if current_hunk

            # Parse hunk header: @@ -start,count +start,count @@
            match = line.match(/@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@/)
            if match
              old_line = match[1].to_i
              new_line = match[3].to_i
              current_hunk = DiffHunk.new(
                old_start: old_line,
                old_count: match[2]&.to_i || 1,
                new_start: new_line,
                new_count: match[4]&.to_i || 1,
                changes: [],
                context: extract_context(line)
              )
            end
          elsif current_hunk
            diff_line = parse_diff_line(line, old_line, new_line)
            current_hunk.changes << diff_line

            case diff_line.type
            when :addition
              new_line += 1
            when :removal
              old_line += 1
            when :context
              old_line += 1
              new_line += 1
            end
          end
        end

        hunks << current_hunk if current_hunk

        ParsedDiff.new(
          filename: filename,
          hunks: hunks,
          summary: build_summary(hunks)
        )
      end

      # Analyzes changes to understand what kinds of modifications were made
      # @param parsed_diff [ParsedDiff]
      # @return [Hash] Analysis results
      def analyze_changes(parsed_diff)
        added = parsed_diff.added_content
        removed = parsed_diff.removed_content

        {
          methods_added: extract_methods(added),
          methods_removed: extract_methods(removed),
          classes_added: extract_classes(added),
          classes_removed: extract_classes(removed),
          has_new_dependencies: added.match?(/\brequire\b|\binclude\b|\bextend\b/),
          has_new_conditionals: added.match?(/\bif\b|\bunless\b|\bcase\b|\bwhen\b/),
          has_new_instantiations: added.match?(/\.new\b/),
          complexity_indicators: count_complexity_indicators(added),
          total_changes: parsed_diff.total_additions + parsed_diff.total_deletions
        }
      end

      private

      def empty_diff(filename)
        ParsedDiff.new(
          filename: filename,
          hunks: [],
          summary: "No changes"
        )
      end

      def parse_diff_line(line, old_line, new_line)
        content = line[1..-1]&.chomp || ''

        case line[0]
        when '+'
          DiffLine.new(type: :addition, content: content, old_line_no: nil, new_line_no: new_line)
        when '-'
          DiffLine.new(type: :removal, content: content, old_line_no: old_line, new_line_no: nil)
        else
          DiffLine.new(type: :context, content: content, old_line_no: old_line, new_line_no: new_line)
        end
      end

      def extract_context(hunk_header)
        # Extract function/method context from hunk header
        match = hunk_header.match(/@@ .* @@ (.+)$/)
        match ? match[1].strip : nil
      end

      def build_summary(hunks)
        additions = hunks.sum { |h| h.added_lines.count }
        deletions = hunks.sum { |h| h.removed_lines.count }
        "#{additions} addition(s), #{deletions} deletion(s) in #{hunks.count} hunk(s)"
      end

      def extract_methods(content)
        content.scan(/def\s+(\w+)/).flatten
      end

      def extract_classes(content)
        content.scan(/class\s+([A-Z]\w*(?:::\w+)*)/).flatten
      end

      def count_complexity_indicators(content)
        {
          conditionals: content.scan(/\b(if|unless|case|when|elsif|else)\b/).count,
          loops: content.scan(/\b(while|until|for|each|map|select|reject)\b/).count,
          blocks: content.scan(/\b(do|begin|rescue|ensure)\b/).count,
          method_calls: content.scan(/\.\w+/).count
        }
      end
    end
  end
end

