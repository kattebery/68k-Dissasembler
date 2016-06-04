*-----------------------------------------------------------
* Title      : EFFECTIVE_ADDRESSES 2.o
* Written by : JOHN ZOELLER
* Date       : 5/24/16
* Description: ALL THE EFFECTIVE ADDRESSES
*-----------------------------------------------------------
    
    
    *MULS IS A SPECIAL CASE BECAUSE I NEVER GET THIS SIZE
    
    
*-------------------------MOVE------------------------------------
EA_MOVE      *1 invalid; done 
*----------------SOURCE-------------------------------------------  
    CLR.L         D5
    MOVE.W      D0, D7 *DO THIS AT THE BEGGINING OF EVERY EA 
    
    MOVE.W      D7, D5      *
    LSR.W       #8, D5      *
    LSR.W       #4, D5      *D5 = SIZE 
    JSR         GET_SIZE    *D5 = <0000 0000 0000 0000 0000 0000 0000 0010>
    ROR.L       #8, D5      *D5 = <0000 0010 0000 0000 0000 0000 0000 0000>
    
    MOVE.W      D7, D4      *d5 = <0000 0010 0000 0000 xxx xxxx xxxx xxxX>
    LSL.W       #8, D4      *
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = <0000 0000> D4 = SOURCE MODE
    
    MOVE.W      D7, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      *D5 = SOURCE REGISTER
    
    JSR         MODE_CHOOSER
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS.W      #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
*---------------END SOURCE---------------------------------------
    JSR COMMA
    JSR SPACE
*--------------DESTINATION-------------------------------------
    MOVE.W      D7, D4      *
    LSL.W       #7, D4      *
    LSR.W       #7, D4      *
    LSR.W       #6, D4      *D4 = DESTINATION MODE
    JSR         MOVE_ERROR_CHECK 
    
    MOVE.W      D7, D5      *
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = DESTINATION REGISTER
    
    JSR         MODE_CHOOSER
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
*------------END DESTINATION-------------------------------------
    MOVE.B      #00, (A3) 
    BRA         VALID_OPCODE
*-------------------------END MOVE--------------------------------
*------------------------------------------------------------------
*-------------------------MOVEA-----------------------------------
EA_MOVEA        *0 invalid
*------------------------SOURCE----------------------------------------
    CLR.L         D5
    MOVE.W      D0, D7

    MOVE.W      D7, D5      *GETTING SIZE
    LSR.W       #8, D5      *
    LSR.W       #4, D5      *SHIFT 12 BITS RIGHT
    JSR         GET_SIZE    *D4 = SIZE
    ROR.L       #8, D5
    
    MOVE.W      D7, D4      *GETTING SOURCE MODE
    LSL.W       #8, D4      *
    LSL.W       #2, D4      *SHIFT 10 BITS LEFT; 13 RIGHT
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = SOURCE MODE

    MOVE.W      D7, D5      *GETTING SOURCE REGISTER
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
    MOVE.W      D7, D5      *GET THE DESTINATION REGISTER
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *SHIFT 4 BITS LEFT; 13 RIGHT
    LSR.W       #5, D5      *D5 = DESTINATION REGISTER
    
    JSR         ADDR_1
    MOVE.B      #00, (A3)
    BRA         VALID_OPCODE
*------------------END DESTINATION--------------------------------------
*------------------------END MOVEA------------------------------
*----------------------------------------------------------------
*-----------------------MOVEQ---------------------------------------
EA_MOVEQ        *0 invalid
*-----------------------SOURCE-----------------------------------------
    CLR.L       D5
    MOVE.W      D0, D7

    JSR SPACE
    JSR POUND
    JSR CASH
    MOVE.W      D7, D5
    LSL.W       #8, D5
    LSR.W       #8, D5 *PROLLY UNNECESSARY
    MOVE.W      D5, D2
    JSR         MOQ
    
  
