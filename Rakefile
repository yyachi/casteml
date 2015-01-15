require "bundler/gem_tasks"
require 'casteml'
require 'medusa_rest_client'
namespace :remote_dump do
  klasses = [Casteml::Unit, Casteml::MeasurementItem]
  desc "clear local-data"
  task :clear do |task, args|
    klasses.each do |klass|
      dump_path = klass.dump_path
      if File.exist?(dump_path)
        puts "#{dump_path} is removing..."
        FileUtils.rm(dump_path) if File.exist?(dump_path)
  	  end
    end
  end
  
  desc "sync local-data with remote"
  task :sync do |task, args|
  	klasses.each do |klass|
  	  	dump_path = klass.dump_path
    	puts "#{dump_path} is generating..."
    	klass.dump_all
	end
  end

end
