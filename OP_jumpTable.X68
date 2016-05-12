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
    *SINGLE CODE, BEGIN OUTPUT
    
    MOVE.B *A CHAR TO ADDRESS REGISTER
    MOVE.B *D CHAR TO ADDRESS REGISTER
    MOVE.B *D CHAR TO ADDRESS REGISTER
    MOVE.B *I CHAR TO ADDRESS REGISTER

    JSR     SIZE_JTAB   *Jump to the size table
    
    *LEA NEXT SUBROUTINE
    *JUMP TO APPROPRIATE SUBROUTINE BY CMP (AND JSR? BEQ?)
    
    RTS


**************************************************************************
*        OP0001 - Subroutine for operations beginning with 0001          *
*        MOVE.B                                                          *
**************************************************************************
OP0001
    *SINGLE CODE, BEGIN OUTPUT
    
    MOVE.B *M CHAR TO ADDRESS REGISTER
    MOVE.B *O CHAR TO ADDRESS REGISTER
    MOVE.B *V CHAR TO ADDRESS REGISTER
    MOVE.B *E CHAR TO ADDRESS REGISTER
    MOVE.B *. CHAR TO ADDRESS REGISTER
    MOVE.B *B CHAR TO ADDRESS REGISTER

    *KNOW THE SIZE ALREADY, NO SIZE_JTAB NEEDED
    
    *LEA NEXT SUBROUTINE
    *JUMP TO APPROPRIATE SUBROUTINE BY CMP (AND JSR?)
    
    RTS

**************************************************************************
*        OP0010 - Subroutine for operations beginning with 0010          *
*        MOVE.W, MOVEA(WORD)                                             *
**************************************************************************
OP0010
    *MULTIPLE CODE, STORE AND CHECK NEXT
    
    *MOVE THE DATA TO REGISTER
    LSR.W   #$4, DXXXXX     *Shift left four bits
    ANDI.W  #$000F, DXXXXX  *Get the first four bits
    MULU    #4, DXXXXX      *Get the offset

    *KNOW THE SIZE ALREADY, NO SIZE_JTAB NEEDED
    
    *LEA NEXT SUBROUTINE
    *JUMP TO APPROPRIATE SUBROUTINE BY CMP (AND JSR? BEQ?)
    
    RTS

**************************************************************************
*        OP0011 - Subroutine for operations beginning with 0011          *
*        MOVE.L, MOVEA(LONG)                                             *
**************************************************************************
OP0011
    *MULTIPLE CODE, STORE AND CHECK NEXT
    
    *MOVE THE DATA TO REGISTER
    LSR.W   #$4, DXXXXX     *Shift left four bits
    ANDI.W  #$000F, DXXXXX  *Get the first four bits
    MULU    #4, DXXXXX      *Get the offset

    *KNOW THE SIZE ALREADY, NO SIZE_JTAB NEEDED
    
    *LEA NEXT SUBROUTINE
    *JUMP TO APPROPRIATE SUBROUTINE BY CMP (AND JSR? BEQ?)
    
    RTS

**************************************************************************
*        OP0100 - Subroutine for operations beginning with 0100          *
*        NOP, MOVEM, MULS(LONG), DIVU(LONG), LEA, CLR, JSR, RTS          *
**************************************************************************
OP0100
    *MULTIPLE CODE, STORE AND CHECK NEXT
    
    *MOVE THE DATA TO REGISTER
    LSR.W   #$4, DXXXXX     *Shift left four bits
    ANDI.W  #$000F, DXXXXX  *Get the first four bits
    MULU    #4, DXXXXX      *Get the offset

    JSR     SIZE_JTAB   *Jump to the size table
    
    *LEA NEXT SUBROUTINE
    *JUMP TO APPROPRIATE SUBROUTINE BY CMP (AND JSR? BEQ?)
    
    RTS
    
**************************************************************************
*        OP0101 - Subroutine for operations beginning with 0101          *
*        ADDQ                                                            *
**************************************************************************
OP0101
    *SINGLE CODE, BEGIN OUTPUT
    
    MOVE.B *A CHAR TO ADDRESS REGISTER
    MOVE.B *D CHAR TO ADDRESS REGISTER
    MOVE.B *D CHAR TO ADDRESS REGISTER
    MOVE.B *Q CHAR TO ADDRESS REGISTER
    
    JSR     SIZE_JTAB   *Jump to the size table
    
    *LEA NEXT SUBROUTINE
    *JUMP TO APPROPRIATE SUBROUTINE BY CMP (AND JSR? BEQ?)
    
    RTS
    
