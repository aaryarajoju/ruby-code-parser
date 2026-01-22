require 'syntax_tree'

class RubyCodeParser
  class Parser
    def parse(code)
      SyntaxTree.parse(code)
    end
  end
end
