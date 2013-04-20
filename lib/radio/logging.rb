require 'logger'

class Radio
module Logging
  def self.included(klass)
    klass.extend ClassMethods
  end

  def logger
    self.class.logger
  end

  module ClassMethods
    def logger
      @@logs ||= {}
      
      unless @@logs.include? self.name
        case ENV['RACK_ENV']
        when 'test'
          output = '/dev/null'
        else
          output = STDERR
        end
        
        new_log = Logger.new(output)
        new_log.progname = self.name
        
        @@logs[self.name] = new_log
      end
      
      @@logs[self.name]
    end
  end
end
end
