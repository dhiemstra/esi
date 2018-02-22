# frozen_string_literal: true

module Esi
  # ApiError base class
  # @!attribute [r] response
  #  @return [Esi::Response] the ApiError Response
  # @!attribute [r] key
  #  @return [String] the response.data[:key]
  # @!attribute [r] message
  #  @return [String] the response error message
  # @!attribute [r] type
  #  @return [String] the response.data[:exceptionType]
  # @!attribute [r] original_exception
  #  @return [ExceptionClass|nil] the orginal raised exception
  class ApiError < OAuth2::Error
    attr_reader :response, :key, :message, :type, :original_exception

    # Create a new instance of ApiError
    # @param [Esi::Response] response the response that generated the exception
    # @param [ExceptionClass|nil] the orginally raised exception
    # @return [Esi::ApiError] an instance of ApiError
    def initialize(response, original_exception = nil)
      super(response.original_response)

      @response = response
      @original_exception = original_exception
      @code = response.original_response.status
      @key = response.data[:key]
      @message = response.data[:message].presence || response.data[:error] || original_exception.try(:message)
      @type = response.data[:exceptionType]
    end
  end

  # ApiRequestError Class
  # @!attribute [r] original_exception
  #  @return [ExceptionClass|nil] the orginal raised exception
  class ApiRequestError < StandardError
    attr_reader :original_exception

    # Create a new instance of ApiRequestError
    # @param [ExceptionClass|nil] the orginally raised exception
    # @return [Esi::ApiRequestError] the instance of ApiRequestError
    def initialize(original_exception)
      @original_exception = original_exception
      msg = "#{original_exception.class}: " \
      "#{original_exception.try(:response).try(:status)}" \
      ' - ' \
      "#{original_exception.try(:message)}"
      super(msg)
    end
  end

  # ApiUnknowntError Class
  # @!attribute [r] response
  #  @return [Esi::Response] the ApiError Response
  # @!attribute [r] key
  #  @return [String] the response.data[:key]
  # @!attribute [r] message
  #  @return [String] the response error message
  # @!attribute [r] type
  #  @return [String] the response.data[:exceptionType]
  # @!attribute [r] original_exception
  #  @return [ExceptionClass|nil] the orginal raised exception
  class ApiUnknownError < ApiError; end

  # ApiBadRequestError Class
  # @!attribute [r] response
  #  @return [Esi::Response] the ApiError Response
  # @!attribute [r] key
  #  @return [String] the response.data[:key]
  # @!attribute [r] message
  #  @return [String] the response error message
  # @!attribute [r] type
  #  @return [String] the response.data[:exceptionType]
  # @!attribute [r] original_exception
  #  @return [ExceptionClass|nil] the orginal raised exception
  class ApiBadRequestError < ApiError; end

  # ApiRefreshTokenExpiredError Class
  # @!attribute [r] response
  #  @return [Esi::Response] the ApiError Response
  # @!attribute [r] key
  #  @return [String] the response.data[:key]
  # @!attribute [r] message
  #  @return [String] the response error message
  # @!attribute [r] type
  #  @return [String] the response.data[:exceptionType]
  # @!attribute [r] original_exception
  #  @return [ExceptionClass|nil] the orginal raised exception
  class ApiRefreshTokenExpiredError < ApiError; end

  # ApiInvalidAppClientKeysError Class
  # @!attribute [r] response
  #  @return [Esi::Response] the ApiError Response
  # @!attribute [r] key
  #  @return [String] the response.data[:key]
  # @!attribute [r] message
  #  @return [String] the response error message
  # @!attribute [r] type
  #  @return [String] the response.data[:exceptionType]
  # @!attribute [r] original_exception
  #  @return [ExceptionClass|nil] the orginal raised exception
  class ApiInvalidAppClientKeysError < ApiError; end

  # ApiNotFoundError Class
  # @!attribute [r] response
  #  @return [Esi::Response] the ApiError Response
  # @!attribute [r] key
  #  @return [String] the response.data[:key]
  # @!attribute [r] message
  #  @return [String] the response error message
  # @!attribute [r] type
  #  @return [String] the response.data[:exceptionType]
  # @!attribute [r] original_exception
  #  @return [ExceptionClass|nil] the orginal raised exception
  class ApiNotFoundError < ApiError; end

  # ApiForbiddenError Class
  # @!attribute [r] response
  #  @return [Esi::Response] the ApiError Response
  # @!attribute [r] key
  #  @return [String] the response.data[:key]
  # @!attribute [r] message
  #  @return [String] the response error message
  # @!attribute [r] type
  #  @return [String] the response.data[:exceptionType]
  # @!attribute [r] original_exception
  #  @return [ExceptionClass|nil] the orginal raised exception
  class ApiForbiddenError < ApiError; end

  # Error Class
  # @see [StandardError](https://ruby-doc.org/core-2.3.2/StandardError.html)
  class Error < StandardError; end
end
