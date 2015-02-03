require 'json'
require 'json-schema'
require 'pathname'

module Aws
  module ModelValidators
    module Validator

      def self.included(klass)
        name = klass.name.split('::').last.downcase.split(/(v\d+)/).join('_')
        schema = File.expand_path("../../../schemas/#{name}.json", __FILE__)
        klass.const_set(:MODEL_NAME, name.sub(/_v\d+$/, '').to_sym)
        klass.const_set(:SCHEMA, LoadJson.load_json(schema))
        klass.const_set(:RULES, [])
        klass.send(:extend, Module.new do
          def v(patterns, &block)
            Array(patterns).each do |pattern|
              const_get(:RULES) << Rule.new(pattern, &block)
            end
          end
        end)
      end

      # @param [Hash] models A map of AWS models. Hash keys should be
      #   symbols and values should be loaded JSON hashes or string paths
      #   to JSON documents. Valid hash keys include:
      #
      #   * `:api`
      #   * `:paginators`
      #   * `:waiters`
      #   * `:resources`
      #
      # @param [Hash<Symbol,Hash>] models
      # @option options [Boolean] :apply_schema (true)
      def validate(models = {}, options = {})
        models = load_models(models)
        errors = []
        errors = validate_schema(models) unless options[:apply_schema] == false
        if errors.empty?
          validate_rules(new_context(models))
        else
          errors
        end
      end

      private

      def load_models(models)
        models.inject({}) { |h,(k,v)| h[k] = LoadJson.load_json(v); h }
      end

      def new_context(models)
        Context.new(value:target(models), models:models)
      end

      def target(models)
        models[self.class::MODEL_NAME]
      end

      def validate_schema(models)
        errors = JSON::Validator.fully_validate(self.class.schema, target(models))
        format_schema_errors(errors)
      end

      def validate_rules(context)
        self.class::RULES.each do |rule|
          if matches = rule.matches(context.path)
            rule.apply(context, matches)
          end
        end
        validate_hash(context) if Hash === context.value
        validate_array(context) if Array === context.value
        context.results
      end

      def validate_hash(context)
        context.value.keys.each do |key|
          validate_rules(context.child(key))
        end
      end

      def validate_array(context)
        (0...context.value.size).each do |index|
          validate_rules(context.child(index))
        end
      end

      def format_schema_errors(errors)
        errors.map do |msg|
          msg = msg.sub(/^The property '/, '')
          msg = msg.sub(/'/, '')
          msg = msg.sub(/ in schema \S+$/, '')
          path = msg.split(' ').first
          ErrorMessage.new(path, msg[(path.size+1)..-1])
        end
      end

    end
  end
end
