BEGIN_PROGRAM(PGM)
 MAIN:
BALAPI   CSECT
         STM    14,12,12(13)
         LR     12,15
@PSTART  EQU    BALAPI
         USING  @PSTART,12
         ST     13,SAVE+4
         LA     14,SAVE
         ST     14,8(13)
         LR     13,14

LAB      MYMACRO R3,42             * Appel de la macro

END_PROGRAM