*----------------------END SOURCE--------------------------------------
    JSR COMMA
    JSR SPACE
*---------------------DESTINATION------------------------------------
    MOVE.W      D7, D5      *GET THE DESTINATION REGISTER
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *
    LSR.W       #5, D5      * D5 = DESTINATION REGISTER
    
    JSR         DATA_0
    MOVE.B      #00, (A3)
    BRA         VALID_OPCODE
*----------------------END MOVEQ--------------------------------
*---------------------------------------------------------------
*------------------------ADD------------------------------------
EA_ADD          *3 invalid; done

*COVERS ADD, SUB, AND, OR
*--------------------GET MODES-----------------------------
    CLR.L         D5
    MOVE.W      D0, D7

    MOVE.W      D7, D5      *GETTING OPMODE AKA SIZE
    LSL.W       #7, D5      * 
    LSR.W       #7, D5      *
    LSR.W       #6, D5      *D4 = OPMODE AKA SIZE
    JSR         GET_OPMODE_MATH *PRINTS THE SIZE

    CMP.B       #3, D5
    BLT         DN_VERSION
    CMP.B       #3, D5
    BGT         EA_VERSION
*-------------------END GETS MODES------------------------------
*-------------------DN VERSION------------------------
DN_VERSION *EA IS SOURCE, REGISTER IS DESTINATION <EA> + DN -> DN
    ROR.L       #8, D5
    
    MOVE.W      D7, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D7, D5      *SHIFT LEFT 13; RIGHT 13
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
    
    MOVE.W      D7, D5      *LEFT 4; RIGHT 13
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 DESTINATION REGISTER
    
    JSR         DATA_0
    MOVE.B      #00, (A3)
    BRA         VALID_OPCODE
*-------------------END DN VERSION-------------------
*-------------------EA VERSION-------------------------
EA_VERSION
    ROR.L       #8, D5

    MOVE.W      D7, D5      *LEFT 4; RIGHT 13
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 DESTINATION REGISTER
    JSR         DATA_0
    
    JSR         COMMA
    JSR         SPACE
    
    MOVE.W      D7, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D7, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    *the only way there could be an error is if 
    *we are in THIS addressing mo
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG 
    JSR         ADD_ERROR_CHECK
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
    
    MOVE.B      #00, (A3)
    BRA         VALID_OPCODE
*------------------END EA VERSION----------------------
*--------------------END ADD----------------------------
*------------------------------------------------------
*-------------------ADDI--------------------------------
EA_ADDI  *2 invalid; DONE
*-------------------PRINT SIZE-----------------------------------
    CLR.L         D5
    MOVE.W      D0, D7
    
    MOVE.W      D7, D5      *
    LSL.W       #8, D5      *
    LSR.W       #8, D5      *
    LSR.W       #6, D5      *D5 = SIZE
    JSR         GET_SIZE_ADDI
    ROR.L       #8, D5
*-----------------END PRINT SIZE-----------------------------
*----------------PRINT IMMEDIATE----------------------------
    JSR         IMME_7
*-------------END PRINT IMMEDIATE-----------------------------
    JSR         COMMA
    JSR         SPACE
*-----------------PRINT EA------------------------------------
    MOVE.W      D7, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D7, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG  
    JSR         ADDI_ERROR_CHECK
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP'
    
    MOVE.B      #00, (A3)
    BRA         VALID_OPCODE
*-------------------END PRINT EA--------------------------
*-------------------END ADDI------------------------------
*----------------------------------------------------------
*------------------------ADDQ----------------------------------
EA_ADDQ     *0 INVALID
*-----------------------SOURCE------------------------------------
    CLR.L         D5
    MOVE.W      D0, D7
    
    MOVE.W      D7, D5
    LSL.W       #8, D5
    LSR.W       #8, D5
    LSR.W       #6, D5
    JSR         GET_SIZE_ADDI    *PRINT SIZE
    ROR.L       #8, D5
    
    MOVE.W      D7, D5      *GETTING DATA
    LSL.W       #4, D5      *SHIFT LEFT 4; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = DATA
    JSR         GET_DATA
