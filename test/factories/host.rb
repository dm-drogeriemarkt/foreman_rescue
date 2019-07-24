FactoryBot.modify do
  factory :host do
    trait :rescue_mode do
      rescue_mode { true }
    end
  end
end
