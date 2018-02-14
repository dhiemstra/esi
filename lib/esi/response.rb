module Esi
  class Response
    extend Forwardable

    attr_reader :original_response, :call, :data
    def_delegators :original_response, :status, :body, :headers
    def_delegators :data, :each

    def initialize(response, call=nil)
      @original_response = response
      @call = call
      @data = MultiJson.load(body || {}, symbolize_keys: true, object_class: OpenStruct) # rescue OpenStruct.new
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

    def save
      return if call.nil?
      return if Esi.config.response_log_path.blank? || !Dir.exists?(Esi.config.response_log_path)

      call_name = call.class.to_s.split('::').last.underscore
      folder = Pathname.new(Esi.config.response_log_path).join(call_name)
      FileUtils.mkdir_p(folder)
      File.write(folder.join("#{Time.now.to_i.to_s}.json"), to_json)
    end

    def method_missing(method, *args, &block)
      data.send(method, *args, &block)
    end
  end
end
