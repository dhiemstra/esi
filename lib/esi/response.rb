module Esi
  class Response
    extend Forwardable

    attr_reader :original_response, :data
    def_delegators :original_response, :status, :body, :headers

    def initialize(response)
      @original_response = response
      @data = MultiJson.load(body, symbolize_keys: true) rescue {}
    end

    def to_s
      MultiJson.dump(json, pretty: true)
    end
  end
end
