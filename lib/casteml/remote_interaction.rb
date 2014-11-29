require 'casteml/user_interaction'
require 'medusa_rest_client'
module Casteml::RemoteInteraction
	include Casteml::UserInteraction

  	@@record_pool = []

  	def setup
  		@@record_pool = get_records
  	end

  	def record_pool
  		setup if @@record_pool.empty?
  		@@record_pool
  	end

  	def record_pool=(records)
  		@@record_pool = records
  	end

  	def clear
  		@@record_pool = []
  	end

  	def set_remote_class remote_class
  		@remote_class = remote_class
  	end

  	def get_records
  		@remote_class.find(:all)
  	end

  	def find_by_global_id(gid)
  		obj = MedusaRestClient::Record.find(gid)
  		raise "<ID: #{gid}> is not an instance of #{@remote_class}." unless obj.class == @remote_class
  		obj
  	end

  	def find_or_create_by_name(name)
  		obj = record_pool.find{|obj| obj.name == name }
  		unless obj
  			if ask_yes_no "<#{@remote_class}: #{name}> does not exist. Are you sure you want to create it?", true
          obj = @remote_class.create(:name => name)
          record_pool << obj
        else
          raise "<#{@remote_class}: #{name}> does not exist."
        end
  		end
      obj
  	end

end
