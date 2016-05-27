    ORG    $1000
START:                  ; first instruction of program
    *TODO: CHANGE THIS VALUE TO RIGHT AFTER PROGRAM CODE
    *BRA         TEST
*----Display input message for mem start-----*
INPUT_START
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
    MOVE.L      #$1000,MEM_START
    MOVE.L      #$1300,MEM_END
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
    BEQ         END               *stop if the end address is reached
    
    ROR         #8,D6               *select correct byte
    CMP.B       #60,D6              *see if maximum lines printed
    BGE         PRESS_TO_CONTINUE
    ROL         #8,D6
READ_MEMORY_CONT                    *continue reading memory (if branched)  
    MOVE.B      (A2)+,D0          *get the value from incrementing address 
    LSL.W       #8,D0             *make room for the next byte of A2
    MOVE.B      -(A2),D0          *copy the rest of A2 to D0    
    BRA         VERIFY_OPCODE                                 ****************Marked to show change
    
    *word != opcode
PRESS_TO_CONTINUE
    MOVE.B      #00,D6              *reset counter
    ROL.L       #8,D6               *put byte back in place
    LEA         M_PRESS_CONT,A1     *load press key to continue messageu
    MOVE.B      #14,D0              *load into D0
    TRAP        #15                 *display message
    MOVE.B      #5,D0               *read single character from keyboard
    TRAP        #15    
    BSR         NEW_LINE            *add new line
    BRA         READ_MEMORY_CONT    *continue reading loop
    
INCREMENT_LINE
    ROR.L       #8,D6               *select correct byte
    ADD.B       #1,D6               *increment counter
    ROL.L       #8,D6               *put byte back in place
    RTS 
    
*word != opcode
INVALID_OPCODE
    CMP.B       #8,D6               *check the loop increment counter
    BGE         PRINT_DATA          *long amount of data. print it.
    ADD.L       #1,A2               *increment current address  
    ADD.B       #1,D6               *increment counter
    BRA         READ_MEMORY_LOOP    *data cap not reached. read next byte.    
    
PRINT_DATA
    MOVE.B      #00,D6              *reset the increment counter
    BSR         PRINT_ADDRESS       *print the data address
    BSR         TAB                 *insert a space
    BSR         DATA                *print 'DATA'   
    BSR         INCREMENT_LINE      *increment line counter (line was printed)
    BRA         PRINT_DATA_LOOP     *print the data
*print whatever's in D1
PRINT_ADDRESS
    MOVE.L      A6,D4               *put the address in D4
    CLR         D3                  *counter for long
    
PRINT_ADDRESS_LOOP
    CMP         #4,D3               *if long reached
    BGE         RETURN_TO_SUBROUTINE *exit loop
    ROL.L       #8,D4               *put ending byte at beginning
    MOVE.B      D4,D1               *put byte in D1 for printing
    BSR         OUTPUT_D1B          *print the first byte of D1
    ADD.B       #1,D3               *increment D3 (loop counter)
    BRA         PRINT_ADDRESS_LOOP  *repeat loop         
         
RETURN_TO_SUBROUTINE
    RTS
PRINT_DATA_LOOP
    MOVE.B      (A6)+,D1            *get the data
    MOVE.B      D1,D2               *copy the data to D2
    CMP.L       A2,A6               *if current address reached
    BGT         END_PRINT_DATA_LOOP *continue reading addresses 
                                    *otherwise keep printing the data
    BSR         OUTPUT_D1B          *print byte in D1 in hex
    *---print a space----*
    BSR         SPACE               *print a space                                
    BRA         PRINT_DATA_LOOP     *repeat loop

END_PRINT_DATA_LOOP
    MOVE.L      A2,A6               *set new address for data/opcode
    BSR         NEW_LINE            *end line
    BSR         INCREMENT_LINE      *increment line printing counter
    BRA         READ_MEMORY_LOOP    *repeat loop   
 
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
    
  
*------Convert Number in D1 to ASCII------*
CONVERT_TO_ASCII
    CMP.B       #9,D1           *compare value with 9
    BGT         ALPH_CHAR       *convert to numeric ascii
    BRA         NUMERIC_CHAR    *convert to alphabetical ascii 
NUMERIC_CHAR        
    ADD.B       #48,D1          *convert to ascii value
    RTS                         *continue converting         ****************Marked to show RTS BUG
ALPH_CHAR
    ADD.B       #55,D1          *convert to ascii value
    RTS                         *continue converting         ****************Marked to show RTS BUG         
OUTPUT_CHAR
    MOVE.B      #6,D0           *output whatever's in D1
    TRAP        #15
    RTS
                                                             *******THERE MAY BE MORE RTS BUGS BELOW********
NEW_LINE
    LEA         M_SPACE,A1      *load new line
    MOVE.B      #14,D0          *load message
    TRAP        #15             *display message
    RTS
SPACE
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

    
END

    SIMHALT             ; halt simulator

CR          EQU     $0D
LF          EQU     $0A

M_INPUT_START DC.B 'Please enter starting memory address in hexadecimal:',CR,LF,0
M_INPUT_END   DC.B 'Please enter ending memory address in hexadecimal:',CR,LF,0
M_INVALID     DC.B 'Invalid value. Please enter a valid value: ',CR,LF,0
M_EQUAL       DC.B 'Equal values. No memory read. Please enter new values',CR,LF,0
M_SPACE       DC.B ' ',CR,LF,0
M_DATA        DC.B 'DATA    ',0
M_TAB         DC.B '    ',0
M_PRESS_CONT  DC.B 'Press any key to continue',0

STRING_START    EQU     $0500
DATA_START      EQU     $0400

MEM_START       EQU     $0100
MEM_END         EQU     $0200



    
VERIFY_OPCODE
*-------------------------------------*
*BEGIN
*D0 will contain word with decodable opcode
*A2 will act as the current address
*if at any time the result is not an opcode,
*branch to "INVALID_OPCODE"    


    MOVE.W  D0,D1   *Copy instruction for modification
    
    **ISOLATE FIRST FOUR BITS**                       ****************Marked to show change                      
    LSR.W   #4,D1       *Shift left four bits
    LSR.W   #8,D1       *Shift left again (12 shifts total)
    ANDI.W  #$000F,D1   *Keep only four bits
    LEA     OP_JTAB, A5 
    JSR     0(A5,D1)    


