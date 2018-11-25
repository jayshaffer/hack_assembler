class Translator
    C_COMMAND_COMP_MAP_A_ZERO = {
        "0"     => "101010",
        "1"     => "111111",
        "-1"    => "111010",
        "D"     => "001100",
        "A"     => "110000",
        "!D"    => "001101",
        "!A"    => "110001",
        "-D"    => "001111",
        "-A"    => "110011",
        "D+1"   => "011111",
        "A+1"   => "110111",
        "D-1"   => "001110",
        "A-1"   => "110010",
        "D+A"   => "000010",
        "D-A"   => "010011",
        "A-D"   => "000111",
        "D&A"   => "000000",
        "D|A"   => "010101"
    }.freeze

    C_COMMAND_COMP_MAP_A_ONE = {
        "M"     => "110000",
        "!M"    => "110001",
        "-M"    => "110011",
        "M-1"   => "110010",
        "M+1"   => "110111",
        "D+M"   => "000010",
        "D-M"   => "010011",
        "M-D"   => "000111",
        "D&M"   => "000000",
        "D|M"   => "010101"
    }.freeze

    C_COMMAND_DEST_MAP = {
        nil     => "000",
        "M"     => "001",
        "D"     => "010",
        "MD"    => "011",
        "A"     => "100",
        "AM"    => "101",
        "AD"    => "110",
        "AMD"   => "111"
    }.freeze

    C_COMMAND_JUMP_MAP = {
        nil     => "000",
        "JGT"   => "001",
        "JEQ"   => "010",
        "JGE"   => "011",
        "JLT"   => "100",
        "JNE"   => "101",
        "JLE"   => "110",
        "JMP"   => "111"
    }.freeze

    def self.translate_a_command(symbol, symbol_table)
        '%016b' % symbol
    end

    def self.translate_c_command(dest, comp, jump, symbol_table)
        result = "111"
        comp_mapped = C_COMMAND_COMP_MAP_A_ZERO[comp]
        if comp_mapped
            result << "0#{comp_mapped}"
        else
            result << "1#{C_COMMAND_COMP_MAP_A_ONE[comp]}"
        end
        result << C_COMMAND_DEST_MAP[dest] 
        result << C_COMMAND_JUMP_MAP[jump]
        result
    end

    def self.translate_var(var, symbol_table)
        symbol_match = symbol_table[var]
        raise "Failed to find symbol for var #{var}" if symbol_match.nil?
        '%016b' % symbol_match
    end
end