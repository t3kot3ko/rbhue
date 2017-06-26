require "thor"
require "dotenv"

require_relative "./api.rb"
require_relative "./client.rb"

module Hue
	class AppBase < Thor

		def initialize(*args)
			super(*args)

			Dotenv.load
			host = ENV["HUE_HOST"]
			user_id = ENV["HUE_USER_ID"]

			if host.nil? || user_id.nil?
				raise "Both HUE_HOST and HUE_USER_ID must be set"
			end

			@client = Client.new(host, user_id)
		end
	end

	class Light < AppBase
		def initialize(*args)
			super(*args)
			@api = LightAPI.new(@client)
		end


		# TODO extract to App
		desc "off", "Turn off the light"
		def off(name)
			id = @api.__name_to_id(name)
			return @api.set_state(id, {on: false})
		end

		desc "on", "Turn on the light"
		def on(name)
			id = @api.__name_to_id(name)
			return @api.set_state(id, {on: true})
		end

		desc "list", "Show light list"
		def list
			self.names.each do |name|
				puts name
			end
		end

		desc "show", "Show information of each light"
		def show(name)
			id = @api.__name_to_id(name)
			p @api.show(id)
		end

		# Internal methods (warning appears without `no_commands` block)
		no_commands do
			def names
				return @api.list.map{|id, value| value["name"]}
			end
		end
	end

	class Group < AppBase
		def initialize(*args)
			super(*args)
			@api = GroupAPI.new(@client)
		end

		desc "list", "Show group names"
		def list
			@api.list.each do |id, value|
				puts value["name"]
			end
		end
	end

	class App < AppBase
		desc "light", "Manage lights"
		subcommand "light", Light
		desc "group", "Manage groups which usually include one or more lights"
		subcommand "group", Group
	end

end

Hue::App.start(ARGV)