**************************************************************************
*               Jump table 1. Determine OP code.                         *
*        Analyzes the first four bits within the instruction             *
*        and jumps to the corresponding subroutine.                      *
**************************************************************************
OP_JTAB
    JMP     OP0000      *Subroutine for operations beginning with 0000
    JMP     OP0001      *Subroutine for operations beginning with 0001
    JMP     OP0010      *Subroutine for operations beginning with 0010
    JMP     OP0011      *Subroutine for operations beginning with 0011
    JMP     OP0100      *Subroutine for operations beginning with 0100
    JMP     OP0101      *Subroutine for operations beginning with 0101
    JMP     OP0110      *Subroutine for operations beginning with 0110
    JSR     OP1000      *Subroutine for operations beginning with 1000
    JMP     OP1001      *Subroutine for operations beginning with 1001
    JMP     OP1011      *Subroutine for operations beginning with 1011
    JMP     OP1100      *Subroutine for operations beginning with 1100
    JMP     OP1101      *Subroutine for operations beginning with 1101
    JMP     OP1110      *Subroutine for operations beginning with 1110
    
    BRA    INVALID_OPCODE     *Subroutine to store as non-decodable
    RTS


**************************************************************************
*        OP0000 - Subroutine for operations beginning with 0000          *
*        ADDI                                                            *
**************************************************************************
OP0000
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    
    MOVE.B  ADDI,(A3)+      *Load 'ADDI' to Add Reg 1 and then increment
    BRA     EA_ADDI         *Branch to EA analysis of the command

ADDI    DC.B    'ADDI',0

**************************************************************************
*        OP0001 - Subroutine for operations beginning with 0001          *
*        MOVE.B                                                          *
**************************************************************************
OP0001
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT

    MOVE.B  MOVEB,(A3)+     *Load 'MOVE.B' to Add Reg 1 and then increment
    BRA     EA_MOVE        *Branch to EA analysis of the command
    
MOVEB   DC.B    'MOVE',0

**************************************************************************
*        OP0010 - Subroutine for operations beginning with 0010          *
*        MOVE.W, MOVEA(WORD)                                             *
**************************************************************************
OP0010
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS
    
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 2/4 as both contain Xn in 1/4
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits
    
    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS       
    CMP     #%001,D1        *Check for 001 to eliminate MOVEA.W
    BEQ     _MOVEAW         *If equal, branch to MOVEA.W
    BRA     _MOVEW          *Else must be MOVE.W. branch.
    
********* MOVEW *************        
_MOVEW
    MOVE.B  MOVEW,(A3)+     *Load 'MOVE.W' to Add Reg 1 and then increment
    BRA     EA_MOVE        *Branch to EA analysis of the command
MOVEW     DC.B    'MOVE',0

********* MOVEAW *************        
_MOVEAW
    MOVE.B  MOVEAW,(A3)+    *Load 'MOVEA.W' to Add Reg 1 and then increment
    BRA     EA_MOVEA       *Branch to EA analysis of the command      
MOVEAW     DC.B    'MOVEA',0


**************************************************************************
*        OP0011 - Subroutine for operations beginning with 0011          *
*        MOVE.L, MOVEA(LONG)                                             *
**************************************************************************
OP0011
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS

    **ISOLATE NEXT BITS TO CHECK**
    **Look to 2/4 as both contain Xn in 1/4
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits
    
    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS            
    CMP     #%001,D1        *Check for 001 to eliminate MOVEA.W
    BEQ     _MOVEAL         *If equal, branch to MOVEA.L
    BRA     _MOVEL          *Else must be MOVEL, branch
    
********* MOVEL *************        
_MOVEL
    MOVE.B  MOVEL,(A3)+     *Load 'MOVE.L' to Add Reg 1 and then increment
    BRA     EA_MOVE        *Branch to EA analysis of the command
MOVEL     DC.B    'MOVE',0

********* MOVEAL *************        
_MOVEAL
    MOVE.B  MOVEAL,(A3)+    *Load 'MOVEA.L' to Add Reg 1 and then increment
    BRA     EA_MOVEA       *Branch to EA analysis of the command
MOVEAL     DC.B    'MOVEA',0

**************************************************************************
*        OP0100 - Subroutine for operations beginning with 0100          *
*        NOP, MOVEM, LEA, CLR, JSR, RTS                                  *
**************************************************************************
OP0100
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS
    
    **ISOLATE NEXT BITS TO CHECK**    
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits

    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS
    CMP     #%001,D1        *Check for 001 to eliminate CLR
    BEQ     _CLR            *If equal, branch to CLR
    BRA     OP0100_1        *Else continue checking

OP0100_1 **Could be MOVEM, LEA, NOP, JSR, or RTS**

    **ISOLATE NEXT BITS TO CHECK**
    **Look to 2/4 as 1/4 already checked
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits
    
    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS
    CMP     #%111,D1        *Check for 111 to eliminate LEA
    BEQ     _LEA            *If equal, branch to LEA
                            
    CMP     #%010,D1        *Else check for 010 to eliminate JSR
    BEQ     _JSR            *If equal, branch to JSR
    
    BRA     OP0100_2        *Else continue checking

