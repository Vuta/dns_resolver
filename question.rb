class Question
  def initialize(name:, type:, klass:)
    @name = name
    @type = type
    @klass = klass
  end

  def to_bytes
    @name + [@type, @klass].pack("S>*")
  end
end
