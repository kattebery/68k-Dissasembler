    **Call GET4 here, reference to jump table and begin cycle

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
    JMP     OP1000      *Subroutine for operations beginning with 1000
    JMP     OP1001      *Subroutine for operations beginning with 1001
    JMP     OP1011      *Subroutine for operations beginning with 1011
    JMP     OP1100      *Subroutine for operations beginning with 1100
    JMP     OP1101      *Subroutine for operations beginning with 1101
    JMP     OP1110      *Subroutine for operations beginning with 1110
    
    BRA     OP_DATA     *Subroutine to store as non-decodable


**************************************************************************
*        OP0000 - Subroutine for operations beginning with 0000          *
*        ADDI                                                            *
**************************************************************************
OP0000
    *SINGLE CODE, BEGIN OUTPUT
    
    LEA     ADDI,(AXXXX)+
    BRA     EA_ADDI

ADDI    DC.B    "ADDI"

**************************************************************************
*        OP0001 - Subroutine for operations beginning with 0001          *
*        MOVE.B                                                          *
**************************************************************************
OP0001
    *SINGLE CODE, BEGIN OUTPUT

    LEA     MOVEB,(AXXXX)+
    BRA     EA_MOVEB    
    
MOVEB   DC.B    "MOVE.B"

**************************************************************************
*        OP0010 - Subroutine for operations beginning with 0010          *
*        MOVE.W, MOVEA(WORD)                                             *
**************************************************************************
OP0010
    *MULTIPLE CODE, STORE AND CHECK NEXT
    
    JSR     GET3            *Get3 twice as both contain reg in 456
    JSR     GET3            
    CMP     #%001,DXXXXX    *Check for 001 to eliminate MOVEA.W
    BEQ     _MOVEAW
    BRA     _MOVEW
    
********* MOVEW *************        
_MOVEW
    LEA     MOVEW,(AXXXX)+
    BRA     EA_MOVEW
MOVEW     DC.B    "MOVE.W"

********* MOVEAW *************        
_MOVEAW
    LEA     MOVEAW,(AXXXX)+
    BRA     EA_MOVEAW
MOVEAW     DC.B    "MOVEA.W"


**************************************************************************
*        OP0011 - Subroutine for operations beginning with 0011          *
*        MOVE.L, MOVEA(LONG)                                             *
**************************************************************************
OP0011
    *MULTIPLE CODE, STORE AND CHECK NEXT
    
    JSR     GET3            *Get3 twice as both contain reg in 456
    JSR     GET3            
    CMP     #%001,DXXXXX    *Check for 001 to eliminate MOVEA.W
    BEQ     _MOVEAL
    BRA     _MOVEL
    
********* MOVEW *************        
_MOVEL
    LEA     MOVEL,(AXXXX)+
    BRA     EA_MOVEL
MOVEL     DC.B    "MOVE.L"

********* MOVEAW *************        
_MOVEAL
    LEA     MOVEAL,(AXXXX)+
    BRA     EA_MOVEAL
MOVEAL     DC.B    "MOVEA.L"

**************************************************************************
*        OP0100 - Subroutine for operations beginning with 0100          *
*        NOP, MOVEM, LEA, CLR, JSR, RTS                                  *
**************************************************************************
OP0100
    *MULTIPLE CODE, STORE AND CHECK NEXT
    
    JSR     GET3
    CMP     #%001,DXXXXX    *Check for 001 to eliminate CLR
    BEQ     _CLR
    BRA     0100_1

0100_1 **Could be MOVEM, LEA, NOP, JSR, or RTS**

    JSR     GET3
    
    CMP     #%111,DXXXX     *Check for 111 to eliminate LEA
    BEQ     _LEA
    
    CMP     #%010,DXXXX     *Check for 010 to eliminate JSR
    BEQ     _JSR     
    
    BRA     0100_2

