module Aws::ModelValidators
  class WaitersV2

    include Validator

    # unknown_operation
    v('/waiters/*/operation') do |c|
      unless c.api['operations'].key?(c.value)
        c.error("references operation not defined at api#/operations/#{c.value}")
      end
    end

  end
end
