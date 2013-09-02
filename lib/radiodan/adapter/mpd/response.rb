require 'logging'
require_relative 'ack'

class Radiodan
  class MPD
  class Response
    include Logging
    attr_accessor :value, :string
    alias_method  :to_s, :string
    
    MULTILINE_COMMANDS = %w{playlistinfo search find}
    
    def initialize(response_string, command=nil)
      @string  = response_string
      @command = command
      @value   = parse(@string, @command)
            
      if ack?
        logger.error "ACK #{@command}, #{@value.inspect}"
        raise AckError, @value.description
      end
    end
    
    def ack?
      value.is_a?(Ack)
    end
    
    def ==(other)
      self.value == other
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
        Ack.new(response)
      when response.split.size == 1
        # set value -> value
        Hash[*(response.split.*2)]
      when MULTILINE_COMMANDS.include?(command.split.first)
        # create array of hash values
        parse_multiline(response)
      else
        split = split_response(response).flatten
        Hash[*split]
      end
    end
    
    def parse_multiline(response)
      multiline = []
      values = {}
      
      split_response(response) do |key, value|
        if key == 'file' && values.has_key?('file')
          multiline << values
          values = {}
        end
                
        values[key] = value
      end
      
      multiline << values
    end
    
    def split_response(response)
      response = response.split("\n")
      
      response.collect do |r| 
        # remove "OK" responses
        next if r == 'OK'
        
        split = r.split(':')
        key   = split.shift.strip
        value = split.join(':').strip
        
        yield(key, value) if block_given?
        
        [key, value]
      end.compact
    end
  end
end
end