**************************************************************************
*        OP0110 - Subroutine for operations beginning with 0110          *
*        MOVEQ, Bcc                                                      *
**************************************************************************
OP0110
    *MULTIPLE CODE, STORE AND CHECK NEXT
    
    *MOVE THE DATA TO REGISTER
    LSR.W   #$4, DXXXXX     *Shift left four bits
    ANDI.W  #$000F, DXXXXX  *Get the first four bits
    MULU    #4, DXXXXX      *Get the offset

    JSR     SIZE_JTAB   *Jump to the size table
    
    *LEA NEXT SUBROUTINE
    *JUMP TO APPROPRIATE SUBROUTINE BY CMP (AND JSR? BEQ?)
    
    RTS
    
**************************************************************************
*        OP1000 - Subroutine for operations beginning with 1000          *
*        DIVU(WORD), OR                                                  *
**************************************************************************
OP1000
    *MULTIPLE CODE, STORE AND CHECK NEXT
    
    *MOVE THE DATA TO REGISTER
    LSR.W   #$4, DXXXXX     *Shift left four bits
    ANDI.W  #$000F, DXXXXX  *Get the first four bits
    MULU    #4, DXXXXX      *Get the offset
    
    *NO SIZE_JTAB NEEDED

    *LEA NEXT SUBROUTINE
    *JUMP TO APPROPRIATE SUBROUTINE BY CMP (AND JSR? BEQ?)
    
    RTS

**************************************************************************
*        OP1001 - Subroutine for operations beginning with 1001          *
*        SUB                                                             *
**************************************************************************
OP1001
    *SINGLE CODE, BEGIN OUTPUT
    
    MOVE.B *S CHAR TO ADDRESS REGISTER
    MOVE.B *U CHAR TO ADDRESS REGISTER
    MOVE.B *B CHAR TO ADDRESS REGISTER
    
    JSR     SIZE_JTAB   *Jump to the size table
    
    *LEA NEXT SUBROUTINE
    *JUMP TO APPROPRIATE SUBROUTINE BY CMP (AND JSR? BEQ?)
    
    RTS
    

**************************************************************************
*        OP1011 - Subroutine for operations beginning with 1011          *
*        CMP                                                             *
**************************************************************************
OP1011
    *SINGLE CODE, BEGIN OUTPUT
    
    MOVE.B *C CHAR TO ADDRESS REGISTER
    MOVE.B *M CHAR TO ADDRESS REGISTER
    MOVE.B *P CHAR TO ADDRESS REGISTER
    
    *NO SIZE_JTAB NEEDED
    
    *LEA NEXT SUBROUTINE
    *JUMP TO APPROPRIATE SUBROUTINE BY CMP (AND JSR? BEQ?)
    
    RTS


**************************************************************************
*        OP1100 - Subroutine for operations beginning with 1100          *
*        MULS(WORD), AND                                                 *
**************************************************************************
OP1100
    *MULTIPLE CODE, STORE AND CHECK NEXT
    
    *MOVE THE DATA TO REGISTER
    LSR.W   #$4, DXXXXX     *Shift left four bits
    ANDI.W  #$000F, DXXXXX  *Get the first four bits
    MULU    #4, DXXXXX      *Get the offset

    JSR     SIZE_JTAB   *Jump to the size table
    
    *LEA NEXT SUBROUTINE
    *JUMP TO APPROPRIATE SUBROUTINE BY CMP (AND JSR? BEQ?)
    
    RTS
    
**************************************************************************
*        OP1101 - Subroutine for operations beginning with 1101          *
*        ADD, ADDA                                                       *
**************************************************************************
OP1101
    *MULTIPLE CODE, STORE AND CHECK NEXT
    
    *MOVE THE DATA TO REGISTER
    LSR.W   #$4, DXXXXX     *Shift left four bits
    ANDI.W  #$000F, DXXXXX  *Get the first four bits
    MULU    #4, DXXXXX      *Get the offset

    JSR     SIZE_JTAB   *Jump to the size table
    
    *LEA NEXT SUBROUTINE
    *JUMP TO APPROPRIATE SUBROUTINE BY CMP (AND JSR? BEQ?)
    
    RTS
    
    
**************************************************************************
*        OP1110 - Subroutine for operations beginning with 1110          *
*        LSR, LSL, ASR, ASL, ROL, ROR                                    *
**************************************************************************
OP1110
    *MULTIPLE CODE, STORE AND CHECK NEXT
    
    *MOVE THE DATA TO REGISTER
    LSR.W   #$4, DXXXXX     *Shift left four bits
    ANDI.W  #$000F, DXXXXX  *Get the first four bits
    MULU    #4, DXXXXX      *Get the offset

    *NO SIZE_JTAB NEEDED

    *LEA NEXT SUBROUTINE
    *JUMP TO APPROPRIATE SUBROUTINE BY CMP (AND JSR? BEQ?)
    
    RTS




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
