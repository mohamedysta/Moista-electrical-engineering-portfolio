# parser.py (complete version)
from token_types import TokenType
from scanner import Scanner, Token

class Parser:
    def __init__(self, tokens, source_lines=None):
        self.tokens = tokens
        self.current = 0
        self.source_lines = source_lines or []
        self.output_buffer = []
        self.has_error = False
    
    def parse(self):
        self.output_buffer.append("\nProgram:")
        
        try:
            while not self.check(TokenType.EOF):
                self.parse_declaration()
            
            # Only print output if no errors occurred
            if not self.has_error:
                for line in self.output_buffer:
                    print(line)
        except:
            # Error already handled in error() method
            pass
    
    def add_output(self, text):
        self.output_buffer.append(text)
    
    def peek(self):
        if self.current < len(self.tokens):
            return self.tokens[self.current]
        return self.tokens[-1]
    
    def previous(self):
        return self.tokens[self.current - 1]
    
    def advance(self):
        if self.current < len(self.tokens) - 1:
            self.current += 1
        return self.previous()
    
    def check(self, token_type):
        if self.current >= len(self.tokens):
            return False
        return self.peek().type == token_type
    
    def match(self, *types):
        for token_type in types:
            if self.check(token_type):
                self.advance()
                return True
        return False
    
    def consume(self, token_type, message):
        if self.check(token_type):
            return self.advance()
        self.error(message)
    
    def error(self, message):
        self.has_error = True
        token = self.peek()
        
        print(f"\n*** Error line {token.line}.")
        if self.source_lines and token.line <= len(self.source_lines):
            error_line = self.source_lines[token.line - 1]
            print(error_line)
            spaces = " " * (token.column - 1)
            print(spaces + "^")
        print("*** syntax error")
        
        import sys
        sys.exit(0)
    
    def parse_declaration(self):
        type_token = self.advance()
        id_token = self.consume(TokenType.IDENTIFIER, "Expected identifier")
        
        if self.check(TokenType.LEFT_PAREN):
            self.parse_function(type_token, id_token)
        else:
            self.parse_global_var(type_token, id_token)
    
    def parse_global_var(self, type_token, id_token):
        self.add_output(f"{id_token.line} \t VarDecl:")
        self.add_output(f" \t\t Type: {type_token.lexeme}")
        self.add_output(f"{id_token.line} \t\t Identifier: {id_token.lexeme}")
        
        while self.match(TokenType.COMMA):
            next_id = self.consume(TokenType.IDENTIFIER, "Expected identifier")
            self.add_output(f"{next_id.line} \t VarDecl:")
            self.add_output(f" \t\t Type: {type_token.lexeme}")
            self.add_output(f"{next_id.line} \t\t Identifier: {next_id.lexeme}")
        
        self.consume(TokenType.SEMICOLON, "Expected ';'")
    
    def parse_function(self, type_token, id_token):
        self.add_output(f"{id_token.line} \t FnDecl:")
        self.add_output(f" \t\t (return type) Type: {type_token.lexeme}")
        self.add_output(f"{id_token.line} \t\t Identifier: {id_token.lexeme}")
        
        self.consume(TokenType.LEFT_PAREN, "Expected '('")
        
        if not self.check(TokenType.RIGHT_PAREN):
            self.parse_parameters()
        
        self.consume(TokenType.RIGHT_PAREN, "Expected ')'")
        
        self.add_output(" \t\t (body) StmtBlock:")
        self.consume(TokenType.LEFT_BRACE, "Expected '{'")
        
        self.parse_statement_block()
        
        self.consume(TokenType.RIGHT_BRACE, "Expected '}'")
    
    def parse_parameters(self):
        param_type = self.advance()
        
        if self.check(TokenType.RIGHT_PAREN) or self.check(TokenType.COMMA):
            self.error("Missing parameter name")
        
        param_name = self.consume(TokenType.IDENTIFIER, "Expected parameter name")
        
        self.add_output(f"{param_name.line} \t\t (formals) VarDecl:")
        self.add_output(f" \t\t\t Type: {param_type.lexeme}")
        self.add_output(f"{param_name.line} \t\t\t Identifier: {param_name.lexeme}")
        
        while self.match(TokenType.COMMA):
            param_type = self.advance()
            param_name = self.consume(TokenType.IDENTIFIER, "Expected parameter name")
            
            self.add_output(f"{param_name.line} \t\t (formals) VarDecl:")
            self.add_output(f" \t\t\t Type: {param_type.lexeme}")
            self.add_output(f"{param_name.line} \t\t\t Identifier: {param_name.lexeme}")
    
    def parse_statement_block(self):
        while not self.check(TokenType.RIGHT_BRACE) and not self.check(TokenType.EOF):
            self.parse_statement()
    
    def parse_statement(self):
        # Variable declaration
        if self.check(TokenType.INT) or self.check(TokenType.STRING) or \
           self.check(TokenType.BOOLEAN) or self.check(TokenType.VOID):
            type_token = self.advance()
            id_token = self.consume(TokenType.IDENTIFIER, "Expected identifier")
            
            self.add_output(f"{type_token.line} \t\t\t VarDecl:")
            self.add_output(f" \t\t\t\t Type: {type_token.lexeme}")
            self.add_output(f"{id_token.line} \t\t\t\t Identifier: {id_token.lexeme}")
            
            self.consume(TokenType.SEMICOLON, "Expected ';'")
        
        # Print statement
        elif self.check(TokenType.PRINT):
            self.advance()
            self.add_output(" \t\t\t PrintStmt:")
            
            self.consume(TokenType.LEFT_PAREN, "Expected '('")
            
            arg_token = self.peek()
            if self.check(TokenType.IDENTIFIER):
                self.add_output(f"{arg_token.line} \t\t\t\t (args) FieldAccess:")
                self.add_output(f"{arg_token.line} \t\t\t\t\t Identifier: {arg_token.lexeme}")
                self.advance()
            elif self.check(TokenType.STRING_LITERAL):
                self.add_output(f"{arg_token.line} \t\t\t\t (args) StringConstant: {arg_token.lexeme}")
                self.advance()
            elif self.check(TokenType.INT_LITERAL):
                self.add_output(f"{arg_token.line} \t\t\t\t (args) IntConstant: {arg_token.lexeme}")
                self.advance()
            
            self.consume(TokenType.RIGHT_PAREN, "Expected ')'")
            self.consume(TokenType.SEMICOLON, "Expected ';' after Print statement")
        
        # Return statement
        elif self.check(TokenType.RETURN):
            return_token = self.advance()
            self.add_output(f"{return_token.line} \t\t\t ReturnStmt:")
            
            self.parse_return_expr()
            self.consume(TokenType.SEMICOLON, "Expected ';'")
        
        # Assignment or expression
        elif self.check(TokenType.IDENTIFIER):
            self.parse_assignment()
        
        else:
            self.advance()
    
    def parse_assignment(self):
        id_token = self.advance()
        line = id_token.line
        
        if self.match(TokenType.ASSIGN):
            self.add_output(f"{line} \t\t\t AssignExpr:")
            self.add_output(f"{line} \t\t\t\t  FieldAccess:")
            self.add_output(f"{line} \t\t\t\t\t Identifier: {id_token.lexeme}")
            self.add_output(f"{line} \t\t\t\t Operator: =")
            
            # Check what's being assigned
            if self.check(TokenType.STRING_LITERAL):
                str_token = self.advance()
                self.add_output(f"{line} \t\t\t\t StringConstant: {str_token.lexeme}")
            elif self.check(TokenType.INT_LITERAL):
                int_token = self.advance()
                self.add_output(f"{line} \t\t\t\t IntConstant: {int_token.lexeme}")
            elif self.check(TokenType.IDENTIFIER):
                next_token = self.peek_next()
                if next_token and next_token.type == TokenType.LEFT_PAREN:
                    # Function call
                    self.parse_call_expr(line)
                else:
                    # Just identifier or expression
                    self.parse_expression(line)
            else:
                self.error("Expected expression after assignment")
        
        self.consume(TokenType.SEMICOLON, "Expected ';'")
    
    def peek_next(self):
        if self.current + 1 < len(self.tokens):
            return self.tokens[self.current + 1]
        return None
    
    def parse_call_expr(self, line):
        func_name = self.advance()
        
        self.add_output(f"{line} \t\t\t\t  Call:")
        self.add_output(f"{line} \t\t\t\t\t Identifier: {func_name.lexeme}")
        
        self.consume(TokenType.LEFT_PAREN, "Expected '('")
        
        # Parse arguments
        if not self.check(TokenType.RIGHT_PAREN):
            if self.check(TokenType.INT_LITERAL):
                arg = self.advance()
                self.add_output(f"{line} \t\t\t\t\t (args) IntConstant: {arg.lexeme}")
            elif self.check(TokenType.IDENTIFIER):
                arg = self.advance()
                self.add_output(f"{line} \t\t\t\t\t (args) FieldAccess:")
                self.add_output(f"{line} \t\t\t\t\t\t Identifier: {arg.lexeme}")
            
            while self.match(TokenType.COMMA):
                if self.check(TokenType.INT_LITERAL):
                    arg = self.advance()
                    self.add_output(f"{line} \t\t\t\t\t (args) IntConstant: {arg.lexeme}")
                elif self.check(TokenType.IDENTIFIER):
                    arg = self.advance()
                    self.add_output(f"{line} \t\t\t\t\t (args) FieldAccess:")
                    self.add_output(f"{line} \t\t\t\t\t\t Identifier: {arg.lexeme}")
        
        self.consume(TokenType.RIGHT_PAREN, "Expected ')'")
    
    def parse_expression(self, line):
        if self.check(TokenType.INT_LITERAL):
            num = self.advance()
            self.add_output(f"{line} \t\t\t\t IntConstant: {num.lexeme}")
        elif self.check(TokenType.IDENTIFIER):
            left = self.advance()
            
            if self.match(TokenType.PLUS, TokenType.MINUS, TokenType.MULTIPLY, TokenType.DIVIDE):
                op = self.previous()
                self.add_output(f"{line} \t\t\t\t ArithmeticExpr:")
                self.add_output(f"{line} \t\t\t\t\t  FieldAccess:")
                self.add_output(f"{line} \t\t\t\t\t\t Identifier: {left.lexeme}")
                self.add_output(f"{line} \t\t\t\t\t Operator: {op.lexeme}")
                
                if self.check(TokenType.IDENTIFIER):
                    right = self.advance()
                    self.add_output(f"{line} \t\t\t\t\t  FieldAccess:")
                    self.add_output(f"{line} \t\t\t\t\t\t Identifier: {right.lexeme}")
                elif self.check(TokenType.INT_LITERAL):
                    right = self.advance()
                    self.add_output(f"{line} \t\t\t\t\t IntConstant: {right.lexeme}")
            else:
                self.add_output(f"{line} \t\t\t\t  FieldAccess:")
                self.add_output(f"{line} \t\t\t\t\t Identifier: {left.lexeme}")
    
    def parse_return_expr(self):
        line = self.previous().line
        
        if self.check(TokenType.INT_LITERAL):
            num = self.advance()
            self.add_output(f"{line} \t\t\t\t IntConstant: {num.lexeme}")
        elif self.check(TokenType.IDENTIFIER):
            left = self.advance()
            
            if self.check(TokenType.PLUS) or self.check(TokenType.MINUS) or \
               self.check(TokenType.MULTIPLY) or self.check(TokenType.DIVIDE):
                op = self.advance()
                
                self.add_output(f"{line} \t\t\t\t ArithmeticExpr:")
                self.add_output(f"{line} \t\t\t\t\t  FieldAccess:")
                self.add_output(f"{line} \t\t\t\t\t\t Identifier: {left.lexeme}")
                self.add_output(f"{line} \t\t\t\t\t Operator: {op.lexeme}")
                
                if self.check(TokenType.IDENTIFIER):
                    right = self.advance()
                    self.add_output(f"{line} \t\t\t\t\t  FieldAccess:")
                    self.add_output(f"{line} \t\t\t\t\t\t Identifier: {right.lexeme}")
                elif self.check(TokenType.INT_LITERAL):
                    num = self.advance()
                    self.add_output(f"{line} \t\t\t\t\t IntConstant: {num.lexeme}")
            else:
                self.add_output(f"{line} \t\t\t\t  FieldAccess:")
                self.add_output(f"{line} \t\t\t\t\t Identifier: {left.lexeme}")