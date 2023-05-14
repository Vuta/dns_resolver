class Record
  attr_reader :data, :type

  TYPE_A = 1
  TYPE_NS = 2
  TYPE_TXT = 16

  def initialize(name:, type:, klass:, ttl:, data:)
    @name = name
    @type = type
    @klass = klass
    @ttl = ttl
    @data = data
  end

  def type_a?
    type == TYPE_A
  end

  def type_txt?
    type == TYPE_TXT
  end

  def type_ns?
    type == TYPE_NS
  end
end
