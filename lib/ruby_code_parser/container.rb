require 'dry-container'
require 'ruby/openai'

class RubyCodeParser
  class Container
    extend Dry::Container::Mixin

    register 'llm.client', -> { OpenAI::Client.new }

    register 'strategies.type.llm', -> {
      RubyCodeParser::Strategies::TypeInference::LLMTypeInferenceStrategy.new(client: self['llm.client'])
    }

    register 'strategies.heuristic.srp', -> {
      RubyCodeParser::Strategies::Heuristic::LargeClassStrategy.new(max_methods: 5)
    }
    register 'strategies.heuristic.lod', -> {
      RubyCodeParser::Strategies::Heuristic::MethodChainStrategy.new(max_chain: 3)
    }

    register 'strategies.validation.srp', -> {
      RubyCodeParser::Strategies::Validation::SRPValidationStrategy.new
    }
    
    register 'parser', -> { RubyCodeParser::Parser.new }
    
    register 'enricher', -> { 
      RubyCodeParser::Visitors::EnricherVisitor.new(self['strategies.type.llm'])
    }
    
    register 'detector', -> {
      strategies = [self['strategies.heuristic.srp'], self['strategies.heuristic.lod']]
      RubyCodeParser::Visitors::DetectorVisitor.new(strategies)
    }

    register 'analyzer', -> {
      strategy_map = { srp: self['strategies.validation.srp'] }
      RubyCodeParser::Analyzer.new(strategy_map, self['llm.client'])
    }
    
    register 'reporter', -> { RubyCodeParser::Reporter.new }
  end
end
