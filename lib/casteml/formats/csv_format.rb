require 'csv'
require 'stringio'
require 'tempfile'
require 'casteml/acquisition'
require 'casteml/number_helper'
class CSV::Row
	alias to_hash_org to_hash
	def to_hash
		hash = to_hash_org
		hash_new = Hash.new

		hash.each do |key, value|
			next unless key

			setter = (key.gsub(/-/,"_") + "=").to_sym
			if Casteml::Acquisition.instance_methods.include?(setter)
				hash_new[key] = value
				next
			end

			if key =~ /spot_(.*)/
				method_name = $1
				hash_new[:spot] = Hash.new unless hash_new[:spot]
				hash_new[:spot][method_name.to_sym] = value
				next
			end

			if key =~ /(.*)\_error/
				nickname = $1
				abundance = hash_new[:abundances].find{|abundance| abundance[:nickname] == nickname } if hash_new[:abundances]
				abundance[:error] = value if abundance
				next
			end

			abundance = Hash.new
			if key =~ /(.*) \((.*)\)/
				abundance[:nickname] = $1
				abundance[:unit] = $2
			else
				abundance[:nickname] = key.strip
			end
			abundance[:data] = value
			hash_new[:abundances] ||= []
			hash_new[:abundances] << abundance
		end
		hash_new
	end

	def valid?
		flag = !self["session"].nil? || !self["name"].nil?
		flag
	end

	def unit_row?
		self[0] =~ /unit/i || self["session"].nil?
	end
end

module Casteml::Formats
	class CsvFormat
		extend Casteml::NumberHelper

		def self.default_units
			{:centi => 'cg/g', :micro => 'ug/g', :nano => 'ng/g', :pico => 'pg/g'}			
		end
		def self.to_string(hashs, opts = {})
			array_of_abundances = []
			array_of_spot = []
			hashs.each do |h|
				array_of_spot << h.delete(:spot)
				array_of_abundances << h.delete(:abundances).map{|ab| Casteml::Abundance.new(ab) } if h.has_key?(:abundances)
			end
			array_of_spot.compact!
			array_of_abundances.compact!

			array_of_nicknames = array_of_abundances.map{|abundances| abundances.map{|abundance| abundance.nickname }}
			nicknames = array_of_nicknames.flatten.uniq

			array_of_numbers = []

			array_of_abundances.each do |abundances|
				numbers = Array.new(nicknames.size, nil)
				abundances.each do |ab|
					idx = nicknames.index{|elem| elem == ab.nickname}
					numbers[idx] = ab.data_in_parts
				end
				array_of_numbers << numbers
			end

			array_of_units = []
			array_of_numbers.transpose.each do |numbers|
				number = numbers.compact.min
				unit = number_to_unit(number, :units => default_units ) if number
				array_of_units << unit
			end

			nicknames_with_unit = []
			nicknames.each_with_index do |nickname, idx|
				unit = array_of_units[idx]
				nicknames_with_unit << (unit ? "#{nickname} (#{unit})" : nickname)
			end

			array_of_data = []
			array_of_abundances.each_with_index do |abundances, i|
				data = Array.new(nicknames.size, nil)
				abundances.each_with_index do |ab, j|
					idx = nicknames.index{|elem| elem == ab.nickname}
					unit = array_of_units[idx]
					number = array_of_numbers[i][idx]
					data[idx] = (number ? number_to(number, unit) : nil)
				end
				array_of_data << data
			end

			spot_methods = array_of_spot.map{|spot| spot.keys }.flatten.uniq.map{|m| "spot_#{m}"}


			column_names = hashs.first.keys
			column_names.concat(spot_methods)
			column_names.concat(nicknames_with_unit)
			string = CSV.generate("", opts) do |csv|
				csv << column_names
				hashs.each_with_index do |h, idx|
					row = h.values
					row.concat(array_of_spot[idx].values) if array_of_spot[idx]
					row.concat(array_of_data[idx]) if array_of_data[idx]
					csv << row
				end
			end
			string
		end

		def self.decode_file(path, opts ={})
			string = File.open(path).read
			decode_string(string, opts)
		end

		def self.tab_separated?(string)
			string =~ /\t/
		end

		def self.tsv2csv(string)
			string.gsub(/\t/,',')
		end

		def self.column_wise?(string)
			csv = CSV.new(string)
			array_of_arrays = csv.to_a
			first_row = array_of_arrays[0].clone
			first_column = array_of_arrays.map{|array| array[0]}
			to_method_array(first_column).size > to_method_array(first_row).size
		end

		def self.to_method_array(array)
			acq_methods = Casteml::Acquisition.instance_methods
			array.compact.map{|item| item.gsub(/-/,'_').to_sym }.map{|item| acq_methods.include?(item) ? item : nil }.compact
		end

		def self.transpose(string, opts = {})
			csv = CSV.new(string)
			array_of_arrays = csv.to_a
			max_items = array_of_arrays.map{|array| array.size }.max
			unless array_of_arrays.all?{|array| array.size == max_items }
				array_of_arrays.each do |array|
					if array.size < max_items
						array[max_items - 1] = nil
					end
				end
			end
			csv_string = CSV.generate do |csv|
				array_of_arrays.transpose.each do |array|
					csv << array
				end
			end
			csv_string
		end

		def self.decode_string(string, opts = {})
			raise "empty csv!" if string.empty?
			string = tsv2csv(string) if tab_separated?(string)
			string = transpose(string) if column_wise?(string)

			sio = StringIO.new(string,"r")
			csv = CSV.new(sio, {
				:headers => true, 
				})
			rows = []
			csv.each do |row|
				if csv.lineno == 2 && row.unit_row?	
					row.each_with_index do |a, index|
						if a[1] && index != 0
							csv.headers[index] += " (#{a[1]})"
						end
					end
					next
				else
					raise "invalid row(#{csv.lineno}) #{row.to_s}" unless row.valid?
					rows << row.to_hash
				end
			end
			rows
		end

		def self.to_attrib

		end
	end	
end
