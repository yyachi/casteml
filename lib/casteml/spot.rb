require 'medusa_rest_client'
require 'casteml/remote_interaction'
module Casteml
	class Spot
		extend Casteml::RemoteInteraction
		set_remote_class MedusaRestClient::Spot
		attr_accessor :target_uid, :image_uid, :name, :description, :image_path, :name, :x_image, :y_image, :radius_in_percent, :stroke_color, :stroke_width, :fill_color, :opacity, :with_cross
		attr_remote :attachment_file_id, :name, :description, :spot_x, :spot_y, :target_uid, :radius_in_percent, :stroke_color, :stroke_width, :fill_color, :opacity, :with_cross
		alias_attribute :spot_x, :x_image
		alias_attribute :spot_y, :y_image

		def initialize(attrib = {})
			attrib.each do |key, value|
				self.send((key.to_s + '=').to_sym, value)
			end
		end

		def attachment_file_id
			return ref_image.id if ref_image
		end

		def ref_image=(obj)
			@ref_image = obj
		end

		def ref_image
			unless @ref_image
				remote_class = MedusaRestClient::AttachmentFile
				if image_uid
			  		obj = MedusaRestClient::Record.find(image_uid)
	  				raise "<ID: #{image_uid}> is not an instance of #{remote_class}." unless obj.class == remote_class
					@ref_image = obj
				elsif image_path
					@ref_image = remote_class.find_or_create_by_file(image_path)
				end
			end
			@ref_image
		end


		def save_remote
			return unless ref_image
			unless remote_obj.new?
				remote_obj.attributes.update(to_remote_hash)
			else
	        	ref_image.spots << remote_obj
			end
		end

	end
end
