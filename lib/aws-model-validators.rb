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
    autoload :LoadJson, 'aws-model-validators/load_json'
    autoload :PathResolver, 'aws-model-validators/path_resolver'
    autoload :Rule, 'aws-model-validators/rule'
    autoload :Validator, 'aws-model-validators/validator'
    autoload :ValidationMessage, 'aws-model-validators/validation_message'
    autoload :VERSION, 'aws-model-validators/version'
    autoload :Warning, 'aws-model-validators/warning'

  end
end
