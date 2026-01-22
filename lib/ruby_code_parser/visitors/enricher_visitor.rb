require 'syntax_tree'

class RubyCodeParser
  module Visitors
    class EnricherVisitor < SyntaxTree::Visitor
      def initialize(type_strategy)
        @type_strategy = type_strategy
        @enriched_ast = {} 
      end

      def visit_def(node)
        method_name = node.name.value
        inferred_type = @type_strategy.infer_type(node)
        
        @enriched_ast[method_name] = inferred_type
        
        super 
      end

      def result
        @enriched_ast
      end
    end
  end
end