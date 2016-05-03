*-----------------------------------------------------------
* Title      :Disassembler.Main
* Written by :Blake Hashimoto
* Date       :4/29/2016
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    *TODO: CHANGE THIS VALUE TO RIGHT AFTER PROGRAM CODE
    MOVE.L      #$2000,A1        *set address of register A1
    
    BRA         READ_MEMORY      *for testing purposes only
    
    
*----Display input message for mem start-----*
INPUT_START
    LEA         M_INPUT_START,A1      *load message
    MOVE.B      #14,D0          *display string
    TRAP        #15             *output string
*----Receive User Input ------
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
    MOVE.L      #$A1,A4         *the stop address
    MOVE.B      #7,D2           *put 7 in D2
    ADD.W       D2,A4           *A4 is now the stop address

*----Convert String To Hex-----*
READ_CHAR_LOOP     
    CLR.L       D1              *D2 will act as the temporary value
    MOVE.B      (A1),D1         *read the byte from string
*----check if the value is exaclty 00 (NULL)
    CMP         #0,D1           *compare 00 (NULL) and the byte ascii value in D1
    BEQ         GET_NEXT_INPUT    *if you reached the end of the string, end loop
    
    MOVE.B      #$30,D2         *put ascii zero in D2
    CMP.B       D2,D1           *compare ascii zero and value of D1
    BLT         ERROR           *branch on invalid (too small) ascii value   
*------Result is greater than ascii 0--------*
    MOVE.B      #$46,D2         *put ascii F in D2
    CMP.B       D2,D1           *compare ascii F and value of D1
    BGT.B       ERROR           *branch on invalid ascii value
*------Result is between 0 and F---------*
    MOVE.B      #$41,D2         *put ascii A in D2
    CMP.B       D2,D1           *compare ascii A and value of D1
    BGE         VALID_LETTER    *value is between A and F. Loop back.
    
    MOVE.B      #$39,D2         *put ascii 9 in D2
    CMP.B       D2,D1           *compare ascii 9 and value of D1
    BLE         VALID_NUMBER    *value between 0 and 9. Loop back.    
    BRA         ERROR           *value is between 9 and A (invalid)     
    
ERROR   
    LEA         M_INVALID,A1    *load error message
    MOVE.B      #14,D0          *display string trap
    TRAP        #15             *output error message
    MOVE.B      #1,D4           *put invalid output in result register
    RTS

VALID_NUMBER
    SUB.B       #$30,D1         *get actual value from ascii value
    BRA         VALID_CHAR      *read the next char in string

VALID_LETTER
    SUB.B       #$37,D1         *get actual value from ascii value
    BRA         VALID_CHAR      *read the next char in string
   
VALID_CHAR
    MOVE.B      #0,D4           *return valid value entry in D4    
    LSL.L       #4,D3           *put hex digit in proper place
    ADD.L       D1,D3           *put new total in D3
    ADD.L       #1,A1           *increment address
    CMP         A1,A4           *if A3 > A4
    BLT         READ_CHAR_LOOP  *begin converting to float    
    RTS                         *loop back to INPUT_START || INPUT_END
    
    
READ_MEMORY
    MOVEA.L     #$1000,A2       *start
    MOVEA.L     #$1200,A3       *end
    
    *MOVEA.L     MEM_START,A2    *A2 will be the starting/current address
    *MOVEA.L     MEM_END,A3      *A3 will act as the ending address
READ_MEMORY_LOOP
    CMP         A2,A3           *compare the incrementing address and the end address
    BEQ         END             *stop if the end address is reached
    MOVE.B      (A2)+,D2        *get the value from incrementing address
    MOVE.B      D2,D1           *copy value in D2 to D1
    LSR.B       #4,D1           *get rid of right nibble
    BSR         CONVERT_TO_ASCII    *convert value in D1, to ascii
    BSR         OUTPUT_CHAR     *output the char in D1
        
    MOVE.B      D2,D1           *copy D2 to D1
    LSL.B       #4,D1           *get rid of left nibble
    LSR.B       #4,D1
    BSR         CONVERT_TO_ASCII    *convert value in D1, to ascii
    BSR         OUTPUT_CHAR   *print the char in D1
*---print a space----*
    BSR         SPACE
    
    ADD.B       #1,D4           *increment D4
    CMP.B       #15,D4          *look at value in D4
    BGT         NEW_LINE        *add new line
    BRA         READ_MEMORY_LOOP
    
CONVERT_TO_ASCII
    CMP         #9,D1           *compare value with 9
    BGT         ALPH_CHAR    *convert to numeric ascii
    BRA         NUMERIC_CHAR       *convert to alphabetical ascii
NUMERIC_CHAR        
    ADD.B       #48,D1          *convert to ascii value
    RTS                         *continue converting
ALPH_CHAR
    ADD.B       #55,D1          *convert to ascii value
    RTS                         *continue converting
            
OUTPUT_CHAR
    MOVE.B      #6,D0  
    TRAP        #15
    RTS
NEW_LINE
    MOVE.B      #0,D4           *reset counter
    LEA         M_SPACE,A1      *load new line
    MOVE.B      #14,D0          *load message
    TRAP        #15             *display message
    BRA         READ_MEMORY_LOOP    
SPACE
    MOVE.B      #32,D1
    MOVE.B      #6,D0
    TRAP        #15
    RTS
END

    SIMHALT             ; halt simulator

CR          EQU     $0D
LF          EQU     $0A

M_INPUT_START DC.B 'Please enter starting memory address in hexadecimal:',CR,LF,0
M_INPUT_END   DC.B 'Please enter ending memory address in hexadecimal:',CR,LF,0
M_INVALID     DC.B 'Invalid value. Please enter a valid value: ',CR,LF,0
M_SPACE       DC.B ' ',CR,LF,0

MEM_START       EQU     $0100
MEM_END         EQU     $0200

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
