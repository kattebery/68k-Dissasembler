*-----------------------------------------------------------
* Title      :Disassembler.Main
* Written by :Blake Hashimoto
* Date       :4/29/2016
* Description:
*-----------------------------------------------------------
    
*--------------------------------------------*
* Program Input. Read user input start and   *
* ending values                              *
*--------------------------------------------*

*----Display input message for mem start-----*
INPUT_START
*    BRA         TEST
    LEA         M_INPUT_START,A1      *load message
    MOVE.B      #14,D0          *display string
    TRAP        #15             *output string
*----Receive User Input ------
    MOVE.L      #$0300,A1       *set address of register A1 for string
    MOVE.B      #2,D0           *input string into A1 Trap
    TRAP        #15             *input string from user
    BSR         READ_CHAR       *check for valid input
    MOVE.L      D3,MEM_START    *put the starting address in memory
    CMP         #0,D4           *check the result register (D4)
    BEQ         INPUT_END       *valid value. read the ending value
    BRA         INPUT_START     *invalid value. try inputting start value again    
    
*----Display input message for mem end-----*
INPUT_END
    LEA         M_INPUT_END,A1  *load message
    MOVE.B      #14,D0          *display string
    TRAP        #15             *output string
*----Receive User Input ------*
    MOVE.L      #$0300,A1       *set address of register A1 for string
    MOVE.B      #2,D0           *input string into A1 Trap
    TRAP        #15             *input string from user
    BSR         READ_CHAR       *check for valid input
    MOVE.L      D3,MEM_END      *put ending address into memory
    CMP         #0,D4           *check the result register (D4)
    BEQ         READ_MEMORY     *valid value. read the ending value
    BRA         INPUT_END       *invalid value. try inputting start value again    
    
GET_NEXT_INPUT
    RTS

*----make sure that start value is valid----*
READ_CHAR                       *verify that string is valid (all hexadecimal digits)
    CLR         D3              *D3 will act as the total result
    MOVE.L      A1,A4           *the stop address
    MOVE.B      #6,D2           *put 6 in D2
    ADD.W       D2,A4           *A4 is now the stop address(A4)
    
REMOVE_ZEROES
    CLR.L       D1              *D1 will act as the temporary value
    MOVE.B      (A1),D1         *read the byte from string
    MOVE.B      #$30,D2         *put ascii zero in D2
    CMP.B       D2,D1           *compare ascii zero and value of D1
    BEQ         REMOVE_ZERO     *skip over that character   
    BRA         READ_CHAR_LOOP  *begin converting characters to numerical values
REMOVE_ZERO
    ADD.L       #1,A1           *increment string start address
    ADD.L       #1,A4           *increment string end address
    BRA         REMOVE_ZEROES   *loop back and keep removing zeroes
*----Convert String To Hex-----*
READ_CHAR_LOOP     
    CLR.L       D1              *D1 will act as the temporary value
    MOVE.B      (A1),D1         *read the byte from string
*----check if the value is exaclty 00 (NULL)
    CMP         #0,D1           *compare 00 (NULL) and the byte ascii value in D1
    BEQ         GET_NEXT_INPUT    *if you reached the end of the string, end loop
    
    MOVE.B      #$30,D2         *put ascii zero in D2
    CMP.B       D2,D1           *compare ascii zero and value of D1
    BLT         INVALID_CHAR_ERROR *branch on invalid (too small) ascii value   
*------Result is greater than ascii 0--------*
    MOVE.B      #$66,D2         *put ascii f in D2
    CMP.B       D2,D1           *compare ascii f and value of D1
    BGT.B       INVALID_CHAR_ERROR *branch on invalid ascii value
*------Result is between ascii 0 and f---------*
    MOVE.B      #$61,D2         *put ascii a in D2
    CMP.B       D2,D1           *compare ascii a and value of D1
    BGE         VALID_LETTER_LC *value is between a and f. Loop back.
    
    MOVE.B      #$39,D2         *put ascii 9 in D2
    CMP.B       D2,D1           *compare ascii 9 and value of D1
    BLE         VALID_NUMBER    *value between 0 and 9. Loop back.

    MOVE.B      #$41,D2         *put ascii A into D2
    CMP.B       D2,D1           *compare ascii A and value of D1
    BLT         INVALID_CHAR_ERROR    *value between 9 and A (Invalid)
    
    MOVE.B      #$46,D2         *put ascii F into D2
    CMP.B       D2,D1           *compare ascii F and value of D1
    BGT         INVALID_CHAR_ERROR    *value between F and a (Invalid)
         
    BRA         VALID_LETTER_UC *value is between A and F        
