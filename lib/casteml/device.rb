require 'medusa_rest_client'
require 'casteml/remote_interaction'
module Casteml
  class Device
	extend Casteml::RemoteInteraction
	set_remote_class MedusaRestClient::Device
  end
end
