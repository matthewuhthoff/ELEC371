/* for standalone testing of this file by itself using the simulator,
   keep the following line, but for in-lab activity with the Monitor Program
   to have a multi-file project, comment out the following line */

//#define TEST_CHARIO


/* no #include statements should be required, as the character I/O functions
   do not rely on any other code or definitions (the .h file for these
   functions would be included in _other_ .c files) */


/* because all character-I/O code is in this file, the #define statements
   for the JTAG UART pointers can be placed here; they should not be needed
   in any other file */

#define JTAG_UART_DATA (volatile unsigned int *)0x10001000
#define JTAG_UART_STATUS (volatile unsigned int *)0x10001004

/* place the full function definitions for the character-I/O routines here */

// Hello old friend... Miss me?
void PrintChar(unsigned int character) {
    unsigned int status;

    // this is a reverse while loop
    // do is ran first then while loop checks
    // if while is true, repeat what's in do
    // we call this an "awaiter" if you have done javascript
    do {
        status = *JTAG_UART_STATUS;
        status = (status & 0xFFFF0000);
    } while (status == 0);
    
    *JTAG_UART_DATA = character; // write to JTAG UART console
}

void PrintString(char *str) {
    char character; // this is a cache of the current character we selected from memory

    while(1) {
        character = *str; // read from the pointer toward the address of the string we are printing
        if (character == '\0') { // looks like we have nothing more to print
            break;
        } else {
            PrintChar(character); // print the character we read from
            str = str + 1; // offset the pointer to the next character in memory
        }
    }
}

void PrintHex(unsigned int hex) {
    // Identifiy which value it is, like if it's 0-9 or A-F
    if (hex >= 10) {
        hex = hex - 10 + 'A';
    } else {
        hex = hex + '0';
    }
    PrintChar(hex); // Print it as a character to console
}

void PrintHexString(char *hex) {
    PrintChar('0');
    PrintChar('x');
    // Hexs are generally 8 digits in this system, but I'll change that later on...
    int i = 0;
	for (; i<7; i++) {
        PrintHex(*hex & 0xF);
        hex = hex + 1;
    }
    PrintChar('\n');
}

#ifdef TEST_CHARIO

/* this portion is conditionally compiled based on whether or not
   the symbol exists; it is only for standalone testing of the routines
   using the simulator; there is a main() routine in lab4.c, so
   for the in-lab activity, the following code would conflict with it */

int main (void)
{

  /* place calls here to the various character-I/O routines
     to test their behavior, e.g., PrintString("hello\n");  */

   PrintChar('I');
   PrintChar('\n');
   PrintString("I love cats!\n");
   PrintHex(0xA);
   PrintChar('\n');
   PrintHexString(0x1234ABCD);

  return 0;
} 

#endif /* TEST_CHARIO */
