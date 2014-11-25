
require 'medusa_rest_client'

module Casteml
	class Acquisition
		attr_accessor :session, :instrument, :analyst, :analysed_at, :sample_uid, :sample_name, :bibliography_uid, :description
		def initialize(attrib = {})
			@session = attrib[:session] 
			@instrument = attrib[:instrument]
			@technique = attrib[:technique]
			@analyst = attrib[:analyst]
			@analysed_at = attrib[:analysed_at]
			@sample_uid = attrib[:sample_uid]
			@sample_name = attrib[:sample_name]
			@bibliography_uid = attrib[:bibliography_uid]
			@description = attrib[:description]

		end

		def remote_attributes
			attrib = Hash.new
			attrib[:name] = session
			attrib[:description] = description
			attrib[:operator] = analyst
			attrib
		end

		def save_remote
			MedusaRestClient::Analysis.new(remote_attributes)
		end
	end
end
