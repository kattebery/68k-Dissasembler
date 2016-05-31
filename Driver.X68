*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
MAIN:                  ; first instruction of program
    BRA             INPUT_START
    
    INCLUDE         'Main.X68'
    INCLUDE         'OP_jumpTable.X68'
*    INCLUDE         'EFFECTIVE_ADDRESSES_2.o.X68'

    SIMHALT             ; halt simulator

* Put variables and constants here

STOP:
    END    MAIN



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
