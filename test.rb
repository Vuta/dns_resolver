require_relative 'parser'
require 'socket'
require 'stringio'

class Test
  def lookup_domain(domain_name)
    parser = Parser.new
    query = parser.build_query(domain_name, 1)

    sk = UDPSocket.new
    sk.send(query, 0, "8.8.8.8", 53)

    begin
      response, _ = sk.recvfrom_nonblock(255)

      packet = parser.parse_packet(response)
      packet.ips 
    rescue IO::WaitReadable
      IO.select([sk])
      retry
    end
  end
end

test = Test.new
p test.lookup_domain("example.com")
p test.lookup_domain("recurse.com")
p test.lookup_domain("www.metafilter.com")
p test.lookup_domain("www.facebook.com")
