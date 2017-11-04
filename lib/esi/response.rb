require 'recursive-open-struct'

module Esi
  class Response
    extend Forwardable

    attr_reader :original_response, :data
    def_delegators :original_response, :status, :body, :headers
    def_delegators :data, :each

    def initialize(response)
      @original_response = response
      @data = normalize_results
    end

    def merge(other_response)
      @data += other_response.data
      self
    end

    def to_json(pretty: true)
      MultiJson.dump(data, pretty: pretty)
    end

    def cached_until
      @cached_until ||= headers[:expires] ? Time.parse(headers[:expires]) : nil
    end

    def response_json
      @response_json ||= MultiJson.load(body, symbolize_keys: true) rescue {}
    end

    def method_missing(method, *args, &block)
      begin
        data.send(method, *args, &block)
      rescue NameError
        super(name, *args, &block)
      end
    end

    private

    def normalize_results
      response_json.is_a?(Hash) ? normalize_entry(response_json) : response_json.map { |e| normalize_entry(e) }
    end

    def normalize_entry(entry)
      entry.is_a?(Hash) ? RecursiveOpenStruct.new(entry.transform_keys { |k| underscore(k).to_sym }, recurse_over_arrays: true) : entry
    end

    def underscore(str)
      str.to_s.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase
    end
  end
end
