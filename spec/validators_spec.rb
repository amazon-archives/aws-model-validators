require 'spec_helper'

module Aws
  module ModelValidators

    describe ApiV2 do
      ValidatorTestRunner.new(self, Dir.glob('spec/api_v2/*.json')).run
    end

    describe PaginatorsV1 do
      ValidatorTestRunner.new(self, Dir.glob('spec/paginators_v1/*.json')).run
    end

    describe WaitersV2 do
      ValidatorTestRunner.new(self, Dir.glob('spec/waiters_v2/*.json')).run
    end

    describe ResourcesV1 do
      ValidatorTestRunner.new(self, Dir.glob('spec/resources_v1/*.json')).run
    end

  end
end
