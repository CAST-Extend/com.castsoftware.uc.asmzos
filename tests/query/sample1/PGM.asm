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
          EXEC SQL
             SELECT LASTNAME
               INTO :ENAME
               FROM   EMP
              WHERE  EMPNO = :EMPNO
          END-EXEC

*--- Vérifier SQLCODE dans SQLCA (fullword)
*    L     r,SQLCODE   ; BZ OK_PATH  ; etc.

*--- Commit & fin
          EXEC SQL COMMIT END-EXEC

OK_PATH   DS    0H
          LM    14,12,12(13)
          BR    14
          END   PGM


END_PROGRAM
