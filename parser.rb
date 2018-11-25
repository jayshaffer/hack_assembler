class Parser

    A_COMMAND = 'A_COMMAND'
    A_COMMAND_PATTERN = /^@(\d+)/

    C_COMMAND = 'C_COMMAND'
    C_COMMAND_PATTERN = %r{^(?:(M|D|MD|A|AM|AD|AMD)=)*
        (D\|A|D\|M|D&A|D&M|A-D|M-D|D-A|D-M|D\+A|D\+M|A-1|M-1|D-1|M\+1|A\+1|D\+1|-A|-M|-D|!M|!A|!D|M|A|D|-1|1|0)+
        (?:;([A-Z]{3}))*
    }x

    COMMENT = 'COMMENT'
    COMMENT_PATTERN = /^\/\/.*/ 

    LABEL_SYMBOL = 'LABEL_SYMBOL'
    LABEL_SYMBOL_PATTERN = /^\((.*)\)/

    VAR = 'VAR'
    VAR_PATTERN = /^@(.*)/

    WHITESPACE = 'WHITESPACE'
    WHITESPACE_PATTERN = /^\s+/

    def parse_line(line)
        line = prep_line(line)
        if whitespace?(line)
            return {type: WHITESPACE, values: nil}
        elsif comment?(line)
            return {type: COMMENT, values: nil}
        elsif a_command?(line)
            return parse_command(line, A_COMMAND_PATTERN, A_COMMAND)
        elsif c_command?(line)
            return parse_command(line, C_COMMAND_PATTERN, C_COMMAND)
        elsif var?(line)
            return parse_command(line, VAR_PATTERN, VAR)
        elsif label_symbol?(line)
            return parse_command(line, LABEL_SYMBOL_PATTERN, LABEL_SYMBOL)
        else
            return {}
        end
    end

    def compilable?(line)
        parsed = parse_line(line)
        usable_line?(line) && parsed[:type] != LABEL_SYMBOL
    end

    def usable_line?(line)
        parsed = parse_line(line)
        parsed[:type] == VAR ||
        parsed[:type] == A_COMMAND ||
        parsed[:type] == C_COMMAND ||
        parsed[:type] == LABEL_SYMBOL
    end

    def comment?(line)
        prep_line(line).match(COMMENT_PATTERN)
    end

    def var?(line)
        prep_line(line).match(VAR_PATTERN)
    end

    def a_command?(line)
        prep_line(line).match(A_COMMAND_PATTERN)
	end

    def c_command?(line)
        prep_line(line).match(C_COMMAND_PATTERN)
    end
    
    def label_symbol?(line)
        prep_line(line).match(LABEL_SYMBOL_PATTERN)
    end

    def whitespace?(line)
        line.match(WHITESPACE_PATTERN) || line.size == 0
    end

    private

    def parse_command(line, pattern, type)
        matches = line.strip.match(pattern)
        values = nil 
        if matches
            values = matches.captures
        else
            raise "Parser error: cannot parse #{line} into #{type}"
        end
        {
            type: type,
            values: values
        } 
    end

    def prep_line(line)
        line.strip
    end
end