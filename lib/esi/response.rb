require 'recursive-open-struct'

module Esi
  class Response
    extend Forwardable

    attr_reader :original_response, :call, :data
    def_delegators :original_response, :status, :body, :headers
    def_delegators :data, :each

    def initialize(response, call=nil)
      @original_response = response
      @call = call
      @data = normalize_results
    end

    def merge(other_response)
      @data += other_response.data
      self
    end

    def to_h
      data.is_a?(Array) ? data.map { |e| e.try(:to_h) || e } : e.to_h
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

    def save
      return if call.nil?
      return if Esi.config.response_log_path.blank? || !Dir.exists?(Esi.config.response_log_path)

      call_name = call.class.to_s.split('::').last.underscore
      folder = Pathname.new(Esi.config.response_log_path).join(call_name)
      FileUtils.mkdir_p(folder)
      File.write(folder.join("#{Time.now.to_i.to_s}.json"), to_json)
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
