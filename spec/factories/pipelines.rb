FactoryBot.define do
  factory :pipeline do
    association :user
    topic { "Why small teams ship faster" }
    formats { ["tweet_thread", "linkedin_post"] }
    status { "pending" }
    tone { "professional" }

    trait :complete do
      status { "complete" }
    end

    trait :failed do
      status { "failed" }
    end
  end
end