INVALID_CHAR_ERROR   
    LEA         M_INVALID,A1    *load error message
    MOVE.B      #14,D0          *display string trap
    TRAP        #15             *output error message
    MOVE.B      #1,D4           *put invalid output in result register
    RTS
VALID_NUMBER
    SUB.B       #$30,D1         *get actual value from ascii value
    BRA         VALID_CHAR      *read the next char in string
VALID_LETTER_UC
    SUB.B       #$37,D1         *get actual value from ascii value
    BRA         VALID_CHAR      *read the next char in string    
VALID_LETTER_LC
    SUB.B       #$57,D1         *get actual value from ascii value
    BRA         VALID_CHAR      *read the next char in string   
VALID_CHAR
    MOVE.B      #0,D4           *return valid value entry in D4    
    LSL.L       #4,D3           *put hex digit in proper place
    ADD.L       D1,D3           *put new total in D3
    ADD.L       #1,A1           *increment address
    CMP         A1,A4           *if A1 > A4
    BGT         READ_CHAR_LOOP  *begin converting to float    
    RTS                         *loop back to INPUT_START || INPUT_END   
   
TEST
    MOVE.L      #$3000,MEM_START
    MOVE.L      #$3300,MEM_END
READ_MEMORY   
    MOVEA.L     MEM_START,A2    *A2 will be the starting/current address
    MOVEA.L     MEM_END,A3      *A3 will act as the ending address
    
VALIDATE_START_END
    MOVE.L      A2,D1           *copy start address into D1
    MOVE.L      A3,D2           *copy end address into D2
    CMP         D1,D2           *compare start and end values
    BEQ         EQUAL_ERROR     *Start address is equal to end address
    BLT         SWAP_VALUES     *Start address is larger than end address
    BRA         PRE_READ_MEMORY *begin reading memory
    
EQUAL_ERROR
    LEA         M_EQUAL,A1      *load error message
    MOVE.B      #14,D0          *display string trap
    TRAP        #15             *output error message
    BRA         INPUT_START     *restart program (request ui again)
    
SWAP_VALUES
    MOVE.L      MEM_START,D1    *put starting address in D1
    MOVE.L      MEM_END,D2      *put ending address in D2
    MOVE.L      D2,MEM_START    *swap the two values in memory
    MOVE.L      D1,MEM_END
    MOVEA.L     D2,A2           *A2 will be the starting/current address
    MOVEA.L     D1,A3           *A3 will act as the ending address
PRE_READ_MEMORY
    MOVE.L      A2,A6           *A6 will act as the current address for Data               
READ_MEMORY_LOOP
    MOVE.L      MEM_END,A3        *put ending address in A3
    CMP         A2,A3             *compare the incrementing address and the end address
    BLT         CONTINUE_YN       *stop if the end address is reached
    
    ROR         #8,D6               *select correct byte
    CMP.B       #30,D6              *see if maximum lines printed
    BGE         PRESS_TO_CONTINUE
    ROL         #8,D6   
READ_MEMORY_CONT                    *continue reading memory (if branched)  
    MOVE.B      (A2)+,D0          *get the value from incrementing address 
    LSL.W       #8,D0             *make room for the next byte of A2
    MOVE.B      (A2),D0          *copy the rest of A2 to D0  
    SUB.L       #1, A2
    LEA         STRING_START,A3   *A3 will act as the string address  
    BRA         VERIFY_OPCODE
    
    
        
*VERIFY_OPCODE
*-------------------------------------*
*BEGIN
*D0 will contain word with decodable opcode
*A2 will act as the current address
*if at any time the result is not an opcode,
*branch to "INVALID_OPCODE"
*-----Put opcode decode here----------*
*END
*A7 will be the address of the string that opcode is saved to
*A6 will be the start of the DATA address
*-------------------------------------*

EFFECTIVE_ADDRESSING
*-------------------------------------*
*BEGIN
*D0 will contain word with decodable opcode
*A2 will act as the current address
*if at any time the result is not an opcode,
*branch to "INVALID_OPCODE"
*-----Put opcode decode here----------*
*END
*A7 will be the address of the string that opcode is saved to 
*A5 will be the start of the DATA address
*-------------------------------------*


