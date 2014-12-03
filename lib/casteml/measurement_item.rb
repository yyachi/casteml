require 'medusa_rest_client'
require 'casteml/remote_interaction'
module Casteml
  class MeasurementItem
	extend Casteml::RemoteInteraction
	set_remote_class MedusaRestClient::MeasurementItem

  	def self.find_or_create_by_name(name)
  		obj = record_pool.find{|obj| obj.nickname == name }
  		unless obj
  			if ask_yes_no "<#{@remote_class}: #{name}> does not exist. Are you sure you want to create it?", true
          obj = @remote_class.create(:nickname => name)
          record_pool << obj
        else
          raise "<#{@remote_class}: #{name}> does not exist."
        end
  		end
      obj
  	end

  end
end
