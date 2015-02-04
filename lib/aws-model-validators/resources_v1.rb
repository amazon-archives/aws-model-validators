module Aws::ModelValidators
  class ResourcesV1

    include Validator

    # TODO: has_many_request_params_may_not_be_input
    # TODO: service_has_resource_identifiers_must_be_input_or_literal
    # TODO: service_request_params_must_be_literals
    # TODO: service_has_resource_path_not_permitted
    # TODO: resource_load_path resolves
    # TODO: resource_has_path_resolves

    # identifiers_may_not_be_prefixed_by_their_resource_name
    v('/resources/*/identifiers/*/name') do |c, matches|
      resource_name = matches[1]
      if c.value.match(/^#{resource_name}/)
        c.error("must not be prefixed with '#{resource_name}'")
      end
    end

    # identifiers_must_have_unique_names
    v('/resources/*/identifiers') do |c|
      names = c.value.map { |v| v['name'] }
      unless names.uniq == names
        c.error("must have unique names")
      end
    end

    # identifiers_with_memberName_require_the_resource_to_have_a_shape
    v('/resources/*/identifiers/*/memberName') do |c, matches|
      resource_name = matches[1]
      shape_path = "/resources/#{resource_name}/shape"
      unless c.resources['resources'][resource_name]['shape']
        c.error("requires #{shape_path} to be set")
      end
    end

    # identifiers_with_memberName_require_the_resource_shape_to_have_that_member
    v('/resources/*/identifiers/*/memberName') do |c, matches|
      resource_name = matches[1]
      shape_path = "/resources/#{resource_name}/shape"
      shape_name = c.resources['resources'][resource_name]['shape']
      if
        shape_name &&
        c.api['shapes'][shape_name] &&
        c.api['shapes'][shape_name]['type'] == 'structure' &&
        !c.api['shapes'][shape_name]['members'].key?(c.value)
      then
        c.error("is not defined at api#/shapes/#{shape_name}/members/#{c.value}")
      end
    end

    # request_operation_must_exist
    v(%w(
      /service/actions/*/request/operation
      /service/hasMany/*/request/operation
      /resources/*/load/request/operation
      /resources/*/actions/*/request/operation
      /resources/*/batchActions/*/request/operation
      /resources/*/hasMany/*/request/operation
    )) do |c|
      unless c.api['operations'][c.value]
        c.error("is set but is not defined at api#/operations/#{c.value}")
      end
    end

    # request_accepts_input
    v(%w(
      /service/actions/*/request/params
      /service/hasMany/*/request/params
      /resources/*/load/request/params
      /resources/*/actions/*/request/params
      /resources/*/batchActions/*/request/params
      /resources/*/hasMany/*/request/params
    )) do |c|
      if operation = c.api['operations'][c.parent.parent['operation']]
        unless operation['input'] || c.value.empty?
          c.error("is set but #{operation['name']} does not accept input")
        end
      end
    end

    # request_params_target_must_resolve
    v(%w(
      /service/actions/*/request/params/*/target
      /service/hasMany/*/request/params/*/target
      /resources/*/load/request/params/*/target
      /resources/*/actions/*/request/params/*/target
      /resources/*/batchActions/*/request/params/*/target
      /resources/*/hasMany/*/request/params/*/target
    )) do |c|
      #raise NotImplementedError
    end

    # resource_paths_must_resolve_to_the_proper_shape
    v(%w(
      /service/actions/*/resource/path
      /service/hasMany/*/resource/path
      /resources/*/actions/*/resource/path
      /resources/*/batchActions/*/resource/path
      /resources/*/hasMany/*/resource/path
    )) do |c|
      type = c.parent['type']
      expected = c.resources['resources'][type]['shape']
      from = c.parent.parent['request']['operation']
      from = c.api['operations'][from]['output']
      resolved = PathResolver.new(c.api).resolve(c.value, from)
      unless expected == resolved
        c.error("must resolve to a \"#{expected}\" shape")
      end
    end

    # load_requires_shape_to_be_set
    v('/resources/*/load') do |c, matches|
      resource = matches[1]
      unless c.resources['resources'][resource]['shape']
        c.error("requires /resources/#{resource}/shape to be set")
      end
    end

    # shape_must_be_a_structure
    v('/resources/*/shape') do |c|
      shape = c.api['shapes'][c.value]
      if shape && shape['type'] != 'structure'
        c.error("must resolve to a structure")
      end
    end

    # shape_must_be_defined_in_the_api
    v('/resources/*/shape') do |c|
      unless c.api['shapes'][c.value]
        c.error("not found at api#/shapes/#{c.value}")
      end
    end

  end
end
