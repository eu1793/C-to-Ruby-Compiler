# C to Ruby Compiler

## Introductionn

This is an implementation of a Flex/Bison based compiler for parsing codes from C to Ruby. For this implementation, we will use the following tools:

* **[Ubuntu 17.04][1]** (or similar Linux system)
* GCC (6.3.0)
* Flex (2.6.1)
* Bison (3.0.4)
* Git (2.11.0)

## Tools installation on Ubuntu 17.04 (from terminal)

### GCC instalation
```
$ sudo apt install gcc
```

### Flex installation
```
$ sudo apt install flex
```

### Bison installation
```
$ sudo apt install bison
```

### Git installation
```
$ sudo apt install git
```

## C-to-Ruby Compiler installation

### Clone this repository into your home folder and move into it
```
$ git clone https://github.com/eu1793/C-to-Ruby-Compiler
```
```
$ cd C-to-Ruby-Compiler
```

### Once inside of C-to-Ruby-Compiler, compile the source code
```
$ make
```

### Once compiled, remove unnecessary files
```
$ make clean
```

## C-to-Ruby Compiler use

After the installation of the C-to-Ruby Compiler, a executable file called **CtoRuby** will appear into the C-to-Ruby-Compiler folder


### To make use of the compiler, simply run this command from the C-to-Ruby-Compiler folder:
```
$ ./CtoRuby code.c code.rb
```
* **code.c** is an existing C code file located in the **C-to-Ruby-Compiler** folder. It can be any C code file of your preference
* **code.rb** will be the generated Ruby code from **code.c**

## Examples of use

* This will create a Ruby code named **main.rb** from the C code **main.c**
```
$ ./CtoRuby main.c main.rb
```
* The new file will be located in the same folder as **CtoRuby**

## Codes: Before and after example

* Counter.c
```C
int main() {
    int i;
    i=0;
    while(i<100) {
        i++;
    }
}
```

* Counter.rb
```Ruby
def main()
        i = 0
        while i < 100 do
                i+=1
        end
end

main()
```

## Functionalities

* Loops: WHILE
* Conditional statements: IF, ELSE, SWITCH
* Nesting structures
* Functions and procedures declaration
* Function calls
* Unidimensional and multidimensional arrays
* Variable declaratinos
* Arithmetic expresions
* Error checks and recovery
* Asignations

## Weaknesses

* Scoping
* Repeated variables check
* Not recognizes declaration with initialization of variables (solution: separate initialization)
* All functions must be above **main**
* Not recognizes **static**, **extern**, **const** and **register** for more practicity

## Not supported features

* Pointers: the compiler does not support the use of pointers and any dependences from it
* Input and output: due to the absence of the input/output functions declarations (present in external libraries of Ruby) that may run into semantic errors
* Pre-processor features: the processing of external libraries from the C pre-processor is not supported due to a very important increase of difficulty, because it will imply the recursive processing of all of these functions and libraries
* Matrices: As in Ruby for the declaration and the management of matrices it is necessary to include a library called "matrices", we use a Ruby unique quality that can handle a list of a list, and as the access to its elements is similar to a matrix, we could simulate the same with it.

## Errors checks and recovery methods

The compiler is equipped with a semantic and syntactic error detector. For the syntactic errors there were implemented additionals productions that detects any malfunction in a certain grammar content, which allows us to continue analyzing the rest of the input without stopping at the very first error

## How we choose C and Ruby

The initial thought was to build a compiler that starts from the C Language, due to our wide knowledge in C. The decision to choose Ruby starts from the fact that Ruby is one of the most simple and beautiful programming languages and it has a syntaxis not too different form C

## Errors messages

All error messages will be at the bottom of each **...__error.c** file

## Makefile content

```
all: flex bison gcc

flex:
	flex lexical.l

bison:
	bison -yd syntactical.y

gcc:
	gcc lex.yy.c y.tab.c -o CtoRuby

clean:
	rm lexical.l syntactical.y lex.yy.c y.tab.c y.tab.h makefile
```

**This document was made by Eusebio Gomez and Laura Vaesken on June 2017**

[1]:https://www.ubuntu.com/download/desktop/contribute/?version=17.04&architecture=amd64
