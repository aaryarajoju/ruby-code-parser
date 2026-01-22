require_relative 'container'

class RubyCodeParser
  Import = Dry::AutoInject(Container)

  class Facade
    include Import['parser', 'enricher', 'detector', 'analyzer', 'reporter']

    def run_analysis(file_path)
      code = File.read(file_path)
      ast = parser.parse(code)

      ast.accept(enricher)
      enriched_ast = enricher.result

      ast.accept(detector)
      candidates = detector.result
      
      validated_violations = analyzer.analyze(candidates)

      reporter.generate(validated_violations)
      
    rescue => e
      puts "Analysis failed: #{e.message}"
    end
  end
end
