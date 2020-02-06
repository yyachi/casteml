require "bundler/gem_tasks"
require 'casteml'
require 'medusa_rest_client'
namespace :remote_dump do
  klasses = [Casteml::Unit, Casteml::MeasurementItem, Casteml::MeasurementCategory]
  desc "clear local-data"
  task :clear do |task, args|
    klasses.each do |klass|
      dump_path = klass.dump_path
      if File.exist?(dump_path)
        puts "#{dump_path} is removing..."
        FileUtils.rm(dump_path) if File.exist?(dump_path)
  	  end
    end
    config_path = Casteml::ABUNDANCE_UNIT_FILE
    if File.exist?(config_path)
        puts "#{config_path} is removing..."
        FileUtils.rm(config_path)
    end
  end
  
  desc "sync local-data with remote"
  task :sync do |task, args|
  	klasses.each do |klass|
  	  	dump_path = klass.dump_path
    	puts "#{dump_path} is generating..."
    	klass.dump_all
	  end
    puts "#{Casteml::ABUNDANCE_UNIT_FILE} is generating..."
    Casteml::Unit.refresh_abundance_unit_file
  end

  namespace :unit do
    desc 'show local unit'
    task :show do |task, args|
      Casteml::Unit.record_pool.each do |unit|
        puts "name: #{unit.name} text: #{unit.text}"
      end
    end
  end
end
