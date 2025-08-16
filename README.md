# Compiler for a C-like Language

A custom compiler designed to process a C-like programming language, from lexical analysis to optimized code generation.  
Built using **Flex**, **Bison**, and **C/C++**, this project demonstrates the complete compiler pipeline along with optimization techniques.

## Features

### Lexical Analysis
- Implemented using **Flex** to tokenize source code into identifiers, keywords, operators, and literals.

### Syntax Analysis (Parsing)
- Built with **Bison** to parse tokens according to the language grammar and generate an **Abstract Syntax Tree (AST)**.

### Semantic Analysis
- Enforces type checking, scope resolution, and detection of semantic errors.

### Intermediate Code Generation
- Generates **Three-Address Code (TAC)** from AST for further processing.

### Code Optimization
- Implements live variable analysis, dead code elimination, and other optimizations for efficiency.

### Target Code Generation
- Translates optimized TAC into final assembly-like instructions.

## Tools & Technologies

- **Languages:** C, C++  
- **Lexer Generator:** Flex  
- **Parser Generator:** Bison  
- **Build System:** Make  
- **OS Tested On:** Linux (WSL Compatible)

## Project Structure

```
project/
│
├── a3.l               # Lexical analysis rules for Mini-C
├── a3.y               # Grammar and parsing rules for Mini-C
├── tac.l              # Lexical analysis rules for TAC
├── tac.y              # Grammar and parsing rules for TAC
├── Makefile           # Automates compiler build
└── README.md          # Project documentation
```

## How to Build & Run

### Prerequisites
Make sure you have the following installed:
- flex  
- bison  
- gcc (or any C compiler)  
- make  

### Build
```bash
make
```

### Run
```bash
./compiler <source_file>
```

**Example:**
```bash
./compiler examples/sample_code.cl
```

### Example

**Input:**
```c
int a = 10;
int b = 20;
int c = a + b;
```

**Output TAC:**
```
t1 = 10
t2 = 20
t3 = t1 + t2
```

## Future Improvements
- Support for arrays and structures  
- Advanced loop optimizations  
- Backend for actual machine code generation  
