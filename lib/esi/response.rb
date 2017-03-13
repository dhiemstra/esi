module Esi
  class Response
    attr_reader :original_response, :json, :items, :pages, :total, :next

    delegate :status, :body, :headers, to: :original_response

    def initialize(response)
      @original_response = response
      @json = MultiJson.load(body, symbolize_keys: true) rescue {}
      @items = json
    end

    def to_s
      MultiJson.dump(json, pretty: true)
    end
  end
end
