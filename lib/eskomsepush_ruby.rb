# frozen_string_literal: true

require_relative "eskomsepush/version"

# EskomSePush API Wrapper Rubygem
#
# This is a Rubygem that wraps the EskomSePush API. It allows you to easily integrate the EskomSePush API into your Ruby applications.
#
# == Usage:
#   require 'eskomsepush_ruby'
#   esp = EskomSePush::API.new("{{token}}")
#   esp.get_quota
module EskomSePush
  # Includes
  require 'net/http'
  require 'uri'
  require 'date'
  require 'time'
  require 'json'

  # Error classes  
  require_relative "eskomsepush/eskomsepusherror"

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
      raise InvalidTokenError, "Invalid token" if token.nil?
      @token = token
      @options = options
      @quota = {}
    end

    # Method to get your remaining API Quota/Allowance
    #
    # == Parameters:
    # None
    #
    # == Returns:
    # Response object from handle_response
    #
    def get_quota
      url = URI("https://developer.sepush.co.za/business/2.0/api_allowance")
      
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      
      request = Net::HTTP::Post.new(url)
      request["token"] = @token
      
      response = https.request(request)
      handle_response(response)
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
      return UnexpectedError, "Something went wrong while parsing your response data" if response.body.nil?

      res = JSON.parse(response.body, symbolize_names: true)
      if response.code != "200" && !res[:error].nil?
        # an error most probably happened
        error_message = " : #{res[:error]}"
        case response.code
        when "400"
          raise BadRequestError, "Bad Request#{error_message}"
        when "403"
          raise AuthenticationError, "Authentication error#{error_message}"
        when "404"
          raise NotFoundError, "Not found#{error_message}"
        when "408"
          raise RequestTimeoutError, "Request timeout#{error_message}"
        when "429"
          raise RateLimitError, "Rate limit exceeded#{error_message}"
          # when 5xx
        when "500".."599"
          raise ServerError, "The SePush API returned a server error #{error_message}"
        end
      elsif response.code == "200"
        # success, so parse the data and make it nice and squeaky clean
        return res
      else
        raise UnexpectedError, "Received an unexpected response code from the API server: #{response.code}"
      end
    end
  end
end