CONTINUE_YN
    LEA         M_FINISHED,A1       *print out finished reading address
    MOVE.B      #14,D0
    TRAP        #15
    LEA         M_CONTINUE,A1        *ask the user if they want to read again
    MOVE.B      #14,D0
    TRAP        #15
    MOVE.B      #5,D0               *get user input
    TRAP        #15
    CMP.B       #89,D1              *compare user input and ascii 'Y'
    BEQ         RESTART             *
    CMP.B       #121,D1             *compare user input with ascii 'y'
    BEQ         RESTART
    BRA         END
    
PRESS_TO_CONTINUE
    MOVE.B      #00,D6              *reset counter
    ROL.L       #8,D6               *put byte back in place
    LEA         M_PRESS_CONT,A1     *load press key to continue messageu
    MOVE.B      #14,D0              *load into D0
    TRAP        #15                 *display message
    MOVE.B      #5,D0               *read single character from keyboard
    TRAP        #15    
    BSR         IM_NEW_LINE            *add new line
    BRA         READ_MEMORY_CONT    *continue reading loop
    
INCREMENT_LINE
    ROR.L       #8,D6               *select correct byte
    ADD.B       #1,D6               *increment counter
    ROL.L       #8,D6               *put byte back in place
    RTS 
    
*word != opcode
INVALID_OPCODE
    CMP.B       #8,D6               *check the loop increment counter
    BLT         INVALID_OPCODE_CONT *less than long length. continue       
    BSR         PRINT_DATA          *long amount of data. print it.
    BRA         READ_MEMORY_LOOP    *read the next byte
INVALID_OPCODE_CONT  
    ADD.L       #1,A2               *increment current address  
    ADD.B       #1,D6               *increment counter
    BRA         READ_MEMORY_LOOP    *data cap not reached. read next byte.    
    
PRINT_DATA
    MOVE.B      #00,D6              *reset the increment counter
    BSR         PRINT_DATA_ADDRESS       *print the data address
    BSR         TAB                 *insert a space
    BSR         DATA                *print 'DATA'       
    BSR         PRINT_DATA_LOOP     *print the data
    BSR         INCREMENT_LINE      *increment line counter (line was printed)
    RTS

PRINT_DATA_ADDRESS
    MOVE.L      A6,D4               *put the address in D4
    CLR         D3                  *counter for long
    BRA         PRINT_ADDRESS_LOOP
*print whatever's in D1
PRINT_ADDRESS
    MOVE.L      A6,D4               *put the address in D4
    CLR         D3                  *counter for long
    MOVE.L      A2, A6
    
PRINT_ADDRESS_LOOP
    CMP         #4,D3               *if long reached
    BGE         RETURN_TO_SUBROUTINE *exit loop
    ROL.L       #8,D4               *put ending byte at beginning
    MOVE.B      D4,D1               *put byte in D1 for printing
    BSR         OUTPUT_D1B          *print the first byte of D1
    ADD.B       #1,D3               *increment D3 (loop counter)
    BRA         PRINT_ADDRESS_LOOP  *repeat loop         
         
PRINT_DATA_LOOP
    MOVE.B      (A6)+,D1            *get the data
    MOVE.B      D1,D2               *copy the data to D2
    CMP.L       A2,A6               *if current address reached
    BGT         END_PRINT_DATA_LOOP *continue reading addresses 
                                    *otherwise keep printing the data
    BSR         OUTPUT_D1B          *print byte in D1 in hex
    *---print a space----*
    BSR         IM_SPACE               *print a space                                
    BRA         PRINT_DATA_LOOP     *repeat loop

END_PRINT_DATA_LOOP
    MOVE.L      A2,A6               *set new address for data/opcode
    BSR         IM_NEW_LINE            *end line
    RTS                             *repeat loop   
 
OUTPUT_D1B
    *print the left character
    MOVE.B      D1,D2               *copy D1 to D2
    LSR.B       #4,D1               *get rid of right nibble  
    BSR         CONVERT_TO_ASCII    *convert value in D1, to ascii
    BSR         OUTPUT_CHAR         *print the char in D1
    *print the right character
    LSL.B       #4,D2               *get rid of left nibble
    LSR.B       #4,D2               *put right nibble in place
    MOVE.B      D2,D1               *put right nibble in D1
    BSR         CONVERT_TO_ASCII    *convert value in D1, to ascii
    BSR         OUTPUT_CHAR         *print the char in D1
    RTS
