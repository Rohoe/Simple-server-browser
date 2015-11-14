require 'socket'
require 'json'

host = 'localhost'     # The web server
port = 2000                         # Default HTTP port
path = "index.html"                 # The file we want

def parse(response)
	headers,body = response.split("\r\n\r\n", 2)
	html_head = headers.lines.first.chomp.split
	version = html_head[0]
	resp_code = html_head[1]
	msg = html_head[2..-1].join(" ")
	{v: version, code: resp_code, msg: msg, body: body, headers: headers}
end

def build_request(request)
	header1 = "#{request[:verb]} #{request[:path]} HTTP/1.0\r\n"
	if !request[:body].nil?
		body = request[:body].to_json
		header2 = "Content-length: #{body.bytesize}\r\n"
		built_request = header1 + header2 + "\r\n" + body
	else
		built_request = header1 + "\r\n"
	end
	built_request
end

def get_request
	request = Hash.new("")
	begin
		puts "What request would you like to make?"
		input = gets.chomp.downcase
		if input == "get"
			Kernel.print "Path: "
			path = gets.chomp
			request[:verb] = "GET"
			request[:path] = path
		elsif input == "post"
			Kernel.print "Name: "
			name = gets.chomp
			Kernel.print "Email: "
			email = gets.chomp
			data = {person: {name: name, email: email}}
			request[:verb] = "POST"
			request[:path] = "no_path"
			request[:body] = data
		else
			raise "Invalid input"
		end
	rescue Exception => e
		puts e.message
		retry
	end
	build_request(request)
end

# This is the HTTP request we send to fetch a file
request = get_request

socket = TCPSocket.open(host,port)  # Connect to server
socket.print(request)               # Send request
response = socket.read              # Read complete response
params = parse(response)
if params[:code] == "200"
	puts params[:body]
else
	puts "Error #{params[:code]}: #{params[:msg]}"
end