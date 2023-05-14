require_relative 'parser'
require 'socket'
require 'byebug'

class Resolver
  def get_answer(packet)
    ip = nil

    packet.answers.each do |record|
      if record.type_a?
        ip = record.data
        break
      end
    end

    ip
  end

  def get_nameserver(packet)
    ns = nil

    packet.authorities.each do |record|
      if record.type_ns?
        ns = record.data
        break
      end
    end

    ns
  end

  def get_nameserver_ip(packet)
    ip = nil

    packet.additionals.each do |record|
      if record.type_a?
        ip = record.data
        break
      end
    end

    ip
  end

  def resolve(domain_name, record_type)
    nameserver = "198.41.0.4"
    while true
      puts("Querying #{nameserver} for #{domain_name}")

      parser = Parser.new
      query = parser.build_query(domain_name, record_type)

      sk = UDPSocket.new
      sk.send(query, 0, nameserver, 53)
      begin
        response, _ = sk.recvfrom_nonblock(1024)
        packet = parser.parse_packet(response)

        if ip = get_answer(packet)
          return ip
        elsif ns_ip = get_nameserver_ip(packet)
          nameserver = ns_ip
        elsif ns_domain = get_nameserver(packet)
          nameserver = resolve(ns_domain, record_type)
        else
          raise 'Something went wrong'
        end
      rescue IO::WaitReadable
        IO.select([sk])
        retry
      end
    end
  end
end

resolver = Resolver.new
p resolver.resolve("google.com", Record::TYPE_A)
p resolver.resolve("twitter.com", Record::TYPE_A)
