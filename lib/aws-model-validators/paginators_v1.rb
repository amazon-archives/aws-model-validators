module Aws::ModelValidators
  class PaginatorsV1

    include Validator

    v('/pagination') do |c|
      puts c.value.inspect
    end

    # unknown_operation
    v('/pagination/*') do |c, matches|
      name = matches[1]
      unless c.api['operations'].key?(name)
        c.error("references operation not found at api#/operations/#{name}")
      end
    end

    # valid_tokens
    v(%w(
      /pagination/*/input_token
    )) do |c|
      puts c.path
    end

  end
end
