*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
MAIN:                  ; first instruction of program
    BRA             3333
    BRA             INPUT_START
    
    INCLUDE         'Main.X68'
    INCLUDE         'OP_jumpTable.X68'
    INCLUDE         'EFFECTIVE_ADDRESSES.X68'

    SIMHALT             ; halt simulator

CR          EQU     $0D
LF          EQU     $0A

M_INPUT_START DC.B 'Please enter starting memory address in hexadecimal:',CR,LF,0
M_INPUT_END   DC.B 'Please enter ending memory address in hexadecimal:',CR,LF,0
M_INVALID     DC.B 'Invalid value. Please enter a valid value: ',CR,LF,0
M_EQUAL       DC.B 'Equal values. No memory read. Please enter new values',CR,LF,0
M_DATA        DC.B 'DATA    ',0
M_TAB         DC.B '    ',0
M_PRESS_CONT  DC.B 'Press any key to continue',0

STRING_START    EQU     $0500
DATA_START      EQU     $0400

MEM_START       EQU     $0100
MEM_END         EQU     $0200

M_SPACE       DC.B  ' ',0
M_NEW_LINE    DC.B  '',CR,LF,0

STOP:
    END    MAIN







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
