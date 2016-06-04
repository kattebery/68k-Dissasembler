*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
MAIN:                  ; first instruction of program
    ADDI.L          #9, D1
    MOVE.B          D1, D2

    BRA             INPUT_START
    
    INCLUDE         'Main.X68'
    INCLUDE         'OP_jumpTable.X68'
    INCLUDE         'EFFECTIVE_ADDRESSES.X68'

END
    JSR             IM_NEW_LINE
    LEA             M_END,A1
    MOVE.B          #14,D0
    TRAP            #15
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
M_FINISHED    DC.B 'Finished Reading Memory',CR,LF,0
M_CONTINUE    DC.B 'Would you like to read memory again? (Y/N)',0
M_END         DC.B 'Program Exit',CR,LF,0

STRING_START    EQU     $0500
DATA_START      EQU     $0400

MEM_START       EQU     $0100
MEM_END         EQU     $0200

M_SPACE       DC.B  ' ',0
M_NEW_LINE    DC.B  '',CR,LF,0

ADDI    DC.B    'ADDI',0
MOVE    DC.B    'MOVE',0
MOVEA   DC.B    'MOVEA',0
OPCLR   DC.B    'CLR',0
OPLEA   DC.B    'LEA',0
OPJSR   DC.B    'JSR',0
OPNOP   DC.B    'NOP',0
OPRTS   DC.B    'RTS',0
MOVEM   DC.B    'MOVEM',0
ADDQ    DC.B    'ADDQ',0
Bcc     DC.B    'B',0
MOVEQ   DC.B    'MOVEQ',0
DIVU    DC.B    'DIVU',0
OR      DC.B    'OR',0
OPSUB   DC.B    'SUB',0
CMP     DC.B    'CMP',0
MULS    DC.B    'MULS',0
AND     DC.B    'AND',0
ADD     DC.B    'ADD',0
ADDA    DC.B    'ADDA',0
LSL     DC.B    'LSL',0
LSR     DC.B    'LSR',0
ASL     DC.B    'ASL',0
ASR     DC.B    'ASR',0
ROL     DC.B    'ROL',0
ROR     DC.B    'ROR',0
M_INVAL DC.B 'INVALID',0
M_CASH  DC.B '$',0
*M_SPACE DC.B ' ',0
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
M_C     DC.B 'C',0
M_G     DC.B 'G',0
M_T     DC.B 'T',0
M_E     DC.B 'E',0
M_L     DC.B 'L',0
M_R     DC.B 'R',0
M_A     DC.B 'A',0
M_SLASH DC.B '/',0


    INCLUDE         'demo_test.x68'
    INCLUDE         'testingFile.x68'

STOP:
    END    MAIN



















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
