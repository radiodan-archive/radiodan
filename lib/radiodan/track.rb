require 'forwardable'
require 'active_support/core_ext/hash/indifferent_access'

class Radiodan
class Track
  class NoFileError < Exception; end
  extend Forwardable
  attr_reader :attributes
  def_delegators :@attributes, :[]
  
  
  alias_method :eql?, :==
  
  def initialize(attributes={})
    @attributes = HashWithIndifferentAccess.new(attributes)
    unless @attributes.has_key?(:file)
      raise NoFileError, 'No file given for track'
    end
  end
  
  def ==(other)
    self[:file] == other[:file]
  end
  
  def method_missing(method, *args, &block)
    if @attributes.include?(method)
      @attributes[method]
    else
      super
    end
  end
  
  def respond_to?(method)
    if @attributes.include?(method)
      true
    else
      super
    end
  end
end
end
