require 'casteml/acquisition'
class Array
	def to_array_of_arrays(opts = {})
		fmt = opts[:number_format] || '%.4g'
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
			array = [Casteml::Formats::TexFormat.escape(nickname)]
			acqs.each do |acq|
				value = acq.abundance_of(nickname)
				text = value ? '$' + sprintf(fmt, value) + '$' : '---'
				error = acq.error_of(nickname)
				text += error ? "\t$\(" + sprintf(fmt, error) + "\)$" : "\t(---)"				
				array << text
			end
			array_of_arrays << array
		end
		array_of_arrays
	end
end

module Casteml::Formats
	class TexFormat

		def self.document(opts = {})
			size = opts[:size] || 'a4paper'
			type = opts[:type] || 'article'
			io = StringIO.new
			io.puts <<-EOF
\\documentclass[#{size}]{#{type}}
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

		def self.to_string(data, opts = {})
			array_of_arrays = data.to_array_of_arrays
			num_column = array_of_arrays.map(&:size).max
			num_row = array_of_arrays.size
			header = array_of_arrays.shift
			document do |doc|
				doc.puts array_of_arrays2table(array_of_arrays, :header => header)
			end
		end
	end
end
