module Aws::ModelValidators
  class PaginatorsV1

    include Validator

    # unknown_operation
    v('/pagination/*') do |c, matches|
      name = matches[1]
      unless c.api['operations'].key?(name)
        c.error("references operation not found at api#/operations/#{name}")
      end
    end

    # valid_tokens
    v(%w(
      /pagination/*/limit_key
      /pagination/*/input_token
      /pagination/*/output_token
      /pagination/*/more_results
      /pagination/*/result_key
    )) do |c, matches|
      if operation = c.api['operations'][matches[1]]
        key = c.path.split('/').last
        mode = %w(limit_key input_token).include?(key) ? 'input' : 'output'
        if Array === c.value
          c.children.each do |context|
            unless PathResolver.new(c.api).resolve(context.value, operation[mode])
              context.error("does not resolve")
            end
          end
        else
          unless PathResolver.new(c.api).resolve(c.value, operation[mode])
            c.error("does not resolve")
          end
        end
      end
    end

  end
end
