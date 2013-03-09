require 'logger'

case ENV['RACK_ENV']
when 'test'
  output = '/dev/null'
else
  output = STDERR
end

Radio::Logger = Logger.new(output)
