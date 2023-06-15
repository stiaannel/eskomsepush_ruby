# frozen_string_literal: true

require_relative "eskomsepush/version"

module EskomSePush
  class Error < StandardError; end
  # Your code goes here...
  
  class SePushError < StandardError;

  class InvalidTokenError < SePushError;

  class API
    def initialize(token)
      @token = token
    end

    def get_quota
      raise InvalidTokenError, "You haven't passed your API Token." if @token.nil?
    end
  end
end
