require 'simplecov'
require 'rspec'
require 'aws-model-validators'

class ValidatorTestRunner

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
    runner = self
    @test_cases.each do |path|
      next if ENV['TEST_CASE'] && !File.basename(path).match(ENV['TEST_CASE'])

      Aws::ModelValidators.load_json(path).tap do |test_case|

        models = test_case.inject({}) { |h,(k,v)| h[k.to_sym] = v; h }
        errors = models.delete(:errors)

        @group.it(File.basename(path[0..-6])) do
          pending unless errors
          results = described_class.new.validate(models, apply_schema: false)
          unless runner.results_match?(results, errors)
            expect(results).to eq(errors)
          end
        end

      end
    end
  end

  def results_match?(results, expected)
    expected.each.with_index do |pattern, i|
      unless results[i].to_s.match(Regexp.escape(pattern))
        return false
      end
    end
    true
  end

end
