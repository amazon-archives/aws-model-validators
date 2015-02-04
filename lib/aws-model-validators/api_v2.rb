require 'set'

module Aws::ModelValidators
  class ApiV2

    include Validator

    # json_protocol_metadata
    v('/metadata/protocol') do |c|
      if c.value == 'json'
        metadata = c.parent
        %w(jsonVersion targetPrefix).each do |key|
          c.error("requires /metadata/#{key} to be set") unless metadata[key]
        end
      end
    end

    # json_version_string
    v('/metadata/jsonVersion') do |c|
      supported = %w(1.0 1.1)
      unless supported.include?(c.value)
        c.error("must be one of #{supported.map(&:inspect).join(' or ')}")
      end
    end

    # target_prefix_contains_no_dot
    v('/metadata/targetPrefix') do |c|
      if c.value.match(/\.$/)
        c.error("should not contain a trailing dot")
      end
    end

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

    # missing_required_member
    v('/shapes/*/required') do |c|
      members = c.parent['members']
      c.value.each do |required|
        unless members.key?(required)
          c.error("references non-existent member `#{required}`")
        end
      end
    end

    # missing_payload_member
    v('/shapes/*/payload') do |c|
      members = c.parent['members']
      unless members.key?(c.value)
        c.error("references non-existent member `#{c.value}`")
      end
    end

    # no_unused_shapes
    v('/shapes') do |c|

      shape_map = c.value

      visited_shapes = Set.new

      c.parent['operations'].values.each do |operation|
        %w(input output).each do |key|
          if ref = operation[key]
            visit(ref, shape_map, visited_shapes)
          end
        end
        Array(operation['errors']).each do |error_ref|
          visit(error_ref, shape_map, visited_shapes)
        end
      end

      unused_shapes = c.api['shapes'].keys - visited_shapes.to_a
      unless unused_shapes.empty?
        c.error("contains unused shapes: #{unused_shapes.to_a.join(', ')}")
      end
    end

    class << self

      # recursively visited shapes from the given ref.
      def visit(ref, shapes, visited, &block)

        # terminal case for recursive shape references
        return visited if visited.include?(ref['shape'])
        visited.add(ref['shape'])

        if shape = shapes[ref['shape']]
          case shape['type']
          when 'structure'
            shape['members'].each { |_,member| visit(member, shapes, visited) }
          when 'list'
            visit(shape['member'], shapes, visited)
          when 'map'
            visit(shape['key'], shapes, visited)
            visit(shape['value'], shapes, visited)
          end
        end
        visited
      end

    end
  end
end
