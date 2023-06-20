# frozen_string_literal: true

require_relative "eskomsepush/version"

# EskomSePush API Wrapper Rubygem
#
# This is a Rubygem that wraps the EskomSePush API. It allows you to easily integrate the
# EskomSePush API into your Ruby applications.
#
# == Usage:
#   require 'eskomsepush_ruby'
#   esp = EskomSePush::API.new("{{token}}")
#   esp.get_quota
module EskomSePush
  # Includes
  require "faraday"
  require "uri"
  require "date"
  require "time"
  require "json"

  # Error classes
  require_relative "eskomsepush/exception"

  # Returns a new instance of API
  #
  # == Parameters:
  # token::
  #   Your API token
  # options::
  #   A hash of options
  #
  # == Returns:
  # A new instance of API
  class API
    def initialize(token, options = {})
      raise SePushError::InvalidTokenError, "Invalid token" if token.nil?

      @token = token
      @options = options
      @quota = {}

      begin
        @connection = Faraday.new("https://developer.sepush.co.za")
        @connection.headers["token"] = @token
      rescue Faraday::ConnectionFailed
        raise SePushError::UnexpectedError
      end
    end

    # Method to get your remaining API Quota/Allowance
    #
    # == Parameters:
    # None
    #
    # == Returns:
    # Response object from handle_response
    #
    def check_allowance
      response = @connection.get("/business/2.0/api_allowance")
      puts handle_response(response)
    end

    # Method to handle the responses from the API
    #
    # == Parameters:
    # response::
    #   The response object from the API
    #
    # == Returns:
    # Parsed response object. Will raise errors if the API returns an unsucessful response.
    #
    def handle_response(response)
      return UnexpectedError, "Something went wrong while parsing your response data" if response.nil?

      if response.status != 200 && !response.body["error"].nil?
        # an error most probably happened
        case response.status
        when 400
          raise SePushError::BadRequestError
        when 403
          raise SePushError::AuthenticationError
        when 404
          raise SePushError::NotFoundError
        when 408
          raise SePushError::RequestTimeoutError
        when 429
          raise SePushError::RateLimitError
          # when 5xx
        when 500..599
          raise SePushError::ServerError
        end
      elsif response.status == 200
        # success, so parse the data and make it nice and squeaky clean
        puts response.body
      else
        raise SePushError::UnexpectedError
      end
    end

    alias quota check_allowance
  end
end
