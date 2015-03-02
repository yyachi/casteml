require 'casteml'
require 'medusa_rest_client'
require 'casteml/remote_interaction'
module Casteml
  class MeasurementCategory
	  extend Casteml::RemoteInteraction
	  set_remote_class MedusaRestClient::MeasurementCategory
    #attr_remote :nickname, :description, :display_in_html, :display_in_tex, :unit_id
    #attr_accessor :unit, :nickname, :significant_digit, :format, :format_error, :in_tex

    #alias_attribute :code, :nickname


    def self.setup
      dump_all unless File.exist?(dump_path)
      @record_pool = load_from_dump
    end

    def self.load_records_from_local(path)
      path = File.expand_path(path)
      hashs = YAML.load_file(path)
      records = []
      hashs.each do |hash|
        records << new(hash)
      end
      records
    end


    # def self.find_by_nickname(nickname)
    #   obj = record_pool.find{|obj| obj.nickname == nickname }
    # end


#   	def self.find_or_create_by_name(name)
#   		obj = record_pool.find{|obj| obj.nickname == name } if record_pool
#   		unless obj
#         robj = @remote_class.find_by_nickname(name)
#         unless robj
#     			if ask_yes_no "<#{@remote_class}: #{name}> does not exist. Are you sure you want to create it?", true
#             obj = @remote_class.create(:nickname => name)
# #            record_pool << obj
#           else
#             raise "<#{@remote_class}: #{name}> does not exist."
#           end
#         else
#           obj = robj
#         end
#   		end
#       record_pool << obj
#       obj
#   	end
  end
end
