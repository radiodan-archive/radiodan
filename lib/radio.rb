require 'em_additions'

module Radio
  def self.new(&blk)
    @radio = Control.new(&blk)      
  end
end

%w{logging player panic download control mpd state stimulus content}.each do |file|
  require_relative "./radio/#{file}"
end
