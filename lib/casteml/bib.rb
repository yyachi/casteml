require 'medusa_rest_client'
require 'casteml/remote_interaction'
module Casteml
	class Bib
		extend Casteml::RemoteInteraction
		set_remote_class MedusaRestClient::Bib
		attr_accessor :entry_type, :abbreviation, :name, :journal, :year, :volume, :number, :pages, :month, :note, :key, :link_url, :doi
		attr_remote :entry_type, :abbreviation, :name, :journal, :year, :volume, :number, :pages, :month, :note, :key, :link_url, :doi
	end
end
