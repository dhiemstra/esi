# frozen_string_literal: true

require 'recursive-open-struct'

module Esi
  class Response
    extend Forwardable

    attr_reader :original_response, :call, :data
    def_delegators :original_response, :status, :body, :headers
    def_delegators :data, :each

    def initialize(response, call = nil)
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

    def normalize_results
      case response_json.class.to_s
      when 'Hash'  then normalize_entry(response_json)
      when 'Array' then response_json.map { |e| normalize_entry(e) }
      else response_json
      end
    end

    def normalize_entry(entry)
      entry.is_a?(Hash) ? hash_to_struct(entry) : entry
    end

    def hash_to_struct(hash)
      RecursiveOpenStruct.new(hash.transform_keys { |k| underscore(k).to_sym }, recurse_over_arrays: true)
    end

    def underscore(str)
      str.to_s.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
    end
  end
end
