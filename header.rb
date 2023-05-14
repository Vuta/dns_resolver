class Header
  attr_reader :num_questions, :num_answers, :num_authorities, :num_additionals

  def initialize(id:, flags:, num_questions: 0, num_answers: 0, num_authorities: 0, num_additionals: 0)
    @id = id
    @flags = flags
    @num_questions = num_questions
    @num_answers = num_answers
    @num_authorities = num_authorities
    @num_additionals = num_additionals
  end

  def to_bytes
    [
      @id,
      @flags,
      @num_questions,
      @num_answers,
      @num_authorities,
      @num_additionals
    ].pack("S>*")
  end
end
