require 'socket'               # Get sockets from stdlib
require 'json'

def parse(request)
	headers,body = request.split("\r\n\r\n", 2)
	html_head = headers.lines.first.chomp.split(" ")
	verb = html_head[0]
	path = html_head[1]
	version = html_head[2]
	{verb: verb, path: path, v: version, headers: headers, body: body}
end


server = TCPServer.open(2000)  # Socket to listen on port 2000
loop {                         # Servers run forever

  client = server.accept       # Wait for a client to connect\
  puts "Client connected!"
  # $/ = "END"
  params = parse(client.recv(10000))

  #GET
  if params[:verb] == "GET"
	  begin
	  	file = File.new(params[:path])
		  contents = "HTTP/1.0 200 OK\r\nContent-Length: #{file.size}\r\n\r\n" +
		  						open(file).read
		rescue
			contents = "HTTP/1.0 404 Not Found\r\n\r\n"
		end
	elsif params[:verb] == "POST"
		begin
			args = JSON.parse(params[:body])
			file = File.new("thanks.html")
			gen_html = ""
			args.each {|_,v|
				v.each { |k2,v2|
					gen_html = gen_html + "<li>#{k2.to_s}: #{v2}</li>\n"
				}
			}
			body = file.read.sub(/<%= yield %>\n/, gen_html)
			contents = "HTTP/1.0 200 OK\r\nContent-Length: #{body.bytesize}\r\n\r\n" +
								 body
		rescue
			contents = "HTTP/1.0 401 Bad Request\r\n\r\n"
		end
	else
		contents = "HTTP/1.0 401 Bad Request\r\n\r\n"
	end
	#POST
  client.puts(contents)
 	# client.puts(Time.now.ctime)
  client.puts "Closing the connection. Bye!"
  client.close                 # Disconnect from the client
}