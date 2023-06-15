module EskomSePush
  # EskomSePush Error Class, subclass from standard error to host
  # all the errors from the EskomSePush API
  class EskomSePushError < StandardError; end

  # Error class that will be raised when the authtoken is invalid
  class InvalidTokenError < EskomSePushError; end

  # Error class that will be raised when the API returns a 429
  class RateLimitError < EskomSePushError; end 

  # Error class that will be raised when the API returns a 400
  class BadRequestError < EskomSePushError; end

  # Error class that will be raised when the API returns a 403
  class AuthenticationError < EskomSePushError; end

  # Error class that will be raised when the API returns a 404
  class NotFoundError < EskomSePushError; end

  # Error class that will be raised when the API returns a 408
  class RequestTimeoutError < EskomSePushError; end

  # Error class that will be raised when the API returns a 5xx error
  class ServerError < EskomSePushError; end

  # Error class that will be raised when the API returns an unexpected error
  class UnexpectedError < EskomSePushError; end
end