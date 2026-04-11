# scanner.py
import sys
from token_types import TokenType

class Token:
    def __init__(self, token_type, lexeme, line, column):
        self.type = token_type
        self.lexeme = lexeme
        self.line = line
        self.column = column
    
    def __str__(self):
        return f"{self.line}:{self.column} {self.type.name} {self.lexeme}"
    
    def __repr__(self):
        return self.__str__()

class Scanner:
    def __init__(self, source_code):
        self.source = source_code
        self.tokens = []
        self.current = 0
        self.line = 1
        self.column = 1
        
        # Keywords
        self.keywords = {
            'int': TokenType.INT,
            'string': TokenType.STRING,
            'void': TokenType.VOID,
            'boolean': TokenType.BOOLEAN,
            'if': TokenType.IF,
            'else': TokenType.ELSE,
            'while': TokenType.WHILE,
            'for': TokenType.FOR,
            'return': TokenType.RETURN,
            'break': TokenType.BREAK,
            'Print': TokenType.PRINT,
            'true': TokenType.BOOLEAN_LITERAL,
            'false': TokenType.BOOLEAN_LITERAL
        }
    
    def peek(self, offset=0):
        pos = self.current + offset
        if pos < len(self.source):
            return self.source[pos]
        return '\0'
    
    def advance(self):
        if self.current < len(self.source):
            if self.source[self.current] == '\n':
                self.line += 1
                self.column = 1
            else:
                self.column += 1
            self.current += 1
    
    def skip_whitespace(self):
        while self.current < len(self.source) and self.source[self.current].isspace():
            self.advance()
    
    def skip_comment(self):
        if self.peek() == '/' and self.peek(1) == '/':
            while self.current < len(self.source) and self.source[self.current] != '\n':
                self.advance()
        elif self.peek() == '/' and self.peek(1) == '*':
            self.advance()  # skip /
            self.advance()  # skip *
            while self.current < len(self.source):
                if self.peek() == '*' and self.peek(1) == '/':
                    self.advance()  # skip *
                    self.advance()  # skip /
                    break
                self.advance()
    
    def scan_string(self):
        start_line = self.line
        start_col = self.column
        value = '"'
        
        self.advance()  # Skip opening quote
        
        while self.current < len(self.source) and self.source[self.current] != '"':
            if self.source[self.current] == '\\':
                value += self.source[self.current]
                self.advance()
                if self.current < len(self.source):
                    value += self.source[self.current]
                    self.advance()
            else:
                value += self.source[self.current]
                self.advance()
        
        if self.current < len(self.source):
            value += '"'
            self.advance()  # Skip closing quote
        
        return Token(TokenType.STRING_LITERAL, value, start_line, start_col)
    
    def scan_number(self):
        start_line = self.line
        start_col = self.column
        value = ""
        
        while self.current < len(self.source) and self.source[self.current].isdigit():
            value += self.source[self.current]
            self.advance()
        
        return Token(TokenType.INT_LITERAL, value, start_line, start_col)
    
    def scan_identifier(self):
        start_line = self.line
        start_col = self.column
        value = ""
        
        while (self.current < len(self.source) and 
               (self.source[self.current].isalnum() or self.source[self.current] == '_')):
            value += self.source[self.current]
            self.advance()
        
        token_type = self.keywords.get(value, TokenType.IDENTIFIER)
        return Token(token_type, value, start_line, start_col)
    
    def scan(self):
        while self.current < len(self.source):
            self.skip_whitespace()
            
            if self.current >= len(self.source):
                break
            
            # Skip comments
            if self.peek() == '/' and (self.peek(1) == '/' or self.peek(1) == '*'):
                self.skip_comment()
                continue
            
            char = self.source[self.current]
            
            # String literals
            if char == '"':
                self.tokens.append(self.scan_string())
            
            # Numbers
            elif char.isdigit():
                self.tokens.append(self.scan_number())
            
            # Identifiers and keywords
            elif char.isalpha() or char == '_':
                self.tokens.append(self.scan_identifier())
            
            # Two-character operators
            elif char == '=' and self.peek(1) == '=':
                self.tokens.append(Token(TokenType.EQUAL, '==', self.line, self.column))
                self.advance()
                self.advance()
            elif char == '!' and self.peek(1) == '=':
                self.tokens.append(Token(TokenType.NOT_EQUAL, '!=', self.line, self.column))
                self.advance()
                self.advance()
            elif char == '<' and self.peek(1) == '=':
                self.tokens.append(Token(TokenType.LESS_EQUAL, '<=', self.line, self.column))
                self.advance()
                self.advance()
            elif char == '>' and self.peek(1) == '=':
                self.tokens.append(Token(TokenType.GREATER_EQUAL, '>=', self.line, self.column))
                self.advance()
                self.advance()
            elif char == '&' and self.peek(1) == '&':
                self.tokens.append(Token(TokenType.AND, '&&', self.line, self.column))
                self.advance()
                self.advance()
            elif char == '|' and self.peek(1) == '|':
                self.tokens.append(Token(TokenType.OR, '||', self.line, self.column))
                self.advance()
                self.advance()
            
            # Single character tokens
            elif char == '+':
                self.tokens.append(Token(TokenType.PLUS, char, self.line, self.column))
                self.advance()
            elif char == '-':
                self.tokens.append(Token(TokenType.MINUS, char, self.line, self.column))
                self.advance()
            elif char == '*':
                self.tokens.append(Token(TokenType.MULTIPLY, char, self.line, self.column))
                self.advance()
            elif char == '/':
                self.tokens.append(Token(TokenType.DIVIDE, char, self.line, self.column))
                self.advance()
            elif char == '%':
                self.tokens.append(Token(TokenType.MODULO, char, self.line, self.column))
                self.advance()
            elif char == '=':
                self.tokens.append(Token(TokenType.ASSIGN, char, self.line, self.column))
                self.advance()
            elif char == '<':
                self.tokens.append(Token(TokenType.LESS_THAN, char, self.line, self.column))
                self.advance()
            elif char == '>':
                self.tokens.append(Token(TokenType.GREATER_THAN, char, self.line, self.column))
                self.advance()
            elif char == '!':
                self.tokens.append(Token(TokenType.NOT, char, self.line, self.column))
                self.advance()
            elif char == '(':
                self.tokens.append(Token(TokenType.LEFT_PAREN, char, self.line, self.column))
                self.advance()
            elif char == ')':
                self.tokens.append(Token(TokenType.RIGHT_PAREN, char, self.line, self.column))
                self.advance()
            elif char == '{':
                self.tokens.append(Token(TokenType.LEFT_BRACE, char, self.line, self.column))
                self.advance()
            elif char == '}':
                self.tokens.append(Token(TokenType.RIGHT_BRACE, char, self.line, self.column))
                self.advance()
            elif char == '[':
                self.tokens.append(Token(TokenType.LEFT_BRACKET, char, self.line, self.column))
                self.advance()
            elif char == ']':
                self.tokens.append(Token(TokenType.RIGHT_BRACKET, char, self.line, self.column))
                self.advance()
            elif char == ';':
                self.tokens.append(Token(TokenType.SEMICOLON, char, self.line, self.column))
                self.advance()
            elif char == ',':
                self.tokens.append(Token(TokenType.COMMA, char, self.line, self.column))
                self.advance()
            else:
                print(f"Unexpected character '{char}' at line {self.line}, column {self.column}")
                self.advance()
        
        self.tokens.append(Token(TokenType.EOF, "", self.line, self.column))
        return self.tokens