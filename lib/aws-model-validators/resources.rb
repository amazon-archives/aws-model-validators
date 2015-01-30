module Aws::ModelValidators
  class Resources < Validator

    # TODO: has_many_request_params_may_not_be_input
    # TODO: service_has_resource_identifiers_must_be_input_or_literal
    # TODO: service_request_params_must_be_literals
    # TODO: service_has_resource_path_not_permitted
    # TODO: resource_load_path resolves
    # TODO: resource_has_path_resolves

    # identifiers_may_not_be_prefixed_by_their_resource_name
    v('#/resources/(\w+)/identifiers/\d+/name') do |c, matches|
      resource_name = matches[1]
      if c.value.match(/^#{resource_name}/)
        c.error("must not be prefixed with '#{resource_name}'")
      end
    end

    # identifiers_must_have_unique_names
    v('#/resources/\w+/identifiers') do |c|
      names = c.value.map { |v| v['name'] }
      unless names.uniq == names
        c.error("must have unique names")
      end
    end

    # identifiers_with_memberName_require_the_resource_to_have_a_shape
    v('#/resources/(\w+)/identifiers/(\d+)/memberName') do |c, matches|
      resource_name = matches[1]
      shape_path = "#/resources/#{resource_name}/shape"
      unless c.model(:resources)['resources'][resource_name]['shape']
        c.error("requires #{shape_path} to be set")
      end
    end

    # identifiers_with_memberName_require_the_resource_shape_to_have_that_member
    v('#/resources/(\w+)/identifiers/(\d+)/memberName') do |c, matches|
      resource_name = matches[1]
      shape_path = "#/resources/#{resource_name}/shape"
      shape_name = c.model(:resources)['resources'][resource_name]['shape']
      if
        shape_name &&
        c.model(:api)['shapes'][shape_name] &&
        c.model(:api)['shapes'][shape_name]['type'] == 'structure' &&
        !c.model(:api)['shapes'][shape_name]['members'].key?(c.value)
      then
        c.error("is not defined at api#/shapes/#{shape_name}/members/#{c.value}")
      end
    end

    # request_operation_must_exist
    v(*%w(
      #/service/actions/\w+/request/operation
      #/service/hasMany/\w+/request/operation
      #/resources/\w+/load/request/operation
      #/resources/\w+/actions/\w+/request/operation
      #/resources/\w+/batchActions/\w+/request/operation
      #/resources/\w+/hasMany/\w+/request/operation
    )) do |c|
      unless c.model(:api)['operations'][c.value]
        c.error("is set but is not defined at api#/operations/#{c.value}")
      end
    end

    # request_params_target_must_resolve
    v(*%w(
      #/service/actions/\w+/request/params
      #/service/hasMany/\w+/request/params
      #/resources/\w+/load/request/params
      #/resources/\w+/actions/\w+/request/params
      #/resources/\w+/batchActions/\w+/request/params
      #/resources/\w+/hasMany/\w+/request/params
    )) do |c|
      #raise NotImplementedError
    end

    # resource_paths_must_resolve_to_the_proper_shape
    v(*%w(
      #/service/actions/\w+/resource/path
      #/service/hasMany/\w+/resource/path
      #/resources/\w+/actions/\w+/resource/path
      #/resources/\w+/batchActions/\w+/resource/path
      #/resources/\w+/hasMany/\w+/resource/path
    )) do |c|
      type = c.parent['type']
      from = c.parent.parent['request']['operation']
      from = c.model(:api)['operations'][from]['output']
      expected = c.model(:resources)['resources'][type]['shape']
      resolved = PathResolver.new(c.model(:api)).resolve(c.value, from)
      unless expected == resolved
        c.error("must resolve to a \"#{expected}\" shape")
      end
    end

    # load_requires_shape_to_be_set
    v('#/resources/(\w+)/load') do |c, matches|
      resource = matches[1]
      unless c.model(:resources)['resources'][resource]['shape']
        c.error("requires #/resources/#{resource}/shape to be set")
      end
    end


    # shape_must_be_a_structure
    v('#/resources/\w+/shape') do |c|
      shape = c.model(:api)['shapes'][c.value]
      if shape && shape['type'] != 'structure'
        c.error("must resolve to a structure")
      end
    end

    # shape_must_be_defined_in_the_api
    v('#/resources/\w+/shape') do |c|
      unless c.model(:api)['shapes'][c.value]
        c.error("not found at api#/shapes/#{c.value}")
      end
    end

  end
end
