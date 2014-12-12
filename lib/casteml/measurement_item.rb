require 'medusa_rest_client'
require 'casteml/remote_interaction'
module Casteml
  class MeasurementItem
	extend Casteml::RemoteInteraction
	set_remote_class MedusaRestClient::MeasurementItem


    def self.setup
      @record_pool = []
    end


  	def self.find_or_create_by_name(name)
  		obj = record_pool.find{|obj| obj.nickname == name } if record_pool
  		unless obj
        robj = @remote_class.find_by_nickname(name)
        unless robj
    			if ask_yes_no "<#{@remote_class}: #{name}> does not exist. Are you sure you want to create it?", true
            obj = @remote_class.create(:nickname => name)
#            record_pool << obj
          else
            raise "<#{@remote_class}: #{name}> does not exist."
          end
        else
          obj = robj
        end
  		end
      record_pool << obj
      obj
  	end

  end
end
