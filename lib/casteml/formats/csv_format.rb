require 'csv'
require 'stringio'
require 'tempfile'
require 'casteml/acquisition'
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
		def self.to_string(hashs, opts = {})
			array_of_abundances = []
			hashs.each do |h|
				array_of_abundances << h.delete(:abundances)
			end
			array_of_nicknames = array_of_abundances.map{|abundances| abundances.map{|abundance| abundance[:nickname] }}
			array_of_units = array_of_abundances.map{|abundances| abundances.map{|abundance| abundance[:unit] }}
			array_of_data = array_of_abundances.map{|abundances| abundances.map{|abundance| abundance[:data] }}

			nicknames = array_of_nicknames.flatten.uniq
			column_names = hashs.first.keys			
			column_names.concat(nicknames)
			string = CSV.generate("", opts) do |csv|
				csv << column_names
				hashs.each_with_index do |h, idx|
					csv << h.values.concat(array_of_data[idx])
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
