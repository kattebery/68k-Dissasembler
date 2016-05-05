**************************************************************************
*               Jump table 1. Determine OP code.                         *
*        Analyzes the first four bits within the instruction             *
*        and jumps to the corresponding subroutine.                      *
**************************************************************************
OP_JTAB
    JSR     OP0000      *Subroutine for operations beginning with 0000
    RTS
    JSR     OP0001      *Subroutine for operations beginning with 0001
    RTS
    JSR     OP0010      *Subroutine for operations beginning with 0010
    RTS
    JSR     OP0011      *Subroutine for operations beginning with 0011
    RTS
    JSR     OP0100      *Subroutine for operations beginning with 0100
    RTS
    JSR     OP0101      *Subroutine for operations beginning with 0101
    RTS
    JSR     OP0110      *Subroutine for operations beginning with 0110
    RTS
    JSR     OP1000      *Subroutine for operations beginning with 1000
    RTS
    JSR     OP1001      *Subroutine for operations beginning with 1001
    RTS
    JSR     OP1011      *Subroutine for operations beginning with 1011
    RTS
    JSR     OP1100      *Subroutine for operations beginning with 1100
    RTS
    JSR     OP1101      *Subroutine for operations beginning with 1101
    RTS
    JSR     OP1110      *Subroutine for operations beginning with 1110
    RTS
    
    *I don't know if this one is necessary:
    JSR     OP_DATA     *Subroutine to store as non-decodable
    RTS

**************************************************************************
*        OP0000 - Subroutine for operations beginning with 0000          *
*        ADDI                                                            *
**************************************************************************
OP0000
    *DO SOME THINGS
    RTS

**************************************************************************
*        OP0001 - Subroutine for operations beginning with 0001          *
*        MOVE.B                                                          *
**************************************************************************
OP0001
    *DO SOME THINGS
    RTS

**************************************************************************
*        OP0010 - Subroutine for operations beginning with 0010          *
*        MOVE.W, MOVEA(WORD)                                             *
**************************************************************************
OP0010
    *DO SOME THINGS
    RTS

**************************************************************************
*        OP0011 - Subroutine for operations beginning with 0011          *
*        MOVE.L, MOVEA(LONG)                                             *
**************************************************************************
OP0011
    *DO SOME THINGS
    RTS

**************************************************************************
*        OP0100 - Subroutine for operations beginning with 0100          *
*        NOP, MOVEM, MULS(LONG), DIVU(LONG), LEA, CLR, JSR, RTS          *
**************************************************************************
OP0100
    *DO SOME THINGS
    RTS

**************************************************************************
*        OP0101 - Subroutine for operations beginning with 0101          *
*        ADDQ                                                            *
**************************************************************************
OP0101
    *DO SOME THINGS
    RTS

**************************************************************************
*        OP0110 - Subroutine for operations beginning with 0110          *
*        MOVEQ, Bcc                                                      *
**************************************************************************
OP0110
    *DO SOME THINGS
    RTS

**************************************************************************
*        OP1000 - Subroutine for operations beginning with 1000          *
*        DIVU(WORD), OR                                                  *
**************************************************************************
OP1000
    *DO SOME THINGS
    RTS

**************************************************************************
*        OP1001 - Subroutine for operations beginning with 1001          *
*        SUB                                                             *
**************************************************************************
OP1001
    *DO SOME THINGS
    RTS

**************************************************************************
*        OP1011 - Subroutine for operations beginning with 1011          *
*        CMP                                                             *
**************************************************************************
OP1011
    *DO SOME THINGS
    RTS

**************************************************************************
*        OP1100 - Subroutine for operations beginning with 1100          *
*        MULS(WORD), AND                                                 *
**************************************************************************
OP1100
    *DO SOME THINGS
    RTS

**************************************************************************
*        OP1101 - Subroutine for operations beginning with 1101          *
*        ADD, ADDA                                                       *
**************************************************************************
OP1101
    *DO SOME THINGS
    RTS
    
**************************************************************************
*        OP1110 - Subroutine for operations beginning with 1110          *
*        LSR, LSL, ASR, ASL, ROL, ROR                                    *
**************************************************************************
OP1110
    *DO SOME THINGS
    RTS



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
