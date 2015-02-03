module Aws
  module ModelValidators

    # @api private
    GEM_ROOT = File.expand_path('../../', __FILE__)

    # validators
    autoload :ApiV2, 'aws-model-validators/api_v2'
    autoload :PaginatorsV1, 'aws-model-validators/paginators_v1'
    autoload :WaitersV2, 'aws-model-validators/waiters_v2'
    autoload :ResourcesV1, 'aws-model-validators/resources_v1'

    # support classes
    autoload :Context, 'aws-model-validators/context'
    autoload :ErrorMessage, 'aws-model-validators/error_message'
    autoload :PathResolver, 'aws-model-validators/path_resolver'
    autoload :Rule, 'aws-model-validators/rule'
    autoload :Validator, 'aws-model-validators/validator'
    autoload :ValidationMessage, 'aws-model-validators/validation_message'
    autoload :VERSION, 'aws-model-validators/version'
    autoload :Warning, 'aws-model-validators/warning'

    class << self

      def load_json(src)
        case src
        when Hash then src
        when Pathname, String then JSON.load(read_file(src))
        else
          msg = "expected a path to a JSON document or hash got: #{src.class}"
          raise ArgumentError, msg
        end
      end

      private

      def read_file(path)
        File.open(path, 'r', encoding: 'UTF-8') { |f| f.read }
      end

    end
  end
end
