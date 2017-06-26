class API
	def initialize(client)
		@client = client
	end

	def __name_to_id(name)
		self.list.each do |id, value|
			return id.to_i if value["name"] == name
		end

		raise "No entry found: #{name}"
	end
end

class LightAPI < API
	def list
		return @client.do_get("/lights")
	end

	def set_state(id, params)
		response = @client.do_put("lights/#{id}/state", params.to_json)
		return true if response.all?{|e| e["success"]}
		return false
	end

	def show(id)
		return @client.do_get("lights/#{id}/")
	end
end

class GroupAPI < API
	def list	
		return @client.do_get("/groups")
	end

	def show(id)
		return @client.do_get("/groups/#{id}/")
	end

	def set_state(id, params)
		response = @client.do_put("/groups/#{id}/action", params.to_json)
		return true, response  if response.all?{|e| e["success"]}
		return false, response

	end
end

if $0 == __FILE__
	require_relative "./client.rb"

	host = "192.168.1.19"
	user_id = "iZQ5mF-O6iZiY32FgpPXYb4uFG8-9-4S-UB7bQ6F"

	client = Client.new(host, user_id)
	light = LightAPI.new(client)
	group = GroupAPI.new(client)

	p group.list
	group_names = group.list.map{|id, value| value["name"]}

	p group.set_state(1, {on: false})
end
