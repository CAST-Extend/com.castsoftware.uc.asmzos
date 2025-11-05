BEGIN_PROGRAM(PGM)
 MAIN:
PGM      CSECT
         STM    14,12,12(13)
         LR     12,15
@PSTART  EQU    BALAPI
         USING  @PSTART,12
         ST     13,SAVE+4
         LA     14,SAVE
         ST     14,8(13)
         LR     13,14


          MVC   EMPNO,=CL6'000010'
          EXEC SQL                                                     X
             SELECT LASTNAME                                           X
               INTO :ENAME                                             X
               FROM   EMP                                              X
              WHERE  EMPNO = :EMPNO


*--- Vérifier SQLCODE dans SQLCA (fullword)
*    L     r,SQLCODE   ; BZ OK_PATH  ; etc.

*--- Commit & fin
         EXEC SQL WHENEVER SQLERROR  GO TO SQLERMOD                     00090000
         EXEC SQL WHENEVER NOT FOUND GO TO SQLERMOD                     00091000
         EXEC SQL WHENEVER SQLWARNING GO TO SQLERMOD                    00092000

OK_PATH   DS    0H
          LM    14,12,12(13)
          BR    14
          END   PGM


END_PROGRAM
