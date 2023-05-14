class Packet
  attr_reader :answers, :additionals, :authorities

  def initialize(header:, questions:, answers:, authorities:, additionals:)
    @header = header
    @questions = questions
    @answers = answers
    @authorities = authorities
    @additionals = additionals
  end
end
