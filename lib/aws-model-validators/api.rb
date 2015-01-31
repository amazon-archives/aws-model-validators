require 'set'

module Aws::ModelValidators
  class Api < Validator

    # endpoint_prefix_must_be_dns_compatible
    v('/metadata/endpointPrefix') do |c|
      unless c.value.match(/^[a-z0-9][a-z0-9-]+[a-z0-9]$/)
        c.error("must be dns-compatible")
      end
    end

    # api_version_yyyy_mm_dd
    v('/metadata/apiVersion') do |c|
      unless c.value.match(/^\d{4}-\d{2}-\d{2}$/)
        c.error("must be formatted like YYYY-MM-DD")
      end
    end

    # shape_references_must_resolve
    v(%w(
      /operations/*/input/shape
      /operations/*/output/shape
      /shapes/*/members/*/shape
      /shapes/*/member/shape
      /shapes/*/key/shape
      /shapes/*/value/shape
    )) do |c|
      shape_name = c.value
      unless c.api['shapes'].key?(shape_name)
        c.error("references an undefined shape")
      end
    end

    # no_unused_shapes
    v('/shapes') do |c|

      unused_shapes = Set.new(c.value.keys)

      c.parent['operations'].values.each do |operation|
        %w(input output).each do |key|
          if ref = operation[key]
            unused_shapes.delete(ref['shape'])
          end
        end
      end

      c.value.each do |_,shape|
        case shape['type']
        when 'structure'
          shape['members'].values.each do |member|
            unused_shapes.delete(member['shape'])
          end
        when 'list'
          unused_shapes.delete(shape['member']['shape'])
        when 'map'
          unused_shapes.delete(shape['key']['shape'])
          unused_shapes.delete(shape['value']['shape'])
        end
      end

      unless unused_shapes.empty?
        c.error("contains unused shapes: #{unused_shapes.to_a.join(', ')}")
      end
    end

  end
end
