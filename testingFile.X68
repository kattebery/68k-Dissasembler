*-----------------------------------------------------------
* Title      : testing
* Written by : John, Blake, Kristen
* Date       : 5/7/16
* Description: Test... trying to figure out exactly how extensive this needs to be
*
* Marked the ones I feel relativley good about with (good)
*   could still be wrong tho....
*--------------------------------------------------------
*
*Instructions:
*
*NOP
*MOVE + MOVEA + MOVEQ + MOVEM
*ADD + ADDA + ADDI + ADDQ
*SUB
*MULS
*DIVU
*LEA
*CLR
*AND
*OR
*LSL + LSR + ASL + ASR
*ROL + ROR
*CMP
*BCC (BCC + BGT + BLE)
*JSR
*RTS
*
*Addressing:
*
*Data Register Direct....................Dn
*Address Register Direct.................An
*Address Register Indirect...............(An)
*Immediate Data..........................#<stuff>
*Address RegInd Post Increment...........(An)+
*Address RegInd Pre Decrement............-(An)
*Absolute WORD Address...................(stuff).W      
*Absolute LONG Address...................(stuff).L
*-----------------------------------------------------------
    ORG    $3000
        

    *NOP* DONE
    *NOP
    
    *MOVE* DONE
    *MOVE SOURCE: DATA REGISTER -> DN
    MOVE.B      D1, D2
    MOVE.B      D1, (A1)
    MOVE.B      D1, (A1)+
    MOVE.B      D1, -(A1)
    MOVE.B      D1, $1234
    MOVE.B      D1, $12345678
    MOVE.W      D1, D2
    MOVE.W      D1, (A1)
    MOVE.W      D1, (A1)+
    MOVE.W      D1, -(A1)
    MOVE.W      D1, $1234
    MOVE.W      D1, $12345678
    MOVE.L      D1, D2
    MOVE.L      D1, (A1)
    MOVE.L      D1, (A1)+
    MOVE.L      D1, -(A1)
    MOVE.L      D1, $1234
    MOVE.L      D1, $12345678
    *MOVE SOURCE: ADDRESS REGISTER -> AN
    *INVALID: MOVE.B      
    MOVE.W       A1, D1
    MOVE.W       A1, A2
    MOVE.W       A1, (A2)
    MOVE.W       A1, -(A2)
    MOVE.W       A1, (A2)+
    MOVE.W       A1, $1234
    MOVE.W       A1, $12345678
    MOVE.L      A1, D1
    MOVE.L      A1, A2
    MOVE.L      A1, (A2)
    MOVE.L      A1, -(A2)
    MOVE.L      A1, (A2)+
    MOVE.L      A1, $1234
    MOVE.L      A1, $12345678
    *MOVE SOURCE: ADDRESS REGISTER INDIRECT -> (AN)
    MOVE.B       (A1), D1
    MOVE.B       (A1), (A2)
    MOVE.B       (A1), -(A2)
    MOVE.B       (A1), (A2)+
    MOVE.B       (A1), $1234
    MOVE.B       (A1), $12345678
    MOVE.W       (A1), D1
    MOVE.W       (A1), (A2)
    MOVE.W       (A1), -(A2)
    MOVE.W       (A1), (A2)+
    MOVE.W       (A1), $1234
    MOVE.W       (A1), $12345678
    MOVE.L      (A1), D1
    MOVE.L      (A1), (A2)
    MOVE.L      (A1), -(A2)
    MOVE.L      (A1), (A2)+
    MOVE.L      (A1), $1234
    MOVE.L      (A1), $12345678
    *MOVE SOURCE: ADDRESS REG IND POST INCREMENT
    MOVE.B       (A1)+, D1
    MOVE.B       (A1)+, (A2)
    MOVE.B       (A1)+, (A2)+
    MOVE.B       (A1)+, -(A2)
    MOVE.B       (A1)+, $1234
    MOVE.B       (A1)+, $12345678
    MOVE.W       (A1)+, D1
    MOVE.W       (A1)+, (A2)
    MOVE.W       (A1)+, (A2)+
    MOVE.W       (A1)+, -(A2)
    MOVE.W       (A1)+, $1234
    MOVE.W       (A1)+, $12345678
    MOVE.L      (A1)+, D1
    MOVE.L      (A1)+, (A2)
    MOVE.L      (A1)+, (A2)+
    MOVE.L      (A1)+, -(A2)
    MOVE.L      (A1)+, $1234
    MOVE.L      (A1)+, $12345678
    *MOVE SOURCE: ADDRESS REG IND PRE DECREMENT
    MOVE.B       -(A1), D1
    MOVE.B       -(A1), (A2)
    MOVE.B       -(A1), (A2)+
    MOVE.B       -(A1), -(A2)
    MOVE.B       -(A1), $1234
    MOVE.B       -(A1), $12345678
    MOVE.W       -(A1), D1
    MOVE.W       -(A1), (A2)
    MOVE.W       -(A1), (A2)+
    MOVE.W       -(A1), -(A2)
    MOVE.W       -(A1), $1234
    MOVE.W       -(A1), $12345678
    MOVE.L      -(A1), D1
    MOVE.L      -(A1), (A2)
    MOVE.L      -(A1), (A2)+
    MOVE.L      -(A1), -(A2)
    MOVE.L      -(A1), $1234
    MOVE.L      -(A1), $12345678
    *MOVE SOURCE: ABSOLUTE WORD -> (XXX).W      
    MOVE.B       $1234, D1
    MOVE.B       $1235, (A2)
    MOVE.B       $9987, (A2)+
    MOVE.B       $5543, -(A2)
    MOVE.B       $1123, $1111
    MOVE.B       $9980, $AAA89999
    MOVE.W       $1234, D1
    MOVE.W       $1235, (A2)
    MOVE.W       $9987, (A2)+
    MOVE.W       $5543, -(A2)
    MOVE.W       $1123, $1111
    MOVE.W       $9980, $AAA89999
    MOVE.L      $1234, D1
    MOVE.L      $1235, (A2)
    MOVE.L      $9987, (A2)+
    MOVE.L      $5543, -(A2)
    MOVE.L      $1123, $1111
    MOVE.L      $9980, $AAA89999
    *MOVE SOURCE: ABSOLUTE LONG -> (XXX).L
    MOVE.B       $0FFF8111, D1
    MOVE.B       $0FFF8222, (A1)
    MOVE.B       $0FFF9999, (A1)+
    MOVE.B       $0FFF1111, -(A1)
    MOVE.B       $0FFF8799, $9879
    MOVE.B       $0FFF1222, $0FFF8878
    MOVE.W       $0FFF8111, D1
    MOVE.W       $0FFF8222, (A1)
    MOVE.W       $0FFF9999, (A1)+
    MOVE.W       $0FFF1111, -(A1)
    MOVE.W       $0FFF8799, $9879
    MOVE.W       $0FFF1222, $0FFF8878
    MOVE.L      $0FFF8111, D1
    MOVE.L      $0FFF8222, (A1)
    MOVE.L      $0FFF9999, (A1)+
    MOVE.L      $0FFF1111, -(A1)
    MOVE.L      $0FFF8799, $9879
    MOVE.L      $0FFF1222, $0FFF8878
    *MOVE SOURCE: IMMEDIATE DATA -> #<DATA>
    MOVE.B       #1, D1
    MOVE.B       #2, (A1)
    MOVE.B       #3, (A1)+
    MOVE.B       #4, -(A1)
    MOVE.B       #5, $1234
    MOVE.B       #6, $0FFF1234
    MOVE.W       #1111, D1
    MOVE.W       #2222, (A1)
    MOVE.W       #3333, (A1)+
    MOVE.W       #4444, -(A1)
    MOVE.W       #5555, $1234
    MOVE.W       #6666, $0FFF1234
    MOVE.L      #11111234, D1
    MOVE.L      #12342222, (A1)
    MOVE.L      #12343333, (A1)+
    MOVE.L      #12344444, -(A1)
    MOVE.L      #12345555, $1234
    MOVE.L      #12346666, $0FFF1234

    *MOVEA* (good) BYTES INVALID
    MOVEA.W       D2, A2
    MOVEA.W       A3, A2
    MOVEA.W       (A3), A2
    MOVEA.W       (A3)+, A2
    MOVEA.W       -(A3), A2
    MOVEA.W       $1050, A2
    MOVEA.W       $000F1050, A2
    MOVEA.W       #$1050, A2
    MOVEA.L      D2, A2
    MOVEA.L      A3, A2
    MOVEA.L      (A3), A2
    MOVEA.L      (A3)+, A2
    MOVEA.L      -(A3), A2
    MOVEA.L      $1050, A2
    MOVEA.L      $000F1050, A2
    MOVEA.L      #$1050, A2
    
    *MOVEQ* (good) ONLY WORKS ON LONGS
    MOVEQ.L      #255, D2
    MOVEQ.L      #$00000011, D2
    
    *MOVEM* move multiple registers... saving this for last i think
    
    *ADD* this one also weird with the whole effecive address thing...
    
    *ADDA* *good) ADDA CANT OPERATE ON BYTES
    ADDA.W       D2, A2
    ADDA.W       A3, A2
    ADDA.W       (A3), A2
    ADDA.W       (A3)+, A2
    ADDA.W       -(A3), A2
    ADDA.W       $1050, A2
    ADDA.W       $000F1050, A2
    ADDA.W       #$1050, A2
    ADDA.L      D2, A2
    ADDA.L      A3, A2
    ADDA.L      (A3), A2
    ADDA.L      (A3)+, A2
    ADDA.L      -(A3), A2
    ADDA.L      $1050, A2
    ADDA.L      $000F1050, A2
    ADDA.L      #$1050, A2
    
    *ADDI*  (good) BYTE DONE
    ADDI.B       #$12, D2
    ADDI.B       #$45, (A2)
    ADDI.B       #$56, (A2)+
    ADDI.B       #$67, -(A2)
    ADDI.B       #$56, $1060
    ADDI.B       #$89, $000F1060
    ADDI.W       #$1234, D2
    ADDI.W       #$2345, (A2)
    ADDI.W       #$3456, (A2)+
    ADDI.W       #$4567, -(A2)
    ADDI.W       #$5678, $1060
    ADDI.W       #$6789, $000F1060
    ADDI.L      #$1234, D2
    ADDI.L      #$2345, (A2)
    ADDI.L      #$3456, (A2)+
    ADDI.L      #$4567, -(A2)
    ADDI.L      #$5678, $1060
    ADDI.L      #$6789, $000F1060
    
    *ADDQ* (good) BYTE DONE, cant move a byte into an address reg...
    ADDQ.B        #1, D3
    ADDQ.B        #3, (A3)+
    ADDQ.B        #4, -(A3)
    ADDQ.B        #5, $1234
    ADDQ.B        #6, $000F1234
    ADDQ.W        #1, D3
    ADDQ.W        #2, A3
    ADDQ.W        #3, (A3)+
    ADDQ.W        #4, -(A3)
    ADDQ.W        #5, $1234
    ADDQ.W        #6, $000F1234
    ADDQ.L       #1, D3
    ADDQ.L       #2, A3
    ADDQ.L       #3, (A3)+
    ADDQ.L       #4, -(A3)
    ADDQ.L       #5, $1234
    ADDQ.L       #6, $000F1234
    
    *SUB*  same with the effective address thing
    
    *MULS*  same as sub and add
    
    *DIVU* same as sub add muls
    
    *LEA*   (good)
    LEA (A4), A3
    LEA $1234, A3
    LEA $12345678, A3
    LEA TEST_MESSAGE, A3
    
    *CLR*   (good) BYTE DONE
    CLR.B         D1
    CLR.B         (A1)
    CLR.B         (A1)+
    CLR.B         -(A1)
    CLR.B         $1234
    CLR.B         $12345678
    CLR.W         D1
    CLR.W         (A1)
    CLR.W         (A1)+
    CLR.W         -(A1)
    CLR.W         $1234
    CLR.W         $12345678
    CLR.L        D1
    CLR.L        (A1)
    CLR.L        (A1)+
    CLR.L        -(A1)
    CLR.L        $1234
    CLR.L        $12345678
    
    
    *AND*  damn it gonna have to look this up on github
    
    *OR*    and this
    
    *LSL* look up this
    
    *LSR*  and this
    
    *ASR*  and this
    
    *ASL*  and this
    
    *ROL*  and this
    
    *ROR*  and this
    
    *CMP*   (good) BYTE DONE.... cant do     CMP.B         A1, D2
    CMP.B         D1, D2
    CMP.B         (A1), D2
    CMP.B         (A1)+, D2
    CMP.B         -(A1), D2
    CMP.B         $1000, D2
    CMP.B         $00001002, D2
    CMP.W         D1, D2
    CMP.W         A1, D2
    CMP.W         (A1), D2
    CMP.W         (A1)+, D2
    CMP.W         -(A1), D2
    CMP.W         $1000, D2
    CMP.W         $00001002, D2
    CMP.L        D1, D2
    CMP.L        A1, D2
    CMP.L        (A1), D2
    CMP.L        (A1)+, D2
    CMP.L        -(A1), D2
    CMP.L        $1000, D2
    CMP.L        $00001002, D2
    
    *BCC*  look these up
    
    *BGT*   look these up 
    
    *BLE*   look these up
    
    *JSR*  (NOT SURE HOW TO TEST THIS CORRECTLY
    *JSR $1234
    *JSR $12345678
    *JSR (A4)
    
    *RTS* (good)
    RTS
    
    
    
    SIMHALT             ; halt simulator

*variables + constants here
TEST_MESSAGE    DC.B       'I LOVE APPLES',0








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
