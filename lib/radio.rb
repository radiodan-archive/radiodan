module Radio
  def self.new(options=nil)
    Control.new(options)
  end
end

%w{logging control mpd state stimulus content}.each do |file|
  require_relative "./radio/#{file}"
end
