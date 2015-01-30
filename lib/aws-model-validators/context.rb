module Aws
  module ModelValidators
    class Context

      # @param [Context] parent
      # @param [String<JSONPointer>] path
      # @param [Mixed] value
      # @param [Hash<String,Hash>] models
      # @param [Array<String>] warnings
      # @param [Array<String>] errors
      def initialize(parent:nil, path:'#', value:, models:{}, warnings:[], errors:[])
        @parent = parent
        @path = path
        @value = value
        @models = models
        @warnings = warnings
        @errors = errors
      end

      # Constructs and returns a new context for the value at the given index.
      # @param [String,Integer] key
      # @return [Context]
      def child(key)
        Context.new(
          parent: self,
          path: "#{@path}/#{key}",
          value: value[key],
          models: @models,
          warnings: @warnings,
          errors: @errors,
        )
      end

      # @return [Context,nil] The parent context
      attr_reader :parent

      # @return [String]
      attr_reader :path

      # @return [Object]
      attr_reader :value

      # @return [Array<String>]
      attr_reader :errors

      # @return [Array<String>]
      attr_reader :warnings

      # @param [String, Integer] key
      # @return [Mixed] Returns the value at the given index.
      def [] key
        @value[key]
      end

      # @param [String] error_msg
      # @return [void]
      def error(error_msg)
        @errors << "#{path} #{error_msg}"
        nil
      end

      # @param [String] warning_msg
      # @return [void]
      def warn(warning_msg)
        @warnings << "#{path} #{warning_msg}"
        nil
      end

      def api
        model(:api)
      end

      def paginators
        model(:paginators)
      end

      def waiters
        model(:waiters)
      end

      def resources
        model(:resources)
      end

      # Reduce inspect string to something useful.
      # @api private
      def inspect
        "#<#{self.class.name} path=#{path.inspect} value=#{value_inspect} warnings=#{warnings.inspect} errors=#{errors.inspect}>"
      end

      private

      def value_inspect
        case value
        when Hash then "Hash<#{value.keys.join(', ')}>"
        when Array then "Array<#{value.size}"
        else value.inspect
        end
      end

      # @param [Symbol] model_name This is the model suffix, such as
      #   `:api`, `:resources`, `:paginators`, `:waiters`, etc.
      # @return [Hash]
      # @raise [ArgumentError] Raised when a model is asked for and not found.
      def model(model_name)
        if @models[model_name]
          @models[model_name]
        else
          raise ArgumentError, "#{name} model not available to validate against"
        end
      end

    end
  end
end