*--------------------END SOURCE-------------------------------------
    JSR COMMA
    JSR SPACE
*-------------------PRINT EA-----------------------------------
    MOVE.W      D7, D4      *GETTING EA MODE
    LSL.W       #8, D4      *
    LSL.W       #2, D4      *SHIFT 10 LEFT; 13 RIGHT
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D7, D5      *GETTING EA REGISTER
    LSL.W       #8, D5      *
    LSL.W       #5, D5      *SHIFT LEFT 13; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = EA REGISTER
    
    JSR         MODE_CHOOSER
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
    
    MOVE.B      #00, (A3)
    
    BRA         VALID_OPCODE
*-------------------END PRINT EA-------------------------------
*----------------------END ADDQ---------------------------------
*--------------------------------------------------------------
*-------------------------ADDA------------------------------------
EA_ADDA         *0 INVALID
*-----------------------SOURCE------------------------------
    CLR.L         D5
    MOVE.W      D0, D7
    
    MOVE.W      D7, D5      *GETTING OPMODE AKA SIZE
    LSL.W       #7, D5      * 
    LSR.W       #7, D5      *
    LSR.W       #6, D5      *D4 = OPMODE AKA SIZE
    JSR         GET_OPMODE
    ROR.L       #8, D5
    
    MOVE.W      D7, D4      *GETTING SOURCE MODE
    LSL.W       #8, D4      *
    LSL.W       #2, D4      *SHIFT 10 BITS LEFT; 13 RIGHT
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = SOURCE MODE
    
    MOVE.W      D7, D5      *GETTING SOURCE REGISTER
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
    MOVE.W      D7, D5      *GET THE DESTINATION REGISTER
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *SHIFT 4 BITS LEFT; 13 RIGHT
    LSR.W       #5, D5      *D5 = DESTINATION REGISTER
    
    JSR         ADDR_1
    MOVE.B      #00, (A3)
    
    BRA         VALID_OPCODE
*-----------------------END DESTINATION---------------------
*-------------------------END ADDA--------------------------------
*---------------------------------------------------------------
*------------------------------MULS--------------------------------
EA_MULS                *1 INVALID;
*COVERS DIVU, MULS     *NEITHER CAN BE ADDR REG
*COMPLICATED BECAUSE: if one is an address and the other is 
*an absolute word or immediate data, you have to eat it. 


*----------------------PRINT EA-------------------------
    CLR.L         D5
    MOVE.W      D0, D7
    
    JSR         SPACE
    MOVE.W      D7, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D7, D5      *SHIFT LEFT 13; RIGHT 13
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
    MOVE.W      D7, D5      *LEFT 4; RIGHT 13
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 DESTINATION REGISTER
    
    JSR         DATA_0
    MOVE.B      #00, (A3)
    
    BRA         VALID_OPCODE
*---------------------------END MULS------------------------------
*----------------------------------------------------------------
*-------------------------LEA-----------------------------------
EA_LEA          *5 INVALIDS; DONE
*-------------------SOURCE-------------------------------------
    CLR.L         D5
    MOVE.W      D0, D7
    
    JSR         SPACE
    MOVE.W      D7, D4      *GETTING SOURCE MODE
    LSL.W       #8, D4      *
    LSL.W       #2, D4      *SHIFT 10 BITS LEFT; 13 RIGHT
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = SOURCE MODE
    
    MOVE.W      D7, D5      *GETTING SOURCE REGISTER
    LSL.W       #8, D5      *
    LSL.W       #5, D5      *SHIFT LEFT 13; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = SOURCE REGISTER
    
    JSR         MODE_CHOOSER  *INCASE MODE IS $111
    JSR         LEA_ERROR_CHECK
    LEA         MODE_JUMP, A0 *LOAD MODE JUMP TABLE
    MULS        #6, D4        *GET JUMP
    JSR         0(A0, D4)     *JUMP
