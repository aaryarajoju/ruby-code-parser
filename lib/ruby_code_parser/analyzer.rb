require 'ruby/openai'

class RubyCodeParser
  class Analyzer
    def initialize(validation_strategies_map, llm_client)
      @strategy_map = validation_strategies_map
      @llm_client = llm_client
    end

    def analyze(candidates)
      candidates.map do |candidate|
        strategy = @strategy_map[candidate.smell_type]
        
        strategy.validate(candidate, @llm_client)
      end
    end
  end

  class SRPValidationStrategy
    def validate(candidate, client)
      prompt = "Analyze this class... does it have one reason to change?..."
      
      response = client.chat(
        parameters: { model: "gpt-4o", messages: [{ role: "user", content: prompt }] }
      )
      
      #... parse response and return a ValidatedViolation struct
    end
  end
end