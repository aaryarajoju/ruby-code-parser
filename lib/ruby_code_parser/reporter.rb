
class RubyCodeParser
  class Reporter
    def generate(validated_violations)
      puts "\n--- Analysis Complete ---"
      if validated_violations.empty?
        puts "No violations found."
        return
      end

      puts "Found #{validated_violations.length} high-confidence violation(s):\n\n"

      validated_violations.each do |violation|
        puts "================================="
        puts "Smell: #{violation.candidate.smell_type.to_s.upcase}"
        puts "File: #{violation.candidate.file_path}"
        puts "Message: #{violation.candidate.message}"
        puts "---"
        puts "LLM Justification: #{violation.llm_justification}"
        puts "=================================\n"
      end
    end
  end
end