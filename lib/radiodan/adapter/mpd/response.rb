require_relative 'ack'

class Radiodan::MPD
  class Response
    attr_accessor :value, :string
    alias_method  :to_s, :string
    
    MULTILINE_COMMANDS = %w{playlistinfo}
    
    def initialize(response_string, command=nil)
      @string = response_string
      @command = command
    end
    
    def value
      @value ||= parse(@string, @command)
    end
    
    def is_ack?
      value.is_a?(Ack)
    end
    
    def method_missing(method, *args, &block)
      if value.respond_to?(method)
        value.send(method, *args, &block)
      else
        super
      end
    end
    
    def respond_to?(method)
      if value.respond_to?(method)
        true
      else
        super
      end
    end
    
    private
    
    # returns true, ACK or formatted values
    def parse(response, command)
      case
      when response == 'OK'
        true
      when response =~ /^ACK/
        parse_ack(response)
      when response.split.size == 1
        # set value -> value
        Hash[*(response.split.*2)]
      when MULTILINE_COMMANDS.include?(command)
        # create array of hash values
        parse_multiline(response)
      else
        split = split_response(response).flatten
        Hash[*split]
      end
    end
    
    def parse_ack(response)
      ack = Ack.new(response)
      logger.warn ack
    
      ack
    end
    
    def parse_multiline(response)
      multiline = []
      values = {}
      
      split_response(response) do |key, value|
        if values.include?(key)
          multiline << values
          values = {}
        end
        
        values[key] = value
      end
      
      multiline << values
    end
    
    def split_response(response)
      response = response.split("\n")
      # remove first response: "OK"
      response.pop
      
      response.collect do |r| 
        split = r.split(':')
        key   = split.shift.strip
        value = split.join(':').strip
        
        yield(key, value) if block_given?
        
        [key, value]
      end
    end
  end
end
