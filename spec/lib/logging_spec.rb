require 'spec_helper'
require 'logging'

describe Radiodan::Logging do
  it 'sets a log level' do
    subject.level = :warn
    class Test
      include Radiodan::Logging
    end

    Test.new.logger.level.should == Logger::WARN
  end
end
