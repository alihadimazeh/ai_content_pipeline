require "rails_helper"

RSpec.describe LlmService do
  describe "call" do
    it "raises an ArgumentError for an unknown format" do
      service = LlmService.new(format: "UnknownFormat", topic: "testing", tone: "professional")
      expect { service.call }.to raise_error(ArgumentError)
    end

    it "returns the generated response on success" do
      stub_request(:post, LlmService::API_URL).to_return(
        status: 200,
        body: { "content" => [{ "text" => "Generated content" }] }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

      service = LlmService.new(format: "tweet_thread", topic: "testing", tone: "professional")
      puts service.inspect
      expect(service.call).to eq("Generated content")
    end

    it 'raises an error if the response is not successful' do
      stub_request(:post, LlmService::API_URL).to_return(status: 500, body: "Internal Server Error")

      service = LlmService.new(format: "tweet_thread", topic: "testing", tone: "professional")
      expect { service.call }.to raise_error(StandardError)
    end
  end
end