OP0100_2 **Could be MOVEM, NOP, or RTS**

    **ISOLATE NEXT BITS TO CHECK**
    **Look to 4/4 as 1/4,2/4 already checked
    **and NOP and RTS both contain 110 in 3/4
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (3/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (4/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits

    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS    
    CMP     #%001,D1        *Check for 001 to eliminate NOP
    BEQ     _NOP            *If equal, branch to NOP
    
    CMP     #%101,D1        *Else Check for 101 to eliminate RTS
    BEQ     _RTS            *If equal, branch to RTS
    
    BRA     _MOVEM          *Else by process of elimination it must be MOVEM    
    
********* CLR *************        
_CLR
    MOVE.B  OPCLR,(A3)+     *Load 'CLR' to Add Reg 1 and then increment
    BRA     EA_CLR          *Branch to EA analysis of the command
OPCLR     DC.B    'CLR',0

********* LEA *************        
_LEA
    MOVE.B  OPLEA,(A3)+     *Load 'LEA' to Add Reg 1 and then increment
    BRA     EA_LEA          *Branch to EA analysis of the command
OPLEA     DC.B    'LEA',0

********* JSR *************     
_JSR
    MOVE.B  OPJSR,(A3)+     *Load 'JSR' to Add Reg 1 and then increment
    BRA     EA_JSR          *Branch to EA analysis of the command
OPJSR     DC.B    'JSR',0

********* NOP *************     
_NOP
    MOVE.B  OPNOP,(A3)+     *Load 'NOP' to Add Reg 1 and then increment    
    *BRA     EA_NOP          *Branch to EA analysis of the command      ****************Marked to show change
OPNOP     DC.B    'NOP',0

********* RTS *************     
_RTS
    MOVE.B  OPRTS,(A3)+     *Load 'RTS' to Add Reg 1 and then increment
    *BRA     EA_RTS          *Branch to EA analysis of the command      ****************Marked to show change
OPRTS     DC.B    'RTS',0

********* MOVEM *************     
_MOVEM
    MOVE.B  MOVEM,(A3)+     *Load 'MOVEM' to Add Reg 1 and then increment
    BRA     EA_MOVEM        *Branch to EA analysis of the command
MOVEM     DC.B    'MOVEM',0
    
**************************************************************************
*        OP0101 - Subroutine for operations beginning with 0101          *
*        ADDQ                                                            *
**************************************************************************
OP0101
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    
    MOVE.B  ADDQ,(A3)+      *Load 'AddQ' to Add Reg 1 and then increment
    BRA     EA_ADDQ         *Branch to EA analysis of the command
    
ADDQ   DC.B    'ADDQ',0
    
**************************************************************************
*        OP0110 - Subroutine for operations beginning with 0110          *
*        Bcc                                                             *
**************************************************************************
OP0110
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    
    *MOVE.B  Bcc,(A3)+       *Load 'Bcc' to Add Reg 1 and then increment       ******************I don't THINK I need this line
    BRA     EA_BCC          *Branch to EA analysis of the command
    
Bcc  DC.B    'Bcc',0

**************************************************************************
*        OP0111 - Subroutine for operations beginning with 0101          *
*        MOVEQ                                                           *
**************************************************************************
OP0111
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    
    MOVE.B  MOVEQ,(A3)+     *Load 'MOVEQ' to Add Reg 1 and then increment
    BRA     EA_MOVEQ        *Branch to EA analysis of the command
    
MOVEQ   DC.B    'MOVEQ',0
    
**************************************************************************
*        OP1000 - Subroutine for operations beginning with 1000          *
*        DIVU, OR                                                        *
**************************************************************************
OP1000
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS
    
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 2/4 as both contain Xn in 1/4
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits
    
    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS           
    CMP     #%011,D1    *Check for 011 to eliminate DIVU
    BEQ     _DIVU        *If equal, branch to DIVU
    BRA     _OR          *Else must be OR, branch
    RTS
    
********* DIVU *************        
_DIVU
    MOVE.B  DIVU,(A3)+      *Load 'DIVU' to Add Reg 1 and then increment
    BRA     EA_MULS         *Branch to EA analysis of the command
DIVU     DC.B    'DIVU',0

********* OR *************        
_OR
    MOVE.B  OR,(A3)+        *Load 'OR' to Add Reg 1 and then increment
    BRA     EA_ADD           *Branch to EA analysis of the command
OR       DC.B    'OR',0

**************************************************************************
*        OP1001 - Subroutine for operations beginning with 1001          *
*        SUB                                                             *
**************************************************************************
OP1001
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    
    MOVE.B  _SUB,(A3)+     *Load 'SUB' to Add Reg 1 and then increment
    BRA     EA_ADD          *Branch to EA analysis of the command

_SUB     DC.B    'SUB',0

**************************************************************************
*        OP1011 - Subroutine for operations beginning with 1011          *
*        CMP                                                             *
**************************************************************************
OP1011
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    MOVE.B  CMP,(A3)+     *Load 'CMP' to Add Reg 1 and then increment
    BRA     EA_CMP          *Branch to EA analysis of the command

CMP     DC.B    'CMP',0

**************************************************************************
*        OP1100 - Subroutine for operations beginning with 1100          *
*        MULS, AND                                                       *
**************************************************************************
OP1100
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS
 
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 2/4 as both contain Xn in 1/4
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits
    
    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS          
    CMP     #%111,D1       *Check for 111 to eliminate MULS
    BEQ     _MULS           *If equal, branch to MULS
    BRA     _AND            *Else must be AND, branch
    
********* MULS *************        
_MULS
    MOVE.B  MULS,(A3)+      *Load 'MULS' to Add Reg 1 and then increment
    BRA     EA_MULS         *Branch to EA analysis of the command
MULS     DC.B    'MULS',0

********* AND *************        
_AND
    MOVE.B  AND,(A3)+       *Load 'AND' to Add Reg 1 and then increment
    BRA     EA_ADD          *Branch to EA analysis of the command
AND       DC.B    'AND',0
    
**************************************************************************
*        OP1101 - Subroutine for operations beginning with 1101          *
*        ADD, ADDA                                                       *
**************************************************************************
OP1101
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS  
    
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 2/4 as both contain Xn in 1/4
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits
    
    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS             
    CMP     #%011,D1       *Check for 011 to eliminate ADDA (Size dependant)
    BEQ     _ADDA           *If equal, branch to ADDA
    CMP     #%111,D1        *Else check for 111 to eliminate ADDA (Size dependant)
    BEQ     _ADDA           *If equal, branch to ADDA
    BRA     _ADD            *Else must be ADD, branch
    
********* ADD *************        
_ADD
    MOVE.B  ADD,(A3)+       *Load 'ADD' to Add Reg 1 and then increment
    BRA     EA_ADD          *Branch to EA analysis of the command
ADD     DC.B    'ADD',0

********* AND *************        
_ADDA
    MOVE.B  ADDA,(A3)+      *Load 'ADDA' to Add Reg 1 and then increment
    BRA     EA_ADDA         *Branch to EA analysis of the command
ADDA      DC.B    'ADDA',0
    
**************************************************************************
*        OP1110 - Subroutine for operations beginning with 1110          *
*        LSR, LSL, ASR, ASL, ROL, ROR                                    *
**************************************************************************
OP1110
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS
    
    **ISOLATE NEXT BITS TO CHECK**    
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits

                  
    CMP     #%001,D1       *Check for 001 to eliminate LSd instructions
    BEQ     _LSd            *If equal, branch to LSd to determine LSR or LSL
    BRA     OP1110_1
    
OP1110_1
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 3/4 as 1/4 has been checked and 2/4 is ambiguous
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits
    
    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS                   
    CMP     #%000,D1       *Check for 000 to eliminate ASd (Rotation dependant)
    BEQ     _ASd            *If equal, branch to ASd to determine ASR or ASL
    CMP     #%100,D1       *Check for 100 to eliminate ASd (Rotation dependant)
    BEQ     _ASd            *If equal, branch to ASd to determine ASR or ASL
    BRA     _ROd             *Else must be a ROd instruction, branch to determine
    
********** LSd *************        
_LSd    
    **ISOLATE NEXT BITS TO CHECK**  
    **Look to 2/4 as 1/4 has been checked
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits

    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS          
    CMP     #%011,D1        *Check for 011 to eliminate LSR
    BEQ     _LSR            *If equal, branch to LSR
    BRA     _LSL            *Else must be LSL, branch

_LSL    
    MOVE.B  LSL,(A3)+       *Load 'LSL' to Add Reg 1 and then increment
    BRA     EA_LSD         *Branch to EA analysis of the command
LSL     DC.B    'LSL',0

_LSR
    MOVE.B  LSR,(A3)+       *Load 'LSR' to Add Reg 1 and then increment
    BRA     EA_LSD          *Branch to EA analysis of the command
LSR     DC.B    'LSR',0

********* ASd *************
_ASd
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 3/4 as 1/4,2/4 already checked
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (3/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits

    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS       
    CMP     #%000,D1        *Check for 000 to eliminate ASR
    BEQ     _ASR            *If equal, branch to ASR
    BRA     _ASL            *Else must be ASL, branch

_ASL    
    MOVE.B  ASL,(A3)+       *Load 'ASL' to Add Reg 1 and then increment
    BRA     EA_LSD          *Branch to EA analysis of the command
ASL     DC.B    'ASL',0

_ASR
    MOVE.B  ASR,(A3)+       *Load 'ASR' to Add Reg 1 and then increment
    BRA     EA_LSD          *Branch to EA analysis of the command
ASR     DC.B    'ASR',0

********* ROd *************
_ROd
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 3/4 as 1/4,2/4 already checked
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (3/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits

    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS   
    CMP     #%011,D1        *Check for 011 to eliminate ROR
    BEQ     _ROR            *If equal, branch to ROR
    BRA     _ROL            *Else must be ROL, branch
    
_ROL    
    MOVE.B  ROL,(A3)+       *Load 'ROL' to Add Reg 1 and then increment
    BRA     EA_LSD          *Branch to EA analysis of the command
ROL     DC.B    'ROL',0

_ROR
    MOVE.B  ROR,(A3)+       *Load 'ROR' to Add Reg 1 and then increment
    BRA     EA_LSD          *Branch to EA analysis of the command
ROR     DC.B    'ROR',0







**************************************************************************
*                          GET4                                          *
*                Reference code for get 4 bits                           *
**************************************************************************
*
*    MOVE.W  D0,D1   *Copy instruction for modification
*    LSR.W   #4,D1       *Shift left four bits
*    LSR.W   #8,D1       *Shift left again (12 shifts total)
*    ANDI.W  #$000F,D1   *Keep only four bits



***************************************************************************
**                         GET3                                           *
**                Reference code for get 3 bits                           *
***************************************************************************

*    MOVE.W  D0,D1    *Copy instruction for modification
*    LSL.W   #4,D1    *Shift left to grab 3 bits (1/4 'chunks')
*    LSR.W   #4,D1    *Rotate left four bits
*    LSR.W   #8,D1      *Shift left again (12 shifts total)
*    ANDI.W  #$00F,D1   *Keep only three bits











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



*-------------------------MOVE------------------------------------
EA_MOVE      
*----------------SOURCE-------------------------------------------  
    MOVE.W      D0, D6 *DO THIS AT THE BEGGINING OF EVERY EA 
    
    MOVE.W      D6, D4      *
    LSR.W       #8, D4      *
    LSR.W       #4, D4      *D4 = SIZE
    JSR GET_SIZE
    
    MOVE.W      D6, D4      *
    LSL.W       #8, D4      *
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = <0000 0000> D4 = SOURCE MODE
    
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      *D5 = SOURCE REGISTER
    
    JSR         MODE_CHOOSER
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
*---------------END SOURCE---------------------------------------
    JSR COMMA
    JSR SPACE
*--------------DESTINATION-------------------------------------
    MOVE.W      D6, D4      *
    LSL.W       #7, D4      *
    LSR.W       #7, D4      *
    LSR.W       #6, D4      *D4 = DESTINATION MODE
    JSR         MOVE_ERROR_CHECK
    
    MOVE.W      D6, D5      *
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = DESTINATION REGISTER
    
    JSR         MODE_CHOOSER
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
*------------END DESTINATION-------------------------------------
    MOVE.B      #00, (A3) 
    *RTS
    BRA         VALID_OPCODE            ********************************* I commented RTS out, added this line
*-------------------------END MOVE--------------------------------
*------------------------------------------------------------------
*-------------------------MOVEA-----------------------------------
EA_MOVEA
*------------------------SOURCE----------------------------------------
    MOVE.W      D0, D6


    MOVE.W      D6, D4      *GETTING SIZE
    LSR.W       #8, D4      *
    LSR.W       #4, D4      *SHIFT 12 BITS RIGHT
    JSR         GET_SIZE    *D4 = SIZE
    
    MOVE.W      D6, D4      *GETTING SOURCE MODE
    LSL.W       #8, D4      *
    LSL.W       #2, D4      *SHIFT 10 BITS LEFT; 13 RIGHT
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = SOURCE MODE

    MOVE.W      D6, D5      *GETTING SOURCE REGISTER
    LSL.W       #8, D5      *
    LSL.W       #5, D5      *SHIFT LEFT 13; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = SOURCE REGISTER
    
    JSR         MODE_CHOOSER  *INCASE MODE IS $111
    LEA         MODE_JUMP, A0 *LOAD MODE JUMP TABLE
    MULS        #6, D4        *GET JUMP
    JSR         0(A0, D4)     *JUMP
*--------------------END SOURCE------------------------------------------
    JSR         COMMA
    JSR         SPACE
*--------------------DESTINATION--------------------------------------
    MOVE.W      D6, D5      *GET THE DESTINATION REGISTER
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *SHIFT 4 BITS LEFT; 13 RIGHT
    LSR.W       #5, D5      *D5 = DESTINATION REGISTER
    
    JSR         ADDR_1
    MOVE.B      #00, (A3)
    *RTS
    BRA         VALID_OPCODE           ********************************* I commented RTS out, added this line
*------------------END DESTINATION--------------------------------------
*------------------------END MOVEA------------------------------
*----------------------------------------------------------------
*-----------------------MOVEQ---------------------------------------
EA_MOVEQ
*-----------------------SOURCE-----------------------------------------
    MOVE.W      D0, D6

    JSR SPACE
    JSR POUND
    JSR CASH
    BSR OUTPUT_HEX    
*----------------------END SOURCE--------------------------------------
    JSR COMMA
    JSR SPACE
*---------------------DESTINATION------------------------------------
    MOVE.W      D6, D5      *GET THE DESTINATION REGISTER
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *
    LSR.W       #5, D5      * D5 = DESTINATION REGISTER
    
    JSR         DATA_0
    MOVE.B      #00, (A3)
    *RTS
    BRA         VALID_OPCODE            ********************************* I commented RTS out, added this line
*----------------------END MOVEQ--------------------------------
*---------------------------------------------------------------
*------------------------ADD------------------------------------
EA_ADD
*COVERS ADD, SUB, AND, OR
*--------------------GET MODES-----------------------------
    MOVE.W      D0, D6

    MOVE.W      D6, D4      *GETTING OPMODE AKA SIZE
    LSL.W       #7, D4      * 
    LSR.W       #7, D4      *
    LSR.W       #6, D4      *D4 = OPMODE AKA SIZE
    JSR         GET_OPMODE_MATH *PRINTS THE SIZE

    CMP.B       #3, D4
    BLT         DN_VERSION
    CMP.B       #3, D4
    BGT         EA_VERSION
    *RTS
    BRA         VALID_OPCODE            ********************************* I commented RTS out, added this line
*-------------------END GETS MODES------------------------------
*-------------------DN VERSION------------------------
DN_VERSION *EA IS SOURCE, REGISTER IS DESTINATION <EA> + DN -> DN
    MOVE.W      D6, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG    
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
        
    JSR         COMMA
    JSR         SPACE
    
    MOVE.W      D6, D5      *LEFT 4; RIGHT 13
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 DESTINATION REGISTER
    
    JSR         DATA_0
    MOVE.B      #00, (A3)
    RTS
*-------------------END DN VERSION-------------------
*-------------------EA VERSION-------------------------
EA_VERSION
    MOVE.W      D6, D5      *LEFT 4; RIGHT 13
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 DESTINATION REGISTER
    JSR         DATA_0
    
    JSR         COMMA
    JSR         SPACE
    
    MOVE.W      D6, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG 
    JSR         ADD_ERROR_CHECK
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
    
    MOVE.B      #00, (A3)
    RTS
*------------------END EA VERSION----------------------
*--------------------END ADD----------------------------
*------------------------------------------------------
*-------------------ADDI--------------------------------
EA_ADDI
*-------------------PRINT SIZE-----------------------------------
    MOVE.W      D0, D6
    
    MOVE.W      D6, D4      *
    LSL.W       #8, D4      *
    LSR.W       #8, D4      *
    LSR.W       #6, D4      *D4 = SIZE
    JSR         GET_SIZE_ADDI
*-----------------END PRINT SIZE-----------------------------
*----------------PRINT IMMEDIATE----------------------------
    JSR         POUND
    JSR         CASH
    BSR         OUTPUT_HEX
*-------------END PRINT IMMEDIATE-----------------------------
    JSR         COMMA
    JSR         SPACE
*-----------------PRINT EA------------------------------------
    MOVE.W      D6, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG    
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP'
    
    MOVE.B      #00, (A3)
    *RTS
    BRA         VALID_OPCODE            ********************************* I commented RTS out, added this line
*-------------------END PRINT EA--------------------------
*-------------------END ADDI------------------------------
*----------------------------------------------------------
*------------------------ADDQ----------------------------------
EA_ADDQ
*-----------------------SOURCE------------------------------------
    MOVE.W      D0, D6
    
    MOVE.W      D6, D4
    LSL.W       #8, D4
    LSR.W       #8, D4
    LSR.W       #6, D4
    JSR         GET_SIZE_ADDI    *PRINT SIZE
    
    MOVE.W      D6, D5      *GETTING DATA
    LSL.W       #4, D5      *SHIFT LEFT 4; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = DATA
    JSR         GET_DATA
*--------------------END SOURCE-------------------------------------
    JSR COMMA
    JSR SPACE
*-------------------PRINT EA-----------------------------------
    MOVE.W      D6, D4      *GETTING EA MODE
    LSL.W       #8, D4      *
    LSL.W       #2, D4      *SHIFT 10 LEFT; 13 RIGHT
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D6, D5      *GETTING EA REGISTER
    LSL.W       #8, D5      *
    LSL.W       #5, D5      *SHIFT LEFT 13; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = EA REGISTER
    
    JSR         MODE_CHOOSER
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
    
    MOVE.B      #00, (A3)
    *RTS
    BRA         VALID_OPCODE            ********************************* I commented RTS out, added this line
*-------------------END PRINT EA-------------------------------
*----------------------END ADDQ---------------------------------
*--------------------------------------------------------------
*-------------------------ADDA------------------------------------
EA_ADDA
*-----------------------SOURCE------------------------------
    MOVE.W      D0, D6
    
    MOVE.W      D6, D4      *GETTING OPMODE AKA SIZE
    LSL.W       #7, D4      * 
    LSR.W       #7, D4      *
    LSR.W       #6, D4      *D4 = OPMODE AKA SIZE
    JSR         GET_OPMODE
    
    MOVE.W      D6, D4      *GETTING SOURCE MODE
    LSL.W       #8, D4      *
    LSL.W       #2, D4      *SHIFT 10 BITS LEFT; 13 RIGHT
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = SOURCE MODE
    
    MOVE.W      D6, D5      *GETTING SOURCE REGISTER
    LSL.W       #8, D5      *
    LSL.W       #5, D5      *SHIFT LEFT 13; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = SOURCE REGISTER
    
    JSR         MODE_CHOOSER  *INCASE MODE IS $111
    LEA         MODE_JUMP, A0 *LOAD MODE JUMP TABLE
    MULS        #6, D4        *GET JUMP
    JSR         0(A0, D4)     *JUMP
*-----------------------END SOURCE--------------------------
    JSR COMMA 
    JSR SPACE
*-----------------------DESTINATION-------------------------
    MOVE.W      D6, D5      *GET THE DESTINATION REGISTER
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *SHIFT 4 BITS LEFT; 13 RIGHT
    LSR.W       #5, D5      *D5 = DESTINATION REGISTER
    
    JSR         ADDR_1
    MOVE.B      #00, (A3)
    *RTS
    BRA         VALID_OPCODE           ********************************* I commented RTS out, added this line
*-----------------------END DESTINATION---------------------
*-------------------------END ADDA--------------------------------
*---------------------------------------------------------------
*------------------------------MULS--------------------------------
EA_MULS
*COVERS DIVU, MULS
*----------------------PRINT EA-------------------------
    MOVE.W      D0, D6
    
    JSR         SPACE
    MOVE.W      D6, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG    
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
*--------------------END PRINT EA----------------------
    JSR         COMMA
    JSR         SPACE
*--------------------PRINT REGISTER--------------------
    MOVE.W      D6, D5      *LEFT 4; RIGHT 13
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 DESTINATION REGISTER
    
    JSR         DATA_0
    MOVE.B      #00, (A3)
    *RTS
    BRA         VALID_OPCODE            ********************************** I commented RTS out, added this line
*---------------------------END MULS------------------------------
*----------------------------------------------------------------
*-------------------------LEA-----------------------------------
EA_LEA
*-------------------SOURCE-------------------------------------
    MOVE.W      D0, D6
    
    JSR         SPACE
    MOVE.W      D6, D4      *GETTING SOURCE MODE
    LSL.W       #8, D4      *
    LSL.W       #2, D4      *SHIFT 10 BITS LEFT; 13 RIGHT
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = SOURCE MODE
    
    MOVE.W      D6, D5      *GETTING SOURCE REGISTER
    LSL.W       #8, D5      *
    LSL.W       #5, D5      *SHIFT LEFT 13; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = SOURCE REGISTER
    
    JSR         MODE_CHOOSER  *INCASE MODE IS $111
    LEA         MODE_JUMP, A0 *LOAD MODE JUMP TABLE
    MULS        #6, D4        *GET JUMP
    JSR         0(A0, D4)     *JUMP
*-------------------END SOURCE---------------------------------
    JSR COMMA
    JSR SPACE
*-------------------DESTINATION-------------------------------
    MOVE.W      D6, D5      *GET THE DESTINATION REGISTER
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *SHIFT 4 BITS LEFT; 13 RIGHT
    LSR.W       #5, D5      *D5 = DESTINATION REGISTER
    
    JSR         ADDR_1
    MOVE.B      #00, (A3)
    *RTS
    BRA         VALID_OPCODE           ********************************* I commented RTS out, added this line
*-----------------END DESTINATION-----------------------------
*------------------------END LEA--------------------------------
*-----------------------------------------------------------------
*------------------------CLR-------------------------------------
EA_CLR
*-------------------PRINT SIZE-----------------------
    MOVE.W      D0, D6
    
    MOVE.W      D6, D4
    LSL.W       #8, D4      *
    LSR.W       #8, D4      *
    LSR.W       #6, D4      *D4 = SIZE
    JSR         GET_SIZE_ADDI
*----------------END PRINT SIZE-------------------------
*---------------PRINT EA---------------------------------
    MOVE.W      D6, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG    
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
    
    MOVE.B      #00, (A3)
    *RTS
    BRA         VALID_OPCODE           ********************************* I commented RTS out, added this line
*---------------END PRINT EA-------------------------
*------------------------END CLR--------------------------------
*----------------------------------------------------------------
*--------------------------SHIFTS------------------------------
EA_LSD
*COVERS LSD, ASD, ROD
*-------------------------SIZE---------------------------
    MOVE.W      D0, D6
    
    MOVE.W      D6, D4
    LSL.W       #8, D4
    LSR.W       #8, D4
    LSR.W       #6, D4      *ISOLATE SIZE
    JSR         GET_SIZE_ADDI  *PRINT SIZE
    CMP.B       #3, D4      *EA SHIFT
    BEQ         EA_SHIFT    *BRANCH TO EA SHIFT
*-----------------------END SIZE--------------------------
*-----------------------SHIFTING------------------------------
    MOVE.W      D6, D4
    LSL.W       #8, D4
    LSL.W       #2, D4
    LSR.W       #8, D4
    LSR.W       #7, D4      *D4 = TYPE
    
    MOVE.W      D6, D5      *GETTING DATA
    LSL.W       #4, D5      *SHIFT LEFT 4; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = DATA / REGISTER
    
    JSR         TYPE_CHOOSER
*-----------------------END SHIFTING---------------------------
    JSR         COMMA
    JSR         SPACE
*----------------------DESTINATION------------------------------
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    JSR         DATA_0
    
    MOVE.B      #00, (A3)
    *RTS
    BRA         VALID_OPCODE            ********************************* I commented RTS out, added this line
*----------------------END DESTINATION-------------------------    
*---------------------------EA SHIFT-------------------------------
EA_SHIFT
    JSR         SPACE
    MOVE.W      D6, D4      *
    LSL.W       #8, D4      *
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG    
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
    BRA         DONE
*-------------------------END EA SHIFT------------------------------
DONE
    MOVE.B      #00, (A3)
    *RTS
    BRA         VALID_OPCODE            ********************************* I commented RTS out, added this line

*----------------------------END SHIFTS---------------------------
*---------------------------------------------------------------
*-------------------------------CMP-----------------------------
EA_CMP
*------------------PRINT SIZE----------------------------
    MOVE.W      D0, D6
    
    MOVE.W      D6, D4      *GETTING OPMODE AKA SIZE
    LSL.W       #7, D4      * 
    LSR.W       #7, D4      *
    LSR.W       #6, D4      *D4 = OPMODE AKA SIZE
    JSR         GET_SIZE_ADDI
*---------------END PRINT SIZE-------------------------
*------------------PRINT EA---------------------------
    MOVE.W      D6, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG    
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
*-----------------END PRINT EA-------------------------
    JSR         COMMA
    JSR         SPACE
*----------------PRINT REG----------------------------
    MOVE.W      D6, D5      *LEFT 4; RIGHT 13
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 DESTINATION REGISTER
    
    JSR         DATA_0
    MOVE.B      #00, (A3)
    *RTS
    BRA         VALID_OPCODE            ********************************* I commented RTS out, added this line
*--------------END PRINT REG---------------------------
*------------------------------END CMP----------------------------
*-----------------------------------------------------------------
*--------------------------------BCC------------------------------
EA_BCC
*--------------------PRINT TYPE------------------------
    MOVE.W      D0, D6
    
    MOVE.W      D6, D4
    LSL.W       #4, D4
    LSR.W       #8, D4
    LSR.W       #4, D4   *D4 = BINARY CONDITION CODE
    JSR         PRINT_BCC
*-------------------END PRINT TYPE---------------------
    JSR         SPACE
*------------------PRINT ADDRESS OR SOMETHING---------
    JSR         OUTPUT_HEX
    MOVE.B      #00, (A3)
    *RTS
    BRA         VALID_OPCODE            ********************************* I commented RTS out, added this line
*-------------END PRINT ADDRESS OR SOMETHING-------------
*-----------------------------END BCC-------------------------------
*-------------------------------------------------------------------
*---------------------------JSR---------------------------------------
EA_JSR

    MOVE.W      D0, D6
    
    JSR         SPACE
    MOVE.W      D6, D4      *GETTING SOURCE MODE
    LSL.W       #8, D4      *
    LSL.W       #2, D4      *SHIFT 10 BITS LEFT; 13 RIGHT
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = SOURCE MODE
    
    MOVE.W      D6, D5      *GETTING SOURCE REGISTER
    LSL.W       #8, D5      *
    LSL.W       #5, D5      *SHIFT LEFT 13; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = SOURCE REGISTER
    
    JSR         MODE_CHOOSER  *INCASE MODE IS $111
    LEA         MODE_JUMP, A0 *LOAD MODE JUMP TABLE
    MULS        #6, D4        *GET JUMP
    JSR         0(A0, D4)     *JUM
    
    MOVE.B      #00, (A3)
    *RTS
    BRA         VALID_OPCODE            ********************************* I commented RTS out, added this line
*---------------------------END JSR----------------------------------
*-----------------------------------------------------------------
*-----------------------------MOVEM-------------------------------
EA_MOVEM
    MOVE.W      D0, D6
*---------------------SIZE--------------------------------
    MOVE.W      D6, D4
    LSL.W       #5, D4
    LSL.W       #4, D4
    LSR.W       #8, D4
    LSR.W       #7, D4
    JSR         REG_SIZE
*-------------------END SIZE----------------------------
*--------------------TYPE-------------------------------
    MOVE.W      D6, D7
    LSL.W       #5, D7
    LSR.W       #8, D7
    LSR.W       #7, D7
    CMP.B       #0, D7
    BEQ         PRINT_LIST
*-------------------END TYPE---------------------------
*----------------------EA INFO-----------------------
EAP CMP.W       #0, D7      *IF ITS A ZERO, THAT MEANS WE JUST JUMPED HERE 
    BEQ         COMMA_SPACE *FROM CHECK TYPE, ELSE MEANS ITS UNALTERED
EAS MOVE.W      D6, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG    
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
    
    CMP.W       #1, D7 *IF ONE THEN THIS WAS PRINTED FIRST
    BEQ         PRINT_LIST
    
    BRA         DONE_PRINTING
*--------------------END EA INFO--------------------------
*---------------------REGISTER PRINT------------------------
PRINT_LIST
    CMP.B       #1, D7 
    BEQ         COMMA_SPACE2
EA2 MOVE.L      A2, D7
    ADD.L       #2, A2
    MOVE.B      #$8, D2
    CLR         D4
FOR_LOOP    
    CMP.B       D4, D2
    BEQ         ADDRESS_REGISTERS
    ROR.W       #1, D7
    BRA         PRINT_CURRENT
JFZ ADDQ        #1, D4
    BRA         FOR_LOOP
    
PRINT_CURRENT
    BCC         JFZ
    MOVE.B      D4, D5
    JSR         DATA_0
    JSR         SLASH
    BRA         JFZ
    
ADDRESS_REGISTERS
    CLR         D4
FOR_2
    CMP.B       D4, D2
    BEQ         CHECK_TYPE
    ROR.W       #1, D7
    BRA         PRINT_ADDRESS
JFF ADDQ        #1, D4
    BRA         FOR_2
    
*PRINT_ADDRESS
*    BCC         JFF
*    MOVE.B      D4, D5
*    JSR         SLASH
*    JSR         ADDR_1
*    BRA         JFF  
*----------------------END REGISTER PRINT-----------------
CHECK_TYPE
    MOVE.W      D6, D7
    LSL.W       #5, D7  
    LSR.W       #8, D7
    LSR.W       #7, D7
    CMP.B       #0, D7   *IF TYPE IS 0 THE LIST HAS BEEN PRINTED FIRST  
    BEQ         EAP      *THEREFORE ITS TIME TO PRINT THE EAP
    BNE         DONE_PRINTING
    
COMMA_SPACE
    JSR         COMMA
    JSR         SPACE
    BRA         EAS
    
COMMA_SPACE2
    JSR         COMMA
    JSR         SPACE
    BRA         EA2
    
DONE_PRINTING
    MOVE.B      #00, (A3)
    RTS


*------------------------------END MOVEM----------------------------




*-------------------ERROR CHECK--------------------------------
MOVE_ERROR_CHECK
    CMP.B       #1, D4
    BEQ         INVALID
    RTS
    
ADD_ERROR_CHECK
    CMP.B       #7, D4
    BEQ         INVALID 
    RTS   
    
*-----------------END ERROR CHECK-------------------------------
*-----------------START MODE JUMP-----------------------------------
MODE_JUMP       JMP     DATA_0
                JMP     ADDR_1
                JMP     ADDI_2
                JMP     ADDP_3
                JMP     ADDM_4
                JMP     ABSW_5
                JMP     ABSL_6
                JMP     IMME_7

DATA_0 *DONE
    MOVE.B      M_DREG, (A3)+
    JSR         GET_REG
    RTS

ADDR_1 *ADD CONDITIONS FOR SOURCE ONLY, AND NEVER BYTES
    MOVE.B      M_AREG, (A3)+
    JSR         GET_REG
    RTS
 
ADDI_2 *DONE
    JSR         OPEN
    JSR         ADDR_1
    JSR         CLOSE
    RTS
    
ADDP_3 *DONE
    JSR         ADDI_2
    JSR         PLUS
    RTS
    
ADDM_4 *DONE
    JSR         SUB
    JSR         ADDI_2
    RTS
    
ABSW_5  *DONE
    MOVE.L      A2, D2
    JSR         CASH
    BSR         OUTPUT_HEX
    ADD.L       #2, A2
    RTS

 
ABSL_6 *
    JSR         CASH
    
    MOVE.L      A2, D2
    BSR         OUTPUT_HEX
    ADD.L       #2, A2      *ACQUIRED FIRST PART OF LONG

***********
    
    MOVE.L      A2, D2
    BSR         OUTPUT_HEX
    ADD.L       #2, A2
    RTS
    
IMME_7  *FOR NOW ONLY WORKING WITH IMMEDIATE HEX VALUES
    JSR         POUND
    JSR         CASH
    
*****
    MOVE.L      A2, D2
    BSR         OUTPUT_HEX
    ADD.L       #2, A2
****
    MOVE.L      A2, D2
    BSR         OUTPUT_HEX
    ADD.L       #2, A2
    RTS

*-------------------------END MODE JUMP----------------------------  
*-------------------------START HELPERS-----------------------------
GET_SIZE
    JSR         DOT
    CMP.B       #1, D4
    BEQ         BYTE
    CMP.B       #3, D4
    BEQ         WORD
    CMP.B       #2, D4
    BEQ         LONG  
    RTS
    
GET_REG ******************
    MOVE.L      D5, D1 
    MOVE.B      D1, (A1)+
    RTS
    
GET_OPMODE
    JSR         DOT
    CMP.B       #3, D4
    BEQ         WORD
    CMP.B       #7, D4
    BEQ         LONG
    RTS
    
GET_OPMODE_MATH
    JSR         DOT
    CMP.B       #0, D4
    BEQ         BYTE
    CMP.B       #4, D4
    BEQ         BYTE
    CMP.B       #1, D4
    BEQ         WORD
    CMP.B       #5, D4
    BEQ         WORD
    CMP.B       #2, D4
    BEQ         LONG
    CMP.B       #6, D4
    BEQ         LONG
    RTS
    
GET_DATA ******************
    JSR         POUND
    CMP.B       #0, D5
    BEQ         PRINT_8
    MOVE.L      D5, D1
    MOVE.B      D1, (A3)+
    RTS
    
PRINT_8 ********
    MOVE.L      #8, D1
    MOVE.B      D1, (A3)+
    RTS
    
GET_SIZE_ADDI
    JSR         DOT
    CMP.B       #0, D4
    BEQ         BYTE
    CMP.B       #1, D4
    BEQ         WORD
    CMP.B       #2, D4
    BEQ         LONG  
    RTS
    
TYPE_CHOOSER
    CMP.B       #0, D4      *IF IMMEDIATE
    BEQ         GET_DATA    *IF BRANCHED  ->  #1 IS NOW PRINTED
    CMP.B       #1, D4      *IF A DATA REG
    BEQ         DATA_0
    RTS
    
PRINT_BCC
    CMP.B       #4, D4
    BEQ         CC
    CMP.B       #14, D4
    BEQ         GT
    CMP.B       #15, D4
    BEQ         LE
    RTS
    
REG_SIZE
    JSR         DOT
    CMP.B       #0, D4
    BEQ         WORD
    CMP.B       #1, D4
    BEQ         LONG
    RTS
*-------------------------END HELPERS----------------------------
*---------------------START CHANGE MODE--------------------------
MODE_CHOOSER
    CMP.B       #7, D4
    BEQ         NEW_MODE
    RTS
    
NEW_MODE
    CMP.B       #0, D5 *CHECK REGISTER(D5), WORD ADDRESS?
    BEQ         TO_FIVE *CHANGE MODE (D4) TO 5
    CMP.B       #1, D5 *CHECK REGISTER(D5), LONG ADDRESS?
    BEQ         TO_SIX *CHANGE MODE(D4) TO 6
    RTS
    
TO_SIX  
    SUB.B      #1, D4
    RTS

TO_FIVE
    SUB.B      #2, D4
    RTS
*---------------------------END CHANGE MODE-----------------------
*--------------------------START PRINT HEX------------------------

OUTPUT_HEX
    *OUTPUT 1ST
    MOVE.W      D2, D7              *D7 = <1010 1111 0101 0111>
    LSR.W       #8, D7              *D7 = <0000 0000 1010 1111>
    LSR.W       #4, D7              *D7 = <0000 0000 0000 1010>
    MOVE.B      D7, D1
    BSR         CONVERT_TO_ASCII    *convert value in D1, to ascii
    BSR         ADD_CHAR         *print the char in D1  
    *OUTPUT 2ND
    MOVE.W      D2, D7
    LSL.W       #4, D7              *SHIFT OUT FURTHEST RIGHT BIT
    LSR.W       #8, D7
    LSR.W       #4, D7  
    MOVE.B      D7, D1
    BSR         CONVERT_TO_ASCII
    BSR         ADD_CHAR
    *OUTPUT 3RD
    MOVE.W      D2, D7
    LSL.W       #8, D7
    LSR.W       #8, D7
    LSR.W       #4, D7
    MOVE.B      D7, D1
    BSR         CONVERT_TO_ASCII
    BSR         ADD_CHAR
    *OUTPUT 4TH
    MOVE.W      D2, D7  *D7 = <1010 1111 0101 0111>
    LSL.W       #8, D7  *     <0101 0111 0000 0000>
    LSL.W       #4, D7  *     <0111 0000 0000 0000>
    LSR.W       #8, D7  *     <
    LSR.W       #4, D7
    MOVE.B      D7, D1
    BSR         CONVERT_TO_ASCII
    BSR         ADD_CHAR
    RTS

*CONVERT_TO_ASCII                                                ****************************************************** I commented these out, defined twice
*    CMP.B       #9,D1           *compare value with 9
*    BGT         ALPH_CHAR       *convert to numeric ascii
*    BRA         NUMERIC_CHAR    *convert to alphabetical ascii
*NUMERIC_CHAR        
*    ADD.B       #48,D1          *convert to ascii value
*    RTS                         *continue converting
*ALPH_CHAR
*    ADD.B       #55,D1          *convert to ascii value
*    RTS
                                   *continue converting            
ADD_CHAR ********
    MOVE.B      D1, (A3)+

*---------------------------END PRINT HEX------------------------
*---------------------------START CHARACTERS---------------------------
COMMA
    MOVE.B      M_COMMA, (A3)+
    RTS
    
POUND
    MOVE.B      M_POUND, (A3)+
    RTS
        
DOT
    MOVE.B      M_DOT, (A3)+
    RTS   
    
WORD
    MOVE.B      M_WORD, (A3)+
    JSR         SPACE
    RTS

BYTE
    MOVE.B      M_BYTE, (A3)+
    JSR         SPACE
    RTS
    
LONG
    MOVE.B      M_LONG, (A3)+
    JSR         SPACE
    RTS
    
OPEN
    MOVE.B      M_OPEN, (A3)+
    RTS

CLOSE
    MOVE.B      M_CLOSE, (A3)+
    RTS
    
PLUS
    MOVE.B      M_PLUS, (A3)+
    RTS
    
SUB
    MOVE.B      M_SUB, (A3)+
    RTS
    
*SPACE
*    MOVE.B      M_SPACE, (A3)+  ****************************************************** I commented this out, defined twice
*    RTS    
    
CASH
    MOVE.B      M_CASH, (A3)+
    RTS

CC
    MOVE.B      M_CC, (A3)+
    RTS
GT
    MOVE.B      M_GT, (A3)+
    RTS

LE
    MOVE.B      M_LE, (A3)+
    RTS
    
SLASH
    MOVE.B      M_SLASH, (A3)+
    RTS
    
INVALID
    MOVE.B      M_INVAL, (A3)+
*----------------------------END CHARACTERS---------------------------        

CR      EQU     $0D
LF      EQU     $0A

M_INVAL DC.B 'INVALID',0
M_CASH  DC.B '$',0
*M_SPACE DC.B ' ',0             ****************************************************** I commented this out, defined twice
M_COMMA DC.B ',',0
M_POUND DC.B '#',0
M_DOT   DC.B '.',0
M_WORD  DC.B 'W',0
M_BYTE  DC.B 'B',0
M_LONG  DC.B 'L',0
M_OPEN  DC.B '(',0
M_CLOSE DC.B ')',0
M_PLUS  DC.B '+',0
M_SUB   DC.B '-',0
M_DREG  DC.B 'D',0
M_AREG  DC.B 'A',0
M_CC    DC.B 'CC',0
M_GT    DC.B 'GT',0
M_LE    DC.B 'LE',0
M_SLASH DC.B '/',0

    END    START

*END
*A7 will be the address of the string that opcode is saved to 
*A5 will be the start of the DATA address
*-------------------------------------*

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
