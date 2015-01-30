Gem::Specification.new do |spec|
  spec.name          = 'aws-model-validators'
  spec.version       = File.read(File.join(File.dirname(__FILE__), 'VERSION'))
  spec.summary       = 'AWS Model Validators.'
  spec.description   = 'Validates AWS API, paginator, waiters, and resource models.'
  spec.author        = 'Amazon Web Services'
  spec.homepage      = 'http://github.com/aws/aws-model-validators'
  spec.license       = 'Apache 2.0'
  spec.require_paths = ['lib']
  spec.files         = ['VERSION'] + Dir['lib/**/*.rb'] + Dir['schemas/*.json']
  spec.add_dependency('json', '~> 1')
  spec.add_dependency('json-schema', '~> 2.5')
end