*-------------------END SOURCE---------------------------------
    JSR COMMA
    JSR SPACE
*-------------------DESTINATION-------------------------------
    MOVE.W      D7, D5      *GET THE DESTINATION REGISTER
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *SHIFT 4 BITS LEFT; 13 RIGHT
    LSR.W       #5, D5      *D5 = DESTINATION REGISTER
    
    JSR         ADDR_1
    MOVE.B      #00, (A3)
    
    BRA         VALID_OPCODE
*-----------------END DESTINATION-----------------------------
*------------------------END LEA--------------------------------
*-----------------------------------------------------------------
*------------------------CLR-------------------------------------
EA_CLR          *2 INVALID; DONE
*-------------------PRINT SIZE-----------------------
    CLR.L         D5
    MOVE.W      D0, D7
    
    MOVE.W      D7, D5
    LSL.W       #8, D5      *
    LSR.W       #8, D5      *
    LSR.W       #6, D5      *D4 = SIZE
    JSR         GET_SIZE_ADDI
    ROR.L       #8, D5
*----------------END PRINT SIZE-------------------------
*---------------PRINT EA---------------------------------
    MOVE.W      D7, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D7, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG  
    JSR         ADDI_ERROR_CHECK  
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
    
    MOVE.B      #00, (A3)
    
    BRA         VALID_OPCODE
*---------------END PRINT EA-------------------------
*------------------------END CLR--------------------------------
*----------------------------------------------------------------
*--------------------------SHIFTS------------------------------
EA_LSD          *3 INVALID; DONE
*COVERS LSD, ASD, ROD
*-------------------------SIZE---------------------------
    CLR.L       D5
    MOVE.W      D0, D7
    
    MOVE.W      D7, D5
    LSL.W       #8, D5
    LSR.W       #8, D5
    LSR.W       #6, D5     *ISOLATE SIZE
    JSR         GET_SIZE_ADDI  *PRINT SIZE
    CMP.B       #3, D5      *EA SHIFT
    *DOES A ROTATE COMMAND AFFECT CARRY FLAG
    BEQ         EA_SHIFT    *BRANCH TO EA SHIFT
*-----------------------END SIZE--------------------------
*-----------------------SHIFTING------------------------------
    MOVE.W      D7, D4
    LSL.W       #8, D4
    LSL.W       #2, D4
    LSR.W       #8, D4
    LSR.W       #7, D4      *D4 = TYPE
    
    MOVE.W      D7, D5      *GETTING DATA
    LSL.W       #4, D5      *SHIFT LEFT 4; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = DATA / REGISTER
    
    JSR         TYPE_CHOOSER
*-----------------------END SHIFTING---------------------------
    JSR         COMMA
    JSR         SPACE
*----------------------DESTINATION------------------------------
    MOVE.W      D7, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    JSR         DATA_0
    
    MOVE.B      #00, (A3)
    
    BRA         VALID_OPCODE
*----------------------END DESTINATION-------------------------    
*---------------------------EA SHIFT-------------------------------
EA_SHIFT
    JSR         WORD
    JSR         SPACE
    MOVE.W      D7, D4      *
    LSL.W       #8, D4      *
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D7, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG   
    JSR         ADD_ERROR_CHECK 
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
    BRA         DONE
*-------------------------END EA SHIFT------------------------------
DONE
    MOVE.B      #00, (A3)
    
    BRA         VALID_OPCODE

*----------------------------END SHIFTS---------------------------
*---------------------------------------------------------------
*-------------------------------CMP-----------------------------
EA_CMP          *0 INVALID
*------------------PRINT SIZE----------------------------
    CLR.L         D5
    MOVE.W      D0, D7
    
    MOVE.W      D7, D5      *GETTING OPMODE AKA SIZE
    LSL.W       #7, D5      * 
    LSR.W       #7, D5      *
    LSR.W       #6, D5      *D4 = OPMODE AKA SIZE
    JSR         GET_SIZE_ADDI
    ROR.L       #8, D5
