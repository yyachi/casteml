require 'casteml'
require 'active_support'
require 'alchemist'

class Float
	def precision(error)
		reg = Regexp.new("e(.*)")
		self_e = reg.match(sprintf("%e", self))[1].to_i
		error_e = reg.match(sprintf("%e", error))[1].to_i
		d = self_e - error_e
		(d >= 0) ? d + 1 : 1
	end
end

module ActiveSupport
  module NumberHelper
    class NumberToHumanConverter
		alias convert_org convert
		def initialize(number, options)
			options[:units] ||= Casteml::NumberHelper::DEFAULT[:units]
			@number = number
			@opts   = options.symbolize_keys
		end

		def convert
			if options[:error]
				return convert_with_error
			elsif options[:unit]
				return convert_with_unit
			else
				return convert_org
			end
		end

		def convert_with_unit
			unit = options.delete(:unit)
	        @number = Float(number)
    	    # for backwards compatibility with those that didn't add strip_insignificant_zeros to their locale files
        	unless options.key?(:strip_insignificant_zeros)
          		options[:strip_insignificant_zeros] = true
        	end

        	units = opts[:units]
        	exponent = unit_exponent(unit, units)
        	@number = number / (10 ** exponent)
        	rounded_number = NumberToRoundedConverter.convert(number, options)

        	format.gsub(/%n/, rounded_number).gsub(/%u/, unit).strip

		end

		def convert_with_error
	        error = Float(options[:error])
	        @number = Float(number)
	        options[:precision] = @number.precision(error)


    	    # for backwards compatibility with those that didn't add strip_insignificant_zeros to their locale files
        	unless options.key?(:strip_insignificant_zeros)
          		options[:strip_insignificant_zeros] = true
        	end

        	units = opts[:units]
        	exponent = calculate_exponent(units)
        	@number = number / (10 ** exponent)
        	error = error / (10 ** exponent)

        	unit = determine_unit(units, exponent)

        	rounded_number = NumberToRoundedConverter.convert(number, options)
        	rounded_error = NumberToRoundedConverter.convert(error, options.merge(:precision => 1))

        	format.gsub(/%n/, rounded_number).gsub(/%e/, rounded_error).gsub(/%u/, unit).strip			
		end

        def unit_exponent(unit, units)
          uis = case units
          when Hash
            units
          when String, Symbol
            I18n.translate(units.to_s, :locale => options[:locale], :raise => true)
          when nil
            translate_in_locale("human.decimal_units.units", raise: true)
          else
            raise ArgumentError, ":units must be a Hash or String translation scope."
          end
          ui = uis.find{|item| item[1] == unit }
          if ui
          	return INVERTED_DECIMAL_UNITS[ui[0]]
          else
          	return nil
          end
          #.map {|key, value| { value => INVERTED_DECIMAL_UNITS[key]}   }
#          end.keys.map { |e_name| INVERTED_DECIMAL_UNITS[e_name] }.sort_by { |e| -e }
        end

    end
  end
end

module Alchemist
	class Library
		alias_method :load_conversion_table_org, :load_conversion_table
		def load_conversion_table(filename=Configuration::DEFAULT_UNITS_FILE)
			table = load_conversion_table_org(filename)			
			begin
				extra_filename = Casteml::ABUNDANCE_UNIT_FILE
			 	extra_table = YAML.load_file(extra_filename)
			 	extra_table.each do |key, value|
			 		table[key.to_sym] = value
			 	end
				table
			rescue Psych::SyntaxError, Errno::ENOENT
				table
			end
		end
	end
end

module Casteml
	module NumberHelper

		Alchemist.setup
		UNIT = :parts
		DEFAULT = {
            units: {
              # femto: Quadrillionth
              pico: "p",
              nano: "n",
              micro: "u",
              #mili: "m",
              centi: "c",
              # deci: Tenth
              unit: "",
              # ten:
              #   one: Ten
              #   other: Tens
              # hundred: Hundred
#              thousand: "kilo",
#              million: "mega",
#              billion: "giga",
#               trillion: "Trillion",
#               quadrillion: "Quadrillion"
            }
		}
		include ActiveSupport::NumberHelper

		def number_with_error_to_human(number, error, options)
#			options[:units] ||= DEFAULT[:units] 
			number_to_human(number, options.merge(:error => error))
		end

		def number_to_unit(number, opts = {})
			converter = NumberToHumanConverter.new(number, opts)
			units = opts[:units] || DEFAULT[:units]
        	exponent = converter.send(:calculate_exponent, units)
        	#@number = number / (10 ** exponent)
        	unit = converter.send(:determine_unit, units, exponent)
		end

	    def numbers_to_human(numbers, options = {})
	    	number = numbers.min
	    	unit = number_to_unit(number, options)
	    	numbers.map{ |number| number_to_human(number, options.merge(:unit => unit)) }
	    end


		def precision(number, error)
			number.precision(error)
		end

		def number_to(number, unit)
			precision = number.to_s.scan(/\d/).count
			number = Alchemist.measure(number, UNIT).to(unit.to_sym).to_f
			rounded_number = NumberToRoundedConverter.convert(number, :precision => precision, :significant => true)
			Float(rounded_number)			
		end

		def numbers_to(numbers, unit)
			numbers.map{|number| number_to(number, unit)}
		end

		def numbers_from(numbers, unit)
			numbers.map{|number| number_from(number, unit) }
		end

		def number_from(number, unit)
			precision = number.to_s.scan(/\d/).count
			number = Alchemist.measure(number, unit).to(UNIT).to_f
			rounded_number = NumberToRoundedConverter.convert(number, :precision => precision, :significant => true)
			Float(rounded_number)
		end
	end
end
