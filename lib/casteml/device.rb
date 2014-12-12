require 'medusa_rest_client'
require 'casteml/remote_interaction'
module Casteml
  class Device
	extend Casteml::RemoteInteraction
	set_remote_class MedusaRestClient::Device

    def self.setup
      @record_pool = []
    end


  	def self.find_or_create_by_name(name)
  		obj = record_pool.find{|obj| obj.name == name } if record_pool
  		unless obj
        robjs = @remote_class.find_by_name(name)
        if robjs.size == 0 
    			if ask_yes_no "<#{@remote_class}: #{name}> does not exist. Are you sure you want to create it?", true
            obj = @remote_class.create(:name => name)
#            record_pool << obj
          else
            raise "<#{@remote_class}: #{name}> does not exist."
          end
        else
          obj = robjs[0]
        end
  		end
      record_pool << obj
      obj
  	end

  end
end
