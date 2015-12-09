require 'medusa_rest_client'
require 'casteml/remote_interaction'
module Casteml
  class Stone
    extend Casteml::RemoteInteraction
    set_remote_class MedusaRestClient::Specimen

    def self.setup
  		@record_pool = []
  	end

  	def self.find_or_create_by_name(name)
  		obj = record_pool.find{|obj| obj.name == name }
  		unless obj
  			robjs = @remote_class.find_by_name(name)
  			if robjs.size == 0
	  			if ask_yes_no "<#{@remote_class}: #{name}> does not exist. Are you sure you want to create it?", true
	          		obj = @remote_class.create(:name => name)
	          		record_pool << obj
	        else
	          		raise "<#{@remote_class}: #{name}> does not exist."
	        end
        else
      		lists = robjs.map{|robj| "#{robj.name} <ID: #{robj.global_id}>" }.push "create new one"
      		select = ui.choose_from_list("select one", lists)
      		obj = robjs[select[1]]
      		if obj
      			record_pool << obj
      		else
          		obj = @remote_class.create(:name => name)
          		record_pool << obj        			
      		end

        end
  		end
      	obj
  	end


  end
end
