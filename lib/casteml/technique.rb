require 'medusa_rest_client'
require 'casteml/user_interaction'
module Casteml
  class Technique
	extend Casteml::UserInteraction

	# @ui = nil
	# def self.ui
	# 	@ui ||= Casteml::ConsoleUI.new
	# end


  	@@record_pool = []

  	def self.setup
  		@@record_pool = get_records
  	end

  	def self.get_records
  		MedusaRestClient::Technique.find(:all)
  	end

  	def self.record_pool
  		setup if @@record_pool.empty?
  		@@record_pool
  	end

  	def self.record_pool=(records)
  		@@record_pool = records
  	end

  	def self.clear
  		@@record_pool = []
  	end

  	def self.find_or_create_by_name(name)
  		obj = record_pool.find{|obj| obj.name == name }
  		unless obj
  			if ask_yes_no "<Technique: #{name}> does not exist. Are you sure you want to create it?"
          obj = MedusaRestClient::Technique.create(:name => name)
          record_pool << obj
        else
          raise "<Technique: #{name}> does not exist."
        end
  		end
      obj
  	end
  end
end
