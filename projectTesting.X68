*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

    MOVE.L      #$2000,A1        *set address of register A1
*----Display input message for mem start-----*
INPUT_START
    LEA         M_INPUT_START,A1      *load message
    MOVE.B      #14,D0          *display string
    TRAP        #15             *output string
*----Receive User Input ------
    MOVE.B      #2,D0           *input string into A1 Trap
    TRAP        #15   
    
    CLR         D3              *D3 will act as the total result
    MOVE.L      #$A1,A4         *the stop address
    MOVE.B      #7,D2           *put 7 in D2
    ADD.W       D2,A4        



    SIMHALT             ; halt simulator

CR          EQU     $0D
LF          EQU     $0A

M_INPUT_START DC.B 'Please enter starting memory address in hexadecimal:',CR,LF,0


    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
