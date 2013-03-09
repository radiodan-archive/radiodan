module Radio; end

%w{control mpd playlist}.each do |file|
  require_relative "./radio/#{file}"
end