*---------------END PRINT SIZE-------------------------
*------------------PRINT EA---------------------------
    MOVE.W      D7, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D7, D5      *SHIFT LEFT 13; RIGHT 13
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
    MOVE.W      D7, D5      *LEFT 4; RIGHT 13
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 DESTINATION REGISTER
    
    JSR         DATA_0
    MOVE.B      #00, (A3)
    
    BRA         VALID_OPCODE
*--------------END PRINT REG---------------------------
*------------------------------END CMP----------------------------
*-----------------------------------------------------------------
*--------------------------------BCC------------------------------
EA_BCC          *0 INVALID (I THINK)
*--------------------PRINT TYPE------------------------
    CLR.L       D5
    MOVE.W      D0, D7
    
    MOVE.W      D7, D4
    LSL.W       #4, D4
    LSR.W       #8, D4
    LSR.W       #4, D4   *D4 = BINARY CONDITION CODE
    JSR         PRINT_BCC
*-------------------END PRINT TYPE---------------------
    JSR         SPACE
*------------------PRINT ADDRESS OR SOMETHING---------
    MOVE.W      D7, D4
    LSL.W       #8, D4
    LSR.W       #8, D4 *NOW THE DISPLACEMENT IS IN D4 BYTE
    BRA         DISPLACEMENT
    
DISPLACEMENT
    CMP.B       #$00, D4
    BEQ         WORD_BIT
    CMP.B       #$FF, D4
    BEQ         LONG_BIT
    BRA         DISP_DONE
    
WORD_BIT
    JSR         ABSW_5
    BRA         DISP_DONE
LONG_BIT
    JSR         ABSL_6
    BRA         DISP_DONE
    
DISP_DONE
    MOVE.B      #00, (A3)
    BRA         VALID_OPCODE
*-------------END PRINT ADDRESS OR SOMETHING-------------
*-----------------------------END BCC-------------------------------
*-------------------------------------------------------------------
*---------------------------JSR---------------------------------------
EA_JSR   *5 INVALID; DONE
    CLR.L         D5

    MOVE.W      D0, D7
    
    JSR         SPACE
    MOVE.W      D7, D4      *GETTING SOURCE MODE
    LSL.W       #8, D4      *
    LSL.W       #2, D4      *SHIFT 10 BITS LEFT; 13 RIGHT
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = SOURCE MODE
    
    MOVE.W      D7, D5      *GETTING SOURCE REGISTER
    LSL.W       #8, D5      *
    LSL.W       #5, D5      *SHIFT LEFT 13; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = SOURCE REGISTER
    
    JSR         MODE_CHOOSER  *INCASE MODE IS $111
    JSR         LEA_ERROR_CHECK
    LEA         MODE_JUMP, A0 *LOAD MODE JUMP TABLE
    MULS        #6, D4        *GET JUMP
    JSR         0(A0, D4)     *JUM
    
    MOVE.B      #00, (A3)
    
    BRA         VALID_OPCODE
*---------------------------END JSR----------------------------------
*-----------------------------------------------------------------
*-----------------------------MOVEM-------------------------------
EA_MOVEM
        *REG-->MEM
*CASE : MOVEM.W A0/A1/A2/D5/D6/D7,-(SP)  AUTOS D AUT S EAM EAR
*                                        01001 0 001 0 100 111 -> 48A7
*   SP IS A7
* PRE-DEC REVERSES SO A7 A6 A5 A4 A3 A2 A1 A0 D7 D6 D5 D4 D3 D2 D1 D0
*                      0  0  0  0  0  1  1  1  1  1  1  0  0  0  0  0
*                                                              -> 07E0

    CLR.L       D5

    MOVE.W      D0, D7 *D6
