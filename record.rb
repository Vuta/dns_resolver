class Record
  attr_reader :data, :type

  TYPE_A = 1

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
end
