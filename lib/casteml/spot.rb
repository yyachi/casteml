require 'medusa_rest_client'
require 'casteml/remote_interaction'
module Casteml
	class Spot
		extend Casteml::RemoteInteraction
		set_remote_class MedusaRestClient::Spot
		attr_accessor :target_uid, :image_uid, :name, :description, :image_path, :name, :x_image, :y_image, :x_overpic, :y_overpic, :radius_in_percent, :stroke_color, :stroke_width, :fill_color, :opacity, :with_cross
		attr_remote :name, :description, :spot_x, :spot_y, :target_uid#, :radius_in_percent, :stroke_color, :stroke_width, :fill_color, :opacity, :with_cross
		alias_attribute :attachment_file_global_id, :image_uid
		#alias_attribute :spot_y, :y_image
		#alias_attribute :ref_image_x_from_center, :x_image
		#alias_attribute :ref_image_y_from_center, :y_image

		def initialize(attrib = {})
			attrib.each do |key, value|
				setter = (key.to_s + '=').to_sym
				self.send(setter, value) if self.respond_to?(setter)
			end
		end

		def attachment_file_id
			return ref_image.id if ref_image
		end

		def ref_image=(obj)
			@ref_image = obj
		end

		def spot_x
			ref_image.length ? (ref_image.width.to_f/2 + x_image.to_f * ref_image.length.to_f / 100 ).to_i : nil
		end

		def spot_y
			ref_image.length ? (ref_image.height.to_f/2 - y_image.to_f * ref_image.length.to_f / 100 ).to_i : nil
		end

		# def spot_x_from_center
		# 	spot_xy_from_center[0] if spot_xy_from_center
		# end

		# def spot_y_from_center
		# 	spot_xy_from_center[1] if spot_xy_from_center
		# end

		# def spot_xy_from_center
		# 	return unless ref_image
		# 	return unless image_x
		# 	return unless image_y

		# 	cpt = spot_center_xy
		# 	[spot_x - cpt[0], cpt[1] - spot_y]
		# end

		# def spot_center_xy
		# 	[ref_image.width.to_f / ref_image.length / 2 * 100, ref_image.height.to_f / ref_image.length / 2 * 100]
		# end

		# def spot_center_ij
		# 	[ref_image.width.to_f / 2, ref_image.height.to_f / 2]
		# end

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
				remote_obj.radius_in_percent = 5
				remote_obj.stroke_color = "blue"
				remote_obj.opacity = 0
	        	ref_image.spots << remote_obj
			end
		end
	end
end
