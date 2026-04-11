# main.py
import sys
from scanner import Scanner
from parser import Parser

def main():
    if len(sys.argv) != 2:
        print("Usage: python main.py <input_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    
    try:
        with open(input_file, 'r') as f:
            source_code = f.read()
        
        # Store source lines for error reporting
        source_lines = source_code.split('\n')
        
        # Run scanner
        scanner = Scanner(source_code)
        tokens = scanner.scan()
        
        # Run parser
        parser = Parser(tokens, source_lines)
        parser.parse()
        
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.")
        sys.exit(1)

if __name__ == "__main__":
    main()