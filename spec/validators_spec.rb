require 'spec_helper'

module Aws
  module ModelValidators

    describe Api do
      ValidatorTestRunner.new(self, Dir.glob('spec/api/*.json')).run
    end

    describe Paginators do
      ValidatorTestRunner.new(self, Dir.glob('spec/paginators/*.json')).run
    end

    describe Waiters do
      ValidatorTestRunner.new(self, Dir.glob('spec/waiters/*.json')).run
    end

    describe Resources do
      ValidatorTestRunner.new(self, Dir.glob('spec/resources/*.json')).run
    end

  end
end
