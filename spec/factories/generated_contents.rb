FactoryBot.define do
  factory :generated_content do
    association :pipeline
    format { "tweet_thread" }
    body { "" }
    status { "pending" }
    version { 1 }

    trait :complete do
      body { "Generated tweet thread content" }
      status { "complete" }
    end

    trait :failed do
      status { "failed" }
    end
  end
end
