module Esi
  class Response
    extend Forwardable

    attr_reader :original_response, :data
    def_delegators :original_response, :status, :body, :headers

    def initialize(response)
      @original_response = response
      @data = MultiJson.load(body, symbolize_keys: true) rescue {}
      @data = normalize_keys(@data) if @data.is_a?(Hash)
    end

    def to_s
      MultiJson.dump(json, pretty: true)
    end

    private

    def normalize_keys(data)
      data.dup.each_key { |k| data[underscore(k).to_sym] = data.delete(k) }
      data
    end

    def underscore(str)
      str.to_s.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase
    end
  end
end
