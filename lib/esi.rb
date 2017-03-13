require "esi/version"

module Esi
  autoload :OAuth, 'esi/o_auth'
  autoload :Calls, 'esi/calls'
  autoload :Client, 'esi/client'
  autoload :Response, 'esi/response'

  class ApiError < OAuth2::Error
    attr_reader :key, :message, :type

    def initialize(response)
      super(response.original_response)

      @code = response.original_response.status
      @key = response.json[:key]
      @message = response.json[:message]
      @type = response.json[:exceptionType]
    end
  end

  class ApiUnknownError < ApiError; end
  class ApiNotFoundError < ApiError; end
  class ApiForbiddenError < ApiError; end
  class Error < StandardError; end
end
