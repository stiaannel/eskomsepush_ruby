# frozen_string_literal: true

RSpec.describe EskomSePush do
  it "has a version number" do
    expect(EskomSePush::VERSION).not_to be nil
  end

  it "initializing it without a token should raise an error" do
    expect { EskomSePush::API.new(nil) }.to raise_error(EskomSePush::InvalidTokenError)
  end
end
