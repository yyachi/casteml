require 'medusa_rest_client'
require 'casteml/remote_interaction'
module Casteml
  class Technique
    extend Casteml::RemoteInteraction
    set_remote_class MedusaRestClient::Technique
  end
end
