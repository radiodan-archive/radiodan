require 'logger'

class Radiodan
module Logging
  @@output = '/dev/null'
  @@level  = :DEBUG

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

  def self.level=(level)
    @@level = Logger.const_get(level.to_sym.upcase)
  end

  def self.level
    @@level
  end

  module ClassMethods
    @@logs = {}

    def logger
      unless @@logs.include? self.name
        new_log = Logger.new(Logging.output)
        new_log.progname = self.name
        new_log.level = Logging.level

        @@logs[self.name] = new_log
      end

      @@logs[self.name]
    end
  end
end
end
