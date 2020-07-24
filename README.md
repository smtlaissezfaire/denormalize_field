
# denormalize_field

Easily Denormalize fields and associations without writing lots of custom before_validations_

## Examples:

Denormalizing a field:

```

class ApplicationRecord < ActiveRecord::Base
  self.base_class = true

  include DenormalizeField
end

class Employer < ApplicationRecord
  validate_presence_of :name
end

class Employee < ApplicationRecord
  validate_presence_of :employer_name

  denormalize_field :employer, :name
  # or:
  # denormalize_field :employer, :name, :target_field => :employer_name
end
```

Denormalizing an association:

```
class Survey < ApplicationRecord
  include MongoMapper::Document

  has_many :survey_questions
  has_many :survey_responses
end

class SurveyQuestion < ApplicationRecord
  belongs_to :survey
end

class SurveyResponseOption < ApplicationRecord
  belongs_to :survey
  belongs_to :survey_question

  denormalize_association :survey, :from => :survey_question
end
```

### Thanks

This was taken from git@github.com:smtlaissezfaire/denormalize_mm.git.

Thanks @pariser.

### For Internal Devs:

Setup:

```
bundle
rake db:create
rake db:migrate
rspec spec
```
