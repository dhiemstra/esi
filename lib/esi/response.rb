# frozen_string_literal: true
module Esi
  class Response
    extend Forwardable

    attr_reader :original_response, :call, :data
    def_delegators :original_response, :status, :body, :headers
    def_delegators :data, :each

    def initialize(response, call = nil)
      @original_response = response
      @data = normalize_response_body
      @call = call
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
      @response_json ||= begin
                           MultiJson.load(body, symbolize_keys: true)
                         rescue StandardError
                           {}
                         end
    end

    def save
      return unless should_log_response?
      File.write(log_directroy.join("#{Time.now.to_i}.json"), to_json)
    end

    def log_directory
      call.class.to_s.split('::').last.underscore
      dir = Pathname.new(Esi.config.response_log_path).join(call_name)
      FileUtils.mkdir_p(dir)
      dir
    end

    def should_log_response?
      return false if call.nil?
      return false if Esi.config.response_log_path.blank? || !Dir.exist?(Esi.config.response_log_path)
      true
    end

    def method_missing(method, *args, &block)
      data.send(method, *args, &block)
    end

    private

    def normalize_response_body
      MultiJson.load(body || {}, symbolize_keys: true, object_class: OpenStruct)
    end
  end
end
