class Packet
  attr_reader :answers

  def initialize(header:, questions:, answers:, authorities:, additionals:)
    @header = header
    @questions = questions
    @answers = answers
    @authorities = authorities
    @additionals = additionals
  end

  def ips
    answers.map do |ans|
      if ans.type_a?
        ans.data.unpack("C*").join(".")
      end
    end.compact
  end
end
