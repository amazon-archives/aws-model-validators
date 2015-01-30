module Aws
  module ModelValidators
    class Rule

      def initialize(pattern, &block)
        pattern = Regexp.escape(pattern).gsub('\*', '(\w+|\d+)')
        @pattern = Regexp.new('^' + pattern + '$')
        @block = block
      end

      def matches(path)
        path.match(@pattern)
      end

      def apply(context, matches)
        @block.call(context, matches)
      end

    end
  end
end