0100_2 **Could be MOVEM, NOP, or RTS**

    JSR     GET3            *Get3 twice as NOP and RTS both contain
    JSR     GET3            *110 in ABC
    
    CMP     #%001,DXXXX     *Check for 001 to eliminate NOP
    BEQ     _NOP
    
    CMP     #%101,DXXXX     *Check for 101 to eliminate RTS
    BEQ     _RTS
    
    BRA     _MOVEM          *NOT FOUND YET, MUST BE MOVEM
    
    
********* CLR *************        
_CLR
    LEA     CLR,(AXXXX)+
    BRA     EA_CLR
CLR     DC.B    "CLR"

********* LEA *************        
_LEA
    LEA     LEA,(AXXXX)+
    BRA     EA_LEA
LEA     DC.B    "LEA"

********* JSR *************     
_JSR
    LEA     JSR,(AXXXX)+
    BRA     EA_JSR
JSR     DC.B    "JSR"

********* NOP *************     
_NOP
    LEA     NOP,(AXXXX)+
    BRA     EA_NOP
NOP     DC.B    "NOP"

********* RTS *************     
_RTS
    LEA     RTS,(AXXXX)+
    BRA     EA_RTS
RTS     DC.B    "RTS"

********* MOVEM *************     
_MOVEM
    LEA     MOVEM,(AXXXX)+
    BRA     EA_MOVEM
MOVEM     DC.B    "MOVEM"
    
**************************************************************************
*        OP0101 - Subroutine for operations beginning with 0101          *
*        ADDQ                                                            *
**************************************************************************
OP0101
    *SINGLE CODE, BEGIN OUTPUT
    
    LEA     ADDQ,(AXXXX)+
    BRA     EA_ADDQ
    
ADDQ   DC.B    "ADDQ"
    
**************************************************************************
*        OP0110 - Subroutine for operations beginning with 0110          *
*        Bcc                                                             *
**************************************************************************
OP0110
    *SINGLE CODE, BEGIN OUTPUT
    
    LEA     Bcc,(AXXXX)+
    BRA     EA_Bcc
    
Bcc  DC.B    "Bcc"

**************************************************************************
*        OP0111 - Subroutine for operations beginning with 0101          *
*        MOVEQ                                                           *
**************************************************************************
OP0101
    *SINGLE CODE, BEGIN OUTPUT
    
    LEA     MOVEQ,(AXXXX)+
    BRA     EA_MOVEQ
    
MOVEQ   DC.B    "MOVEQ"
    
**************************************************************************
*        OP1000 - Subroutine for operations beginning with 1000          *
*        DIVU, OR                                                        *
**************************************************************************
OP1000
    *MULTIPLE CODE, STORE AND CHECK NEXT  
    JSR     GET3            *Get3 twice as both contain reg in 456
    JSR     GET3            
    CMP     #%011,DXXXXX    *Check for 011 to eliminate DIVU
    BEQ     _DIVU
    BRA     _OR
    
********* DIVU *************        
_DIVU
    LEA     DIVU,(AXXXX)+
    BRA     EA_DIVU
DIVU     DC.B    "DIVU"

********* OR *************        
_OR
    LEA     OR,(AXXXX)+
    BRA     EA_OR
OR       DC.B    "OR"

**************************************************************************
*        OP1001 - Subroutine for operations beginning with 1001          *
*        SUB                                                             *
**************************************************************************
OP1001
    *SINGLE CODE, BEGIN OUTPUT
    
    LEA     SUB,(AXXX)+
    BRA     EA_SUB

SUB     DC.B    "SUB"

**************************************************************************
*        OP1011 - Subroutine for operations beginning with 1011          *
*        CMP                                                             *
**************************************************************************
OP1011
    *SINGLE CODE, BEGIN OUTPUT
    LEA     CMP,(AXXX)+
    BRA     EA_CMP

CMP     DC.B    "CMP"

