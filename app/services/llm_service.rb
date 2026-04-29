# frozen_string_literal: true

# this service is called by a content generation job
class LlmService
  # wraps Anthropic API call
  # takes format + topic
  # returns generated text
  API_URL = "https://api.anthropic.com/v1/messages".freeze
  MODEL = "claude-haiku-4-5".freeze

  def initialize(format:, topic:, tone: "professional")
    @format = format
    @topic = topic
    @tone = tone
  end

  def call
    prompt = Prompts::PROMPTS[@format]
    raise ArgumentError, "Unknown format: #{@format}" unless prompt

    prompt = "#{prompt} Use a #{@tone} tone."

    # URL, headers:, body:
    response = HTTParty.post(API_URL, headers: {
      "content-type" => "application/json",
      "anthropic-version" => "2023-06-01",
      "x-api-key" => ENV["ANTHROPIC_API_KEY"]
    }, body: {
      model: MODEL,
      max_tokens: 1024,
      system: prompt,
      messages: [
        {
          role: "user",
          content: "Topic: #{@topic}"
        }
      ]
    }.to_json
    )
    raise StandardError, "API Error: #{response.code}" unless response.success?
    response.parsed_response.dig("content", 0, "text")
  end
end
