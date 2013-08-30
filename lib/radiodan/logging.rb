require 'logger'

class Radiodan
module Logging
  @@output = '/dev/null'
  
  def self.included(klass)
    klass.extend ClassMethods
  end
  
  def self.output=(output)
    @@output = output
    STDOUT.sync = true if @@output == STDOUT
  end
  
  def self.output
    @@output
  end

  def logger
    self.class.logger
  end

  module ClassMethods    
    @@logs = {}
    
    def logger
      unless @@logs.include? self.name
        new_log = Logger.new(Logging.output)
        new_log.progname = self.name
        
        @@logs[self.name] = new_log
      end
      
      @@logs[self.name]
    end
  end
end
end
