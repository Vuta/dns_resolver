require_relative 'header'
require_relative 'question'

class Resolver
  TYPE_A = 1
  CLASS_IN = 1

  def build_query(domain_name, record_type)
    name = encode_dns_name(domain_name)
    id = rand(0..65535)
    recursion_desired = 1 << 8

    header = Header.new(id:, flags: recursion_desired, num_questions: 1)
    question = Question.new(name:, type: record_type, klass: CLASS_IN)

    header.to_bytes + question.to_bytes
  end

  private

  def encode_dns_name(domain_name)
    parts = domain_name.split('.')

    # "c" means 1 byte, which is enough for a DNS label
    name = [parts[0].bytesize].pack("c") + parts[0]

    parts[1..-1].each do |part|
      name += [part.bytesize].pack("c") + part
    end

    name += "\x00"
  end
end
