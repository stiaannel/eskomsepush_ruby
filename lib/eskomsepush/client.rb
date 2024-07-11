# Includes
require "faraday"
require "uri"
require "date"
require "time"
require "json"
require "ostruct"

# Error classes
require_relative "exception"

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
module EskomSePush
  class Client
    def initialize(token, options = {})
      raise EskomSePushError::InvalidTokenError, "Invalid token" if token.nil?

      @token = token
      @options = options
      @quota = {}

      begin
        @connection = Faraday.new("https://developer.sepush.co.za")
        @connection.headers["token"] = @token
      rescue Faraday::ConnectionFailed
        raise EskomSePushError::UnexpectedError
      end
    end

    # Method to get your remaining API Quota/Allowance
    #
    # == Parameters:
    # None
    #
    # == Returns:
    # OpenStruct object with the quota information
    #
    def check_allowance
      response = @connection.get("/business/2.0/api_allowance")
      handle_response(response)
    end

    # Method to get the current status of the Eskom Loadshedding
    #
    # == Parameters:
    # None
    def status
      response = @connection.get("/business/2.0/status")
      handle_response(response)
    end

    # Search for the areaID of a specific area
    #
    # == Parameters:
    # text::
    #   The name of the area you want to search for
    #
    # == Returns:
    # Response object from handle_response
    def areas_search(text = nil)
      raise EskomSePushError::BadRequestError if text.nil?

      response = @connection.get("/business/2.0/areas_search?text=#{text}")
      puts response
      handle_response(response)
    end

    # Get the area information for a specific area
    #
    # == Parameters:
    # area_id::String
    #   The areaID of the area you want to get information for
    # test::String
    #   Whether you would like to use test data or not, valid options
    #   are current and future
    def area_information(area_id = nil, _test = nil)
      raise EskomSePushError::BadRequestError if area_id.nil?

      response = @connection.get("/business/2.0/area?id=#{area_id}&test=current")
      handle_response(response)
    end

    # Get a list of all nearby areas
    #
    # == Parameters:
    # lat::String
    #   The latitude of the area you want to get nearby areas for
    # long::String
    #   The longitude of the area you want to get nearby areas for
    #
    # == Returns:
    # Response object from handle_response
    def areas_nearby(lat = nil, long = nil)
      raise EskomSePushError::BadRequestError if lat.nil? || long.nil?

      response = @connection.get("/business/2.0/areas_nearby?lat=#{lat}&long=#{long}")
      handle_response(response)
    end

    # Get a list of all nearby topics
    #
    # == Parameters:
    # lat::String
    #   The latitude of the area you want to get nearby topics for
    # long::String
    #   The longitude of the area you want to get nearby topics for
    #
    # == Returns:
    # Response object from handle_response
    def topics_nearby(lat = nil, long = nil)
      raise EskomSePushError::BadRequestError if lat.nil? || long.nil?

      response = @connection.get("/business/2.0/topics_nearby?lat=#{lat}&long=#{long}")
      handle_response(response)
    end

    private

    # Private Method to handle the responses from the API
    #
    # == Parameters:
    # response::
    #   The response object from the API
    #
    # == Returns:
    # Parsed response object. Will raise errors if the API returns an unsucessful response.
    #
    def handle_response(response)
      return EskomSePushError::UnexpectedError if response.nil?

      if response.status != 200 || response.body["error"]
        case response.status
        when 400
          raise EskomSePushError::BadRequestError
        when 403
          raise EskomSePushError::AuthenticationError
        when 404
          raise EskomSePushError::NotFoundError
        when 408
          raise EskomSePushError::RequestTimeoutError
        when 429
          raise EskomSePushError::RateLimitError
        when 500..599
          raise EskomSePushError::ServerError
        else
          raise EskomSePushError::UnexpectedError
        end
      else
        JSON.parse(response.body, object_class: OpenStruct)
      end
    end

    alias quota check_allowance
  end
end
