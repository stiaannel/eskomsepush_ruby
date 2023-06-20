# frozen_string_literal: true

module EskomSePush
  # EskomSePush Error Class, subclass from standard error to host
  # all the errors from the EskomSePush API
  class SePushError < StandardError
    # Error class that will be raised when the authtoken is invalid
    class InvalidTokenError < SePushError
      # Auth Token Error Message
      def message
        "The Auth Token you provided was invalid."
      end
    end

    # Error class that will be raised when the API returns a 429
    class RateLimitError < SePushError
      # Rate Limit Error Message
      def message
        "You have exceeded your API quota/allowance."
      end
    end

    # Error class that will be raised when the API returns a 400
    # @!scope [error] EskomSePushError
    class BadRequestError < SePushError
      # Bad Request Error Message
      def message
        "The request you sent was invalid."
      end
    end

    # Error class that will be raised when the API returns a 403
    class AuthenticationError < SePushError
      # Authentication Error Message
      def message
        "Authentication Error, Check your credentials."
      end
    end

    # Error class that will be raised when the API returns a 404
    class NotFoundError < SePushError
      # Not Found Error Message
      def message
        "The resource you requested was not found."
      end
    end

    # Error class that will be raised when the API returns a 408
    class RequestTimeoutError < SePushError
      # Request Timeout Error Message
      def message
        "The request you sent timed out."
      end
    end

    # Error class that will be raised when the API returns a 5xx error
    class ServerError < SePushError
      # Server Error Message
      def message
        "The SePush API returned a server error."
      end
    end

    # Error class that will be raised when the API returns an unexpected error
    class UnexpectedError < SePushError
      # Unexpected Error Message
      def message
        "Something went wrong while parsing your response data."
      end
    end
  end
end