*---------------------SIZE--------------------------------
    MOVE.W      D7, D4 *D6
    LSL.W       #5, D4
    LSL.W       #4, D4
    LSR.W       #8, D4
    LSR.W       #7, D4
    JSR         REG_SIZE    
    
*-------------------END SIZE----------------------------
*--------------------TYPE-------------------------------
    MOVE.W      D7, D5
    LSL.W       #5, D5
    LSR.W       #8, D5
    LSR.W       #7, D5
    CMP.B       #0, D5       *D5 NOW CONTAINS TYPE
    BEQ         PRINT_LIST
*-------------------END TYPE---------------------------
*----------------------EA INFO-----------------------
EAP CMP.B       #0, D5      *IF ITS A ZERO, THAT MEANS WE JUST JUMPED HERE 
    BEQ         COMMA_SPACE *FROM CHECK TYPE, ELSE MEANS ITS UNALTERED
EAS ROR.L       #8, D5
    MOVE.W      D7, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D7, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG    
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
    
    ROL.L       #8, D5
    CMP.W       #1, D5 *IF ONE THEN THIS WAS PRINTED FIRST
    BEQ         PRINT_LIST
    
    BRA         DONE_PRINTING
*--------------------END EA INFO--------------------------
*---------------------REGISTER PRINT------------------------
PRINT_LIST
    CMP.B       #1, D5 
    BEQ         COMMA_SPACE2
EA2 ROR.L       #8, D5
    ADD.L       #2, A2
    MOVE.W      (A2), D5  
    MOVE.B      #$8, D2
    CLR         D4
FOR_LOOP    
    CMP.B       D4, D2
    BEQ         ADDRESS_REGISTERS
    ROR.W       #1, D5
    BRA         PRINT_CURRENT
JFZ ADDQ        #1, D4
    BRA         FOR_LOOP
    
PRINT_CURRENT
    BCC         JFZ *D5 = <0000 0001 0000 0000 XXXX XXXX XXXX XXXX>
    ROR.L       #8, D5
    ROR.L       #8, D5 
    MOVE.B      D4, D5 *D5 = <XXXX XXXX XXXX XXXX 0000 0001 0000 000Y>
    JSR         DATA_0
    JSR         SLASH
    ROL.L       #8, D5
    ROL.L       #8, D5
    BRA         JFZ
    
ADDRESS_REGISTERS  *LEFT OFF HERE
    CLR         D4
FOR_2
    CMP.B       D4, D2
    BEQ         CHECK_TYPE
    ROR.W       #1, D5
    BRA         EA_PRINT_ADDRESS
JFF ADDQ        #1, D4
    BRA         FOR_2
    
EA_PRINT_ADDRESS
    BCC         JFF
    ROR.L       #8, D5
    ROR.L       #8, D5
    MOVE.B      D4, D5
    JSR         SLASH
    JSR         ADDR_1
    ROL.L       #8, D5
    ROL.L       #8, D5
    BRA         JFF  
*----------------------END REGISTER PRINT-----------------
CHECK_TYPE
    ROL.L       #8, D5
    CMP.B       #0, D5   *IF TYPE IS 0 THE LIST HAS BEEN PRINTED FIRST  
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
    BRA         VALID_OPCODE


*------------------------------END MOVEM----------------------------














BYEBYE
    SIMHALT















*-------------------ERROR CHECK--------------------------------
MOVE_ERROR_CHECK       *only invalid move is desn addr reg
    CMP.B       #1, D4 *if d4 is one, dest is addr reg
    BEQ         INVALID
    RTS
    
ADD_ERROR_CHECK  *COVERS ALL SHIFTS
    CMP.B       #7, D4
    BEQ         EAT_INVALID
    CMP.B       #1, D4
    BEQ         INVALID
    CMP.B       #0, D4
    BEQ         INVALID
    RTS 
    