**************************************************************************
*        OP1100 - Subroutine for operations beginning with 1100          *
*        MULS, AND                                                       *
**************************************************************************
OP1100
    *MULTIPLE CODE, STORE AND CHECK NEXT  
    JSR     GET3            *Get3 twice as both contain reg in 456
    JSR     GET3            
    CMP     #%111,DXXXXX    *Check for 111 to eliminate MULS
    BEQ     _MULS
    BRA     _AND
    
********* MULS *************        
_MULS
    LEA     MULS,(AXXXX)+
    BRA     EA_MULS
MULS     DC.B    "MULS"

********* AND *************        
_AND
    LEA     AND,(AXXXX)+
    BRA     EA_AND
AND       DC.B    "AND"
    
**************************************************************************
*        OP1101 - Subroutine for operations beginning with 1101          *
*        ADD, ADDA                                                       *
**************************************************************************
OP1101
    *MULTIPLE CODE, STORE AND CHECK NEXT  
    JSR     GET3            *Get3 twice as both contain reg in 456
    JSR     GET3            
    CMP     #%011,DXXXXX    *Check for 011 to eliminate ADDA (Size dependant)
    BEQ     _ADDA
    CMP     #%111,DXXXX     *Check for 111 to eliminate ADDA (Size dependant)
    BEQ     _ADDA
    BRA     _AND
    
********* ADD *************        
_ADD
    LEA     ADD,(AXXXX)+
    BRA     EA_ADD
ADD     DC.B    "ADD"

********* AND *************        
_ADDA
    LEA     ADDA,(AXXXX)+
    BRA     EA_ADDA
ADDA      DC.B    "ADDA" 
    
**************************************************************************
*        OP1110 - Subroutine for operations beginning with 1110          *
*        LSR, LSL, ASR, ASL, ROL, ROR                                    *
**************************************************************************
OP1110
    *MULTIPLE CODE, STORE AND CHECK NEXT
    JSR     GET3                  
    CMP     #%001,DXXXXX    *Check for001 to eliminate LSd
    BEQ     _LSd
    BRA     1110_1
    
1110_1
    JSR     GET3            *Get3 twice as both ambiguous in 789
    JSR     GET3
                  
    CMP     #%000,DXXXXX    *Check for 000 to eliminate ASd (Rotation dependant)
    BEQ     _ASd
    CMP     #%100,DXXXXX    *Check for 100 to eliminate ASd (Rotation dependant)
    BEQ     _ASd
    BRA     ROd
    
********* LSd *************        
_LSd
    CMP     #%011,DXXXX
    BEQ     _LSR
    BRA     _LSL

_LSL    
    LEA     LSL,(AXXXX)+
    BRA     EA_LSL
LSL     DC.B    "LSL"

_LSR
    LEA     LSR,(AXXXX)+
    BRA     EA_LSR
LSR     DC.B    "LSR"

********* ASd *************      ****BROKEN****  
_ASd
    CMP     #%XXX,DXXXX        
    BEQ     _ASR
    BRA     _ASL

_ASL    
    LEA     ASL,(AXXXX)+
    BRA     EA_ASL
ASL     DC.B    "ASL"

_ASR
    LEA     ASR,(AXXXX)+
    BRA     EA_ASR
ASR     DC.B    "ASR"
********* ROd *************      ****BROKEN****  
_ROd

_LSL    
    LEA     LSL,(AXXXX)+
    BRA     EA_LSL
LSL     DC.B    "LSL"

_LSR
    LEA     LSR,(AXXXX)+
    BRA     EA_LSR
LSR     DC.B    "LSR"

**************************************************************************
**************************************************************************
*              *
*                                           *
**************************************************************************
**************************************************************************
GET4  
    MOVE.W  Dg,D5   *Copy instruction for modification
    LSL.W   #4,D5   *Shift left four bits


    LEA OP_JTAB,A0
    JSR A0,D5
    RTS

GET3
    RTS


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
