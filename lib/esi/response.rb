require 'recursive-open-struct'

module Esi
  class Response
    extend Forwardable

    attr_reader :original_response, :json
    def_delegators :original_response, :status, :body, :headers

    def initialize(response)
      @original_response = response
      @json = MultiJson.load(body, symbolize_keys: true) rescue {}
      @json = normalize_keys(@json) if @json.is_a?(Hash)
    end

    def data
      @data ||= begin
        if @json.is_a?(Array)
          @json[0].is_a?(Hash) ? @json.map { |e| RecursiveOpenStruct.new(e, recurse_over_arrays: true) } : @json
        else
          RecursiveOpenStruct.new(@json, recurse_over_arrays: true)
        end
      end
    end

    def to_s
      MultiJson.dump(json, pretty: true)
    end

    def cached_until
      original_response.headers[:expires] ? Time.parse(original_response.headers[:expires]) : nil
    end

    def method_missing(method, *args, &block)
      begin
        data.send(method, *args, &block)
      rescue NameError
        super(name, *args, &block)
      end
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
