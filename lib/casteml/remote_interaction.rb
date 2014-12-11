require 'casteml/user_interaction'
require 'medusa_rest_client'
module Casteml::RemoteInteraction
	include Casteml::UserInteraction
  	@record_pool = []

  	def setup
  		@record_pool = get_records
  	end

  	def record_pool
#  		setup if @record_pool.empty?
		setup if @record_pool.nil? || @record_pool.size == 0
  		@record_pool 
  	end

  	def record_pool=(records)
  		@record_pool = records
  	end

  	def clear
  		@record_pool = []
  	end

  	def get_records
  		@remote_class.find(:all)
  	end

  	def find_by_global_id(gid)
  		obj = MedusaRestClient::Record.find(gid)
  		raise "<ID: #{gid}> is not an instance of #{@remote_class}." unless obj.class == @remote_class
  		obj
  	end

  	def find_by_name(name)
  		obj = record_pool.find{|obj| obj.name == name }
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

  	def set_remote_class remote_class
  		@remote_class = remote_class
  	end

  	def remote_class
  		@remote_class
  	end

  	# def set_remote_attributes(array_of_symbols)
  	# 	@remote_attributes = array_of_symbols
  	# end

  	def attr_remote(*args)
  		@remote_attributes = args
  	end

  	def remote_attributes
  		@remote_attributes || []
  	end

  	def self.included(klass)
  	end

  	def self.extended(klass)
  		klass.include(InstanceMethods)
  	end

  	module InstanceMethods
  		attr_accessor :id, :global_id
  		def verbose(*args)
  			self.class.verbose(args)
  		end

		def initialize(attrib = {})
			attrib.each do |key, value|
				self.send((key.to_s + '=').to_sym, value)
			end
		end


		def to_remote_hash
			hash = Hash.new
			self.class.remote_attributes.each do |attrib|
				hash[attrib] = self.send(attrib)
			end
			hash
		end

		def remote_obj
			unless @remote_obj
				if self.id
					@remote_obj = self.class.remote_class.find(self.id)
				elsif self.global_id
					@remote_obj = self.class.find_by_global_id(self.global_id)
				else
					@remote_obj = self.class.remote_class.new(to_remote_hash)
				end
			end
			@remote_obj
		end

		def save_remote
			self.class.remote_class.new(to_remote_hash)
		end

  	end
end
