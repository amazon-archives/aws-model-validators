require 'simplecov'
require 'rspec'
require 'aws-model-validators'

class ValidatorTestRunner

  include Aws::ModelValidators::LoadJson

  def initialize(group, test_cases)
    @group = group
    @test_cases = test_cases
    raise ArgumentError, "no test cases given"  if test_cases.empty?
  end

  # Allows executing a limited set of validator specs by specifing
  # a pattern the test must match.
  #
  #     $ TEST_CASE=pattern bundle exec rspec spec/validator_spec.rb
  #
  # Any test files in spec/validator/*.json where the basename matches
  # the given pattern will be executed.
  def run
    @test_cases.each do |path|
      next if ENV['TEST_CASE'] && !File.basename(path).match(ENV['TEST_CASE'])

      load_json(path).tap do |test_case|

        models = test_case.inject({}) { |h,(k,v)| h[k.to_sym] = v; h }
        models.delete(:errors)

        @group.it(File.basename(path[0..-6])) do
          pending unless test_case['errors']
          errors = described_class.new.validate(models)
          unless errors == test_case['errors']
            expected = test_case['errors'].map { |e| Regexp.new(Regexp.escape(e)) }
            expect(errors).to match(expected)
          end
        end

      end
    end
  end

end