VALID_OPCODE
    CMP.B       #00,D6              *if leftover data not printed
    BEQ         PRINT_OPCODE_EA     *print just the opcode
    BSR         PRINT_DATA          *print unreadable data
                                    *and the opcode
PRINT_OPCODE_EA    
    ADD.L       #02,A2              *increment the current address because word is valid

    MOVE.B      #00,D6              *reset the increment counter
    BSR         PRINT_ADDRESS       *print the data address
    BSR         TAB                 *insert a space
    BSR         PRINT_OPCODE        *print out hte opcode and eA
    BSR         INCREMENT_LINE      *increment line counter (line was printed)
    BSR         IM_NEW_LINE
    BRA         READ_MEMORY_LOOP    *read next byte.
    

PRINT_OPCODE
    LEA         STRING_START,A1     *put the starting address of the string into A1
    MOVE.B      #14,D0              *print null terminated string into A
    TRAP        #15                 *output to terminal
    LEA         STRING_START,A3     *reset the current string pointer
    RTS
    
RESTART
    LEA         M_NEW_LINE,A1
    MOVE.B      #14,D0
    TRAP        #15
*Clear all the data registers
    CLR.L       D0
    CLR.L       D1
    CLR.L       D2
    CLR.L       D3
    CLR.L       D4
    CLR.L       D5
    CLR.L       D6
    CLR.L       D7
*clear all the address registers
    MOVE.L      D0,A0
    MOVE.L      D0,A1
    MOVE.L      D0,A2
    MOVE.L      D0,A3
    MOVE.L      D0,A4
    MOVE.L      D0,A5
    MOVE.L      D0,A6
    MOVE.L      D0,A7
    BRA         INPUT_START
    
*-------------Return to subroutine----------------*    
RETURN_TO_SUBROUTINE
    RTS
  
*------Convert Number in D1 to ASCII------*
CONVERT_TO_ASCII
    CMP.B       #9,D1           *compare value with 9
    BGT         ALPH_CHAR       *convert to numeric ascii
    BRA         NUMERIC_CHAR    *convert to alphabetical ascii
NUMERIC_CHAR        
    ADD.B       #48,D1          *convert to ascii value
    RTS                         *continue converting
ALPH_CHAR
    ADD.B       #55,D1          *convert to ascii value
    RTS                         *continue converting            
OUTPUT_CHAR
    MOVE.B      #6,D0           *output whatever's in D1
    TRAP        #15
    RTS


IM_NEW_LINE
    LEA         M_NEW_LINE,A1      *load new line
    MOVE.B      #14,D0          *load message
    TRAP        #15             *display message
    RTS
IM_SPACE
    MOVE.B      #32,D1
    MOVE.B      #6,D0
    TRAP        #15
    RTS
TAB
    LEA         M_TAB,A1
    MOVE.B      #14,D0
    TRAP        #15
    RTS
DATA
    LEA         M_DATA,A1
    MOVE.B      #14,D0
    TRAP        #15
    RTS
    


*    SIMHALT             ; halt simulator

*CR          EQU     $0D
*LF          EQU     $0A
*
*M_INPUT_START DC.B 'Please enter starting memory address in hexadecimal:',CR,LF,0
*M_INPUT_END   DC.B 'Please enter ending memory address in hexadecimal:',CR,LF,0
*M_INVALID     DC.B 'Invalid value. Please enter a valid value: ',CR,LF,0
*M_EQUAL       DC.B 'Equal values. No memory read. Please enter new values',CR,LF,0
*M_DATA        DC.B 'DATA    ',0
*M_TAB         DC.B '    ',0
*M_PRESS_CONT  DC.B 'Press any key to continue',0
*M_FINISHED    DC.B 'Finished Reading Memory',0
*M_CONTINUE    DC.B 'Would you like to read memory again? (Y/N)',0
*
*STRING_START    EQU     $0500
*DATA_START      EQU     $0400
*
*MEM_START       EQU     $0100
*MEM_END         EQU     $0200
*
*M_SPACE       DC.B  ' ',0
*M_NEW_LINE    DC.B  '',CR,LF,0


























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
