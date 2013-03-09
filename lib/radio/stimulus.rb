=begin
  The many ways to control the radio.
  Stimuli register themselves to the parent class
  #new creates instances of each and passes on options
  #check checks each instance in term
=end

module Radio
  class Stimulus
    @@stimuli = []
    
    def self.register(stimulus)
      @@stimuli << stimulus
    end
    
    attr_accessor :stimuli
    def initialize(options)
       self.stimuli = @@stimuli.collect do |s|
         s.new(options)
       end
    end
    
    def check
      self.stimuli.each do |s|
        s.check
      end
    end
  end
end

require_relative "./stimulus/touch_file"