ADDI_ERROR_CHECK *COVERS CLR
    CMP.B       #1, D4
    BEQ         INVALID
    CMP.B       #7, D4
    BEQ         EAT_INVALID
    RTS
    
LEA_ERROR_CHECK *COVERS JSR
    CMP.B       #0, D4
    BEQ         INVALID
    CMP.B       #1, D4
    BEQ         INVALID
    CMP.B       #3, D4
    BEQ         INVALID
    CMP.B       #4, D4
    BEQ         INVALID
    CMP.B       #7, D4
    BEQ         EAT_INVALID
    RTS
    
MOVEM_ERROR_CHECK *0, 1, 4, 7
    CMP.B       #0, D4
    BEQ         INVALID
    CMP.B       #1, D4
    BEQ         INVALID
    CMP.B       #4, D4
    BEQ         INVALID
    CMP.B       #7, D4
    BEQ         EAT_INVALID
    RTS
    
    
    
    *assuming FOR NOW that it always eats a long
EAT_INVALID *EATS THE NEXT TWO WORD VALUES... THEN CALLS INVALID
    ADD.L       #2, A2      *EAT THE FIRST WORD
    ADD.L       #2, A2      *EAT THE SECOND WORD
    BRA         INVALID
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
    ADD.L       #2, A2      *INCREMENT INTO WORD ADDRESS
    MOVE.B      (A2)+, D2
    ROL         #8, D2
    MOVE.B      (A2), D2
    SUB         #1, A2  
    JSR         CASH
    BSR         OUTPUT_HEX
    RTS

 
ABSL_6 *
    JSR         CASH
    ADD.L       #2, A2      *INCREMENT INTO WORD
    MOVE.B      (A2)+, D2
    ROL         #8, D2
    MOVE.B      (A2), D2
    SUB         #1, A2      *WHATS WITH THE SUB 1
    BSR         OUTPUT_HEX
    
    
    ADD.L       #2, A2      *IDCREMENT INTO NEXT WORK
    MOVE.B      (A2)+, D2
    ROL         #8, D2
    MOVE.B      (A2), D2
    SUB         #1, A2          *WHY THE SUB 1
    BSR         OUTPUT_HEX
    RTS
    
IMME_7  *FOR NOW ONLY WORKING WITH IMMEDIATE HEX VALUES
    JSR         POUND
    JSR         CASH
    
    ADD.L       #2, A2
    MOVE.B      (A2)+, D2
    ROL         #8, D2
    MOVE.B      (A2), D2
    SUB         #1, A2
    BSR         OUTPUT_HEX
    *if size is a 2, 7, or 6, its a long
    *d4 needs to always hold the size
    JSR         ADD_WORD
    RTS

ADD_WORD
    ROL.L       #8, D5
    CMP.B       #2, D5
    BEQ         ADD_NEW
    CMP.B       #6, D5
    BEQ         ADD_NEW
    CMP.B       #7, D5
    BEQ         ADD_NEW
    RTS
    
ADD_NEW
    ROR.L       #8, D5
    ADD.L       #2, A2
    MOVE.B      (A2)+, D2
    ROL         #8, D2
    MOVE.B      (A2), D2
    SUB         #1, A2
    BSR         OUTPUT_HEX
    RTS
*-------------------------END MODE JUMP----------------------------  
*-------------------------START HELPERS-----------------------------
GET_SIZE
    JSR         DOT
    CMP.B       #1, D5
    BEQ         BYTE
    CMP.B       #3, D5
    BEQ         WORD
    CMP.B       #2, D5
    BEQ         LONG  
    RTS
    
GET_REG ******************
    MOVE.L      D5, D1 
    JSR         CONVERT_TO_ASCII
    MOVE.B      D1, (A3)+
    RTS
    
GET_OPMODE          
    JSR         DOT
    CMP.B       #3, D5
    BEQ         WORD
    CMP.B       #7, D5
    BEQ         LONG
    RTS
    
