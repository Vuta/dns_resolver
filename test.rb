require_relative 'resolver'
require 'socket'

class Test
  def run
    query = Resolver.new.build_query("example.com", 1)  

    sk = UDPSocket.new
    sk.send(query, 0, "8.8.8.8", 53)

    begin
      p sk.recvfrom_nonblock(255)
    rescue IO::WaitReadable
      IO.select([sk])
      retry
    end
  end
end

Test.new.run
