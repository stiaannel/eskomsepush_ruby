# frozen_string_literal: true

module EskomSePush
  # EskomSePush Error Class, subclass from StandardError to host
  # all the errors from the EskomSePush API
  class EskomSePushError < StandardError
    # Error class that will be raised when the auth token is invalid
    class InvalidTokenError < EskomSePushError
      def message
        "The Auth Token you provided was invalid."
      end
    end

    # Error class that will be raised when the API returns a 429
    # Implying that you have been rate limited, or you have exceeded
    # your API quota/allowance
    class RateLimitError < EskomSePushError
      def message
        "You have exceeded your API quota/allowance."
      end
    end

    # Error class that will be raised when the API returns a 400
    # Implying that the request you sent was invalid
    class BadRequestError < EskomSePushError
      def message
        "The request you sent was invalid."
      end
    end

    # Error class that will be raised when the API returns a 403
    # Implying that the request you sent was not authenticated.
    # Check your API token. And ensure it is valid during initialization.
    class AuthenticationError < EskomSePushError
      def message
        "Authentication Error, check your credentials."
      end
    end

    # Error class that will be raised when the API returns a 404
    # Implying that the resource you requested was not found.
    # Check the URL you are trying to access.
    class NotFoundError < EskomSePushError
      def message
        "The resource you requested was not found."
      end
    end

    # Error class that will be raised when the API returns a 408
    # Implying that the request you sent timed out.
    class RequestTimeoutError < EskomSePushError
      def message
        "The request you sent timed out."
      end
    end

    # Error class that will be raised when the API returns a 5xx error
    # Implying that the API returned a server error and you should try again later.
    class ServerError < EskomSePushError
      def message
        "The SePush API returned a server error."
      end
    end

    # Error class that will be raised for unexpected errors
    # Implying that something went wrong while parsing the response data.
    class UnexpectedError < EskomSePushError
      def message
        "Something went wrong while parsing your response data."
      end
    end
  end
end
