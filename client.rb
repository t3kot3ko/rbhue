require "faraday"
require "json"

class Client 
	def initialize(host, user_id)
		@host = host
		url = "http://#{@host}"
		@conn = Faraday::Connection.new(url: url) do |builder|
			builder.request :url_encoded
			# builder.response :logger
			builder.adapter :net_http
		end

		@user_id = user_id
	end

	def __build_url(path)
		return "/" + ["api", @user_id, *path.split("/").reject(&:empty?)].join("/")
	end

	def do_get(path)
		response = @conn.get( __build_url(path) )
		return JSON.parse(response.body)
	end

	def do_put(path, params)
		response = @conn.put(__build_url(path), params)
		return JSON.parse(response.body)
	end


	def groups
		return self.do_get("/groups")
	end

	def __handle_error(response)

	end

end


