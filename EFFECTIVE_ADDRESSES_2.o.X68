*-----------------------------------------------------------
* Title      : EFFECTIVE_ADDRESSES 2.o
* Written by : JOHN ZOELLER
* Date       : 5/24/16
* Description: ALL THE EFFECTIVE ADDRESSES
*-----------------------------------------------------------
    ORG    $1000
START:
    *EXAMPLE, MOVE A HEX CODE INTO D6
    *CALL THE CORRESPONDING EA CODE
    MOVE.W     #$2E7C, D6
    JSR         EA_MOVE
    BRA         BYEBYE
    *END EXAMPLE
    
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
    RTS
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
    RTS
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
    RTS
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
    RTS
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
    RTS
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
    RTS
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
    RTS
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
    RTS
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
    RTS
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
    RTS
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
    RTS
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
    RTS

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
    RTS
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
    RTS
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
    RTS
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
    
PRINT_ADDRESS
    BCC         JFF
    MOVE.B      D4, D5
    JSR         SLASH
    JSR         ADDR_1
    BRA         JFF  
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














BYEBYE
    SIMHALT















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

CONVERT_TO_ASCII
    CMP.B       #9,D1           *compare value with 9
    BGT         ALPH_CHAR       *convert to numeric ascii
    BRA         NUMERIC_CHAR    *convert to alphabetical ascii
NUMERIC_CHAR        
    ADD.B       #48,D1          *convert to ascii value
    RTS                         *continue converting
ALPH_CHAR
    ADD.B       #55,D1          *convert to ascii value
    RTS
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
    
SPACE
    MOVE.B      M_SPACE, (A3)+
    RTS    
    
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
M_SPACE DC.B ' ',0
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






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
