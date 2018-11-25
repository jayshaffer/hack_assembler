require './parser.rb'
require './translator.rb'

class HackAssembler
	attr_accessor :symbol_table, :src, :parser
	def initialize(src)
		build_symbol_table
		@src = File.expand_path(src)
		@src_name = File.basename(@src, '.asm')
		@dest = File.dirname(__FILE__) + "/#{@src_name}.hack" 
		@tmp_src = "/tmp/#{@src_name}.asm"
		@var_pointer = 16
		File.delete(@dest) if File.exist?(@dest)
		File.delete(@tmp_src) if File.exist?(@tmp_src)
		@parser = Parser.new
	end

	def assemble
		line_number = 0
		build_stripped_file
		translate_labels
		translate_vars
		build_fully_stripped
		File.open(@dest, 'w') do |file|
			iterate_file do |line|
				file << handle_line(line, line_number) + "\n"
			end
		end
	end

	private

	def build_symbol_table
		table = {}
		for i in 0..15 do
			table["R#{i}"] = i
		end
		table["SCREEN"] = 16384
		table["KEYBOARD"] = 24576
		table["SP"] = 0 
		table["LCL"] = 1
		table["ARG"] = 2
		table["THIS"] = 3
		table["THAT"] = 4
		@symbol_table = table
	end
	
	def build_stripped_file
		File.open(@tmp_src , 'w') do |file|
			File.open(@src) do |src_file|
				src_file.each_line do |line|
					file << line if @parser.usable_line?(line) 
				end
			end
		end
	end

	def build_fully_stripped
		File.delete(@tmp_src) if File.exist?(@tmp_src)
		File.open(@tmp_src , 'w') do |file|
			File.open(@src) do |src_file|
				src_file.each_line do |line|
					file << line if @parser.compilable?(line) 
				end
			end
		end
	end

	def translate_labels
		line_number = 0
		iterate_file do |line|
			parsed = @parser.parse_line(line)
			if parsed[:type] == Parser::LABEL_SYMBOL
				@symbol_table[parsed[:values][0]] = line_number
			else
				line_number += 1
			end
		end
	end

	def translate_vars
		iterate_file do |line|
			parsed = @parser.parse_line(line)
			if parsed[:type] == Parser::VAR && !@symbol_table.key?(parsed[:values][0])
				@symbol_table[parsed[:values][0]] = @var_pointer 
				@var_pointer += 1
			end
		end
	end

	def handle_line(line, line_number)
		parsed = @parser.parse_line(line)
		values = parsed[:values]
		translated = case parsed[:type]
		when Parser::A_COMMAND
			Translator.translate_a_command(values[0], @symbol_table)
		when Parser::C_COMMAND
			Translator.translate_c_command(values[0], values[1], values[2], @symbol_table)
		when Parser::VAR
			Translator.translate_var(values[0], @symbol_table)
		else
			raise "Invalid translatable provided: #{line}"
		end
		translated
	end

	def iterate_file
		return unless block_given?
		File.open(@tmp_src) do |file|
			file.each_line do |line|
				yield line
			end
		end
	end
end