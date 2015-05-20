require 'casteml/acquisition'
require 'casteml/number_helper'

class Array
	def to_array_of_arrays(opts = {})
		fmt = opts[:number_format] || '%.4g'
        units_for_display = {:centi => 'c', :mili => 'm', :micro => 'u', :nano => 'n', :pico => 'p'}
        fmt_opts = {:format => "$%n%u$", :units => units_for_display }
		acqs = []
		each do |hash|
			acqs << Casteml::Acquisition.new(hash)
		end
		nicknames = []
		acqs.each do |acq|
			nicknames.concat(acq.abundances.map(&:nickname))
			nicknames.uniq!
		end

		array_of_arrays = []

		array_of_arrays << ["session"].concat(acqs.map{|acq| Casteml::Formats::TexFormat.escape(acq.session) })

		nicknames.each do |nickname|
			item = Casteml::MeasurementItem.find_by_nickname(nickname)
			array = (item && item.display_in_tex) ? [item.display_in_tex] : [Casteml::Formats::TexFormat.escape(nickname) + "\t"]
			acqs.each do |acq|
				ab = acq.abundance_of(nickname)
				value = ab.data_in_parts if ab && ab.data 
				error = ab.error_in_parts if ab && ab.error	
				#text = value ? '$' + sprintf(fmt, value) + '$' : '---'
				if value
					if ab.precision
						fmt_opts[:precision] = ab.precision
					else
						fmt_opts.delete(:precision)
					end
					#tops = fmt_opts.merge(:precision => ab.precision) if ab.precision
					if error
						text = Casteml::Formats::TexFormat.number_with_error_to_human(value, error, fmt_opts.merge(:format => "$%n(%e)$%u"))
					else
						text = Casteml::Formats::TexFormat.number_to_human(value, fmt_opts.merge(:format => "$%n$%u"))
					end
				else
					text = '---'
				end
				#text = value ? '$' + number_to_human(value, :precision => ab.precision) + '$' : '---'

				#text += error ? "\t$\(" + sprintf(fmt, error) + "\)$" : "\t(---)"				
				array << text
			end
			array_of_arrays << array
		end
		array_of_arrays
	end
end

module Casteml::Formats
	class TexFormat
	#	extend ActiveSupport::NumberHelper
		extend Casteml::NumberHelper

		# def self.number_with_error_to_human(number, error, options)
		# 	number_to_human(number, options.merge(:error => error))
		# end

		def self.document(opts = {})
			size = opts[:size] || '12pt'
			type = opts[:type] || 'article'
			io = StringIO.new
			io.puts <<-EOF
\\documentclass[#{size}]{#{type}}
\\usepackage{pmlatex}
\\begin{document}
			EOF
			yield io
			io.puts <<-EOF
\\end{document}
			EOF
			io.close
			io.string
		end

		def self.escape(string)
			string.gsub(/_/, '\\_')
		end

		def self.tabular(option, header = nil)
			io = StringIO.new
			io.puts "\\begin{tabular}{#{option}}"
			io.puts "\\hline"
			if header
				io.puts header.join(' & ') + '\\\\'
				io.puts "\\hline"
			end
			yield io
			io.puts "\\hline"
			io.puts "\\end{tabular}"
			io.close
			io.string
		end

		def self.double_slash
			'\\\\'
		end

		def self.command(name, arg = nil)
			txt = '\\' + name
			txt += '{' + arg + '}' if arg
			txt
		end

		def self.abundance(nickname)
			'$' + nickname.gsub(/[A-Z][a-z]*/){|a| '\\mbox{' + a + '}'}.gsub(/\d+/){|n| '_{' + n + '}' } + '$'
		end

		def self.array2row(array, opts = {})
			array.join(' & ') + double_slash
		end

		def self.array_of_arrays2table(array_of_arrays, opts = {})
			num_column = opts[:table_option] || array_of_arrays.map(&:size).max
			header = opts[:header]
			table_option = 'l' * num_column
			string = tabular(table_option, header) do |tab|
				array_of_arrays.each do |array|
					tab.puts array2row(array)
				end
			end
			string
		end

		def self.transpose_array_of_arrays(a)
			num_col = a.size
			num_row = a[0].size
			tr = []
			num_row.times do |idx|
				tr << a.map{|c| c[idx]}
			end
			tr
		end

		def self.to_string(data, opts = {})
			array_of_arrays = transpose_array_of_arrays(data.to_array_of_arrays(opts))
			if opts[:transpose]
				array_of_arrays = transpose_array_of_arrays(array_of_arrays)
			end

			num_column = array_of_arrays.map(&:size).max
			num_row = array_of_arrays.size
			header = array_of_arrays.shift
			#document do |doc|
			#	doc.puts array_of_arrays2table(array_of_arrays, :header => header)
			#end
			array_of_arrays2table(array_of_arrays, :header => header)
		end
	end
end
