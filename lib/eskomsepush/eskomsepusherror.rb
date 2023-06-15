module EskomSePush
  class EskomSePushError < StandardError; end
  class InvalidTokenError < EskomSePushError; end
  class RateLimitError < EskomSePushError; end 
  class BadRequestError < EskomSePushError; end
  class AuthenticationError < EskomSePushError; end
  class NotFoundError < EskomSePushError; end
  class RequestTimeoutError < EskomSePushError; end
  class ServerError < EskomSePushError; end
  class UnexpectedError < EskomSePushError; end
end