# AWS Model Validators

Provides validators for the various AWS JSON model formats.

## Basic Usage

```ruby
require 'aws-model-validators'

# validating an API model
errors = Aws::ModelValidators::ApiV2.validate(api: '/path/to/api.json')

# validating a resource model requires the API and waiter models
errors = Aws::ModelValidators::ResourcesV1.new.validate(
  resources: '/path/to/resources.json',
  api: '/path/to/api.json',
  waiters: '/path/to/waiters.json'
)
```

## Supported Model Formats

| Model        | Version | Validator                          |
| ------------ - ------- ------------------------------------ |
| api          | v2      | Aws::ModelValidators::ApiV1        |
| paginators   | v1      | Aws::ModelValidators::PaginatorsV1 |
| waiters      | v2      | Aws::ModelValidators::WaitersV2    |
| resources    | v1      | Aws::ModelValidators::ResourcesV1  |

## Todo

* Finish JSON schemas for api, paginators, and waiters.
* Expand validation tests for resources

