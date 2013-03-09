module Radio
  def self.new(options=nil)
    Control.new(options)
  end
end

%w{logger control mpd state stimulus content playlist}.each do |file|
  require_relative "./radio/#{file}"
end