GET_OPMODE_MATH
    JSR         DOT
    CMP.B       #0, D5
    BEQ         BYTE
    CMP.B       #4, D5
    BEQ         BYTE
    CMP.B       #1, D5
    BEQ         WORD
    CMP.B       #5, D5
    BEQ         WORD
    CMP.B       #2, D5
    BEQ         LONG
    CMP.B       #6, D5
    BEQ         LONG
    RTS
    
GET_DATA ******************
    JSR         POUND
    CMP.B       #0, D5
    BEQ         PRINT_8
    MOVE.W      D5, D2
    JSR         QHX
    RTS
    
PRINT_8 ********
    MOVE.W      #8, D2
    JSR         QHX
    RTS
    
GET_SIZE_ADDI
    JSR         DOT
    CMP.B       #0, D5
    BEQ         BYTE
    CMP.B       #1, D5
    BEQ         WORD
    CMP.B       #2, D5
    BEQ         LONG  
    RTS
    
TYPE_CHOOSER
    CMP.B       #0, D4      *IF IMMEDIATE
    BEQ         GET_DATA    *IF BRANCHED  ->  #1 IS NOW PRINTED
    CMP.B       #1, D4      *IF A DATA REG
    BEQ         DATA_0
    RTS
    
PRINT_BCC
    CMP.B       #0, D4
    BEQ         RA
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
    CMP.B       #4, D5 *for immediate data
    BEQ         TO_EIGHT
    RTS
    
TO_EIGHT
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
    MOVE.W      D2, D4              *D7 = <1010 1111 0101 0111>
    LSR.W       #8, D4              *D7 = <0000 0000 1010 1111>
    LSR.W       #4, D4              *D7 = <0000 0000 0000 1010>
    MOVE.B      D4, D1
    BSR         CONVERT_TO_ASCII    *convert value in D1, to ascii
    BSR         ADD_CHAR         *print the char in D1  
    *OUTPUT 2ND
    MOVE.W      D2, D4
    LSL.W       #4, D4              *SHIFT OUT FURTHEST RIGHT BIT
    LSR.W       #8, D4
    LSR.W       #4, D4  
    MOVE.B      D4, D1
    BSR         CONVERT_TO_ASCII
    BSR         ADD_CHAR
    *OUTPUT 3RD
MOQ MOVE.W      D2, D4
    LSL.W       #8, D4
    LSR.W       #8, D4
    LSR.W       #4, D4
    MOVE.B      D4, D1
    BSR         CONVERT_TO_ASCII
    BSR         ADD_CHAR
    *OUTPUT 4TH
QHX MOVE.W      D2, D4  *D7 = <1010 1111 0101 0111>
    LSL.W       #8, D4  *     <0101 0111 0000 0000>
    LSL.W       #4, D4  *     <0111 0000 0000 0000>
    LSR.W       #8, D4  *     <
    LSR.W       #4, D4
    MOVE.B      D4, D1
    BSR         CONVERT_TO_ASCII
    BSR         ADD_CHAR
    RTS
                                   *continue converting            
ADD_CHAR ********
    MOVE.B      D1, (A3)+
    RTS

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
    MOVE.B      M_C, (A3)+
    MOVE.B      M_C, (A3)+
    RTS
    
GT
    MOVE.B      M_G, (A3)+
    MOVE.B      M_T, (A3)+
    RTS

LE
    MOVE.B      M_L, (A3)+
    MOVE.B      M_E, (A3)+
    RTS
    
RA
    MOVE.B      M_R, (A3)+
    MOVE.B      M_A, (A3)+
    RTS
    
SLASH
    MOVE.B      M_SLASH, (A3)+
    RTS
    
INVALID
    MOVE.B      #00, (A3)
    BRA         INVALID_OPCODE
    
*----------------------------END CHARACTERS---------------------------        

CR      EQU     $0D
LF      EQU     $0A






















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
