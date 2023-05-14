require_relative 'header'
require_relative 'question'
require_relative 'record'
require_relative 'packet'
require 'stringio'

class Parser
  CLASS_IN = 1

  def build_query(domain_name, record_type)
    name = encode_dns_name(domain_name)
    id = rand(0..65535)
    recursion_desired = 1 << 8

    header = Header.new(id:, flags: recursion_desired, num_questions: 1)
    question = Question.new(name:, type: record_type, klass: CLASS_IN)

    header.to_bytes + question.to_bytes
  end

  def parse_header(io)
    data = io.read(12).unpack("S>*")

    Header.new(
      id: data[0],
      flags: data[1],
      num_questions: data[2],
      num_answers: data[3],
      num_authorities: data[4],
      num_additionals: data[5]
    )
  end

  def parse_question(io)
    name = decode_name_simple(io)
    data = io.read(4)
    type, klass = data.unpack("S>*")

    Question.new(name:, type:, klass:)
  end

  def parse_record(io)
    name = decode_name(io)
    data = io.read(10)

    type, klass, ttl, data_len = data.unpack("S>S>L>S>")
    case type
    when Record::TYPE_NS
      data = decode_name(io)
    when Record::TYPE_A
      data = ip_to_string(io.read(data_len))
    else
      data = io.read(data_len)
    end

    Record.new(name:, type:, klass:, ttl:, data:)
  end

  def parse_packet(data)
    io = StringIO.new(data)
    header = parse_header(io)
    questions = header.num_questions.times.map { parse_question(io) }
    answers = header.num_answers.times.map { parse_record(io) }
    authorities = header.num_authorities.times.map { parse_record(io) }
    additionals = header.num_additionals.times.map { parse_record(io) }

    Packet.new(header:, questions:, answers:, authorities:, additionals:)
  end

  def ip_to_string(data)
    data.unpack("C*").join(".")
  end

  private

  def encode_dns_name(domain_name)
    parts = domain_name.split('.')

    # "C" means 1 byte, which is enough for a DNS label
    name = [parts[0].bytesize].pack("C") + parts[0]

    parts[1..-1].each do |part|
      name += [part.bytesize].pack("C") + part
    end

    name += "\x00"
  end

  def decode_name_simple(io)
    parts = []

    while (bytes = io.read(1).unpack("C")[0]) != 0
      parts << io.read(bytes)
    end

    parts.join('.')
  end

  def decode_name(io)
    parts = []

    while (bytes = io.read(1).unpack("C")[0]) != 0
      if (bytes & 0b1100_0000) != 0
        parts << decode_compressed_name(bytes, io)  
        break
      else
        parts << io.read(bytes)
      end
    end

    parts.join('.')
  end

  def decode_compressed_name(bytes, io)
    pointer_bytes = [bytes & 0b0011_1111].pack("C") + io.read(1)
    pointer = pointer_bytes.unpack("S>")[0]
    current_pos = io.pos
    io.seek(pointer)
    result = decode_name(io)
    io.seek(current_pos)

    result
  end
end
