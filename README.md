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
| ------------ | ------- | ---------------------------------- |
| api          | v2      | Aws::ModelValidators::ApiV1        |
| paginators   | v1      | Aws::ModelValidators::PaginatorsV1 |
| waiters      | v2      | Aws::ModelValidators::WaitersV2    |
| resources    | v1      | Aws::ModelValidators::ResourcesV1  |

## Todo

* Finish JSON schemas for api, paginators, and waiters.
* Expand validation tests for resources

## License

This library is distributed under the
[apache license, version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)

```no-highlight
copyright 2015. amazon web services, inc. all rights reserved.

licensed under the apache license, version 2.0 (the "license");
you may not use this file except in compliance with the license.
you may obtain a copy of the license at

    http://www.apache.org/licenses/license-2.0

unless required by applicable law or agreed to in writing, software
distributed under the license is distributed on an "as is" basis,
without warranties or conditions of any kind, either express or implied.
see the license for the specific language governing permissions and
limitations under the license.
```
