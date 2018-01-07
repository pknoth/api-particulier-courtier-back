FactoryGirl.define do
  factory :field do
    trait :with_enrollment do
      fieldable { FactoryGirl.create(:enrollment) }
    end

    trait :section do
      type 'Field::Section'
    end

    trait :boolean do
      type 'Field::Boolean'
    end

    trait :string do
      type 'Field::String'
    end

    trait :json do
      type 'Field::Json'
    end

    trait :agreement do
      boolean

      name 'agreement'
      description 'Agreement'
    end

    trait :applicant do
      json

      name 'applicant'
      description 'Applicant'
    end
  end
end
