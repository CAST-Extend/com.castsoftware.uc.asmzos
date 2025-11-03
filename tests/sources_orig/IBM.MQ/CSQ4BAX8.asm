         TITLE 'MQSeries Data Conversion User Exit'                     00400000
         LCLC  &X8_NAME                                                 00800000
**********************************************************************  01200000
*                                                                    *  01600000
*    Product Number        : 5695-137                                *  02000000
*                                                                    *  02400000
*    Module Name           : CSQ4BAX8                                *  02800000
*                                                                    *  03200000
*    Environment           : Data conversion exit                    *  03600000
*                                                                    *  04000000
*                                                                    *  04400000
*    Description : Sample program to illustrate parameter access     *  04800000
*                  and the MQXCNVC call in a data conversion exit.   *  05200000
*                                                                    *  05600000
*    Function    : This program is a data conversion user exit.      *  06000000
*                  It illustrates how to access the parameters, and  *  06400000
*                  how to use the MQXCNVC call, if you are writing   *  06800000
*                  your own exit.                                    *  07200000
*                                                                    *  07600000
*                  (If you are using the utility CSQUCVX to help you *  08000000
*                  write the exit, see the sample CSQ4BAX9 instead.) *  08400000
*                                                                    *  08800000
*    Parameters  : For parameter details, see                        *  09200000
*                  "MQSeries Application Programming Reference".     *  09600000
*                                                                    *  10000000
*    Usage       : For simplicity, the data to be converted is       *  10500000
*                  assumed to be a single character string,          *  11000000
*                  although a message format that required a user    *  11500000
*                  exit would normally comprise several data items   *  12000000
*                  of differing types.                               *  12500000
*                                                                    *  13000000
*                  Replace CSQ4BAX8 in the following by the          *  13500000
*                  name of the format to be converted:               *  14000000
&X8_NAME SETC  'CSQ4BAX8'                                               14500000
*                                                                    *  15000000
*    Link-editing: Use the MQSeries libraries, and include CSQASTUB. *  15500000
*                  Give the module the name of the format.           *  16000000
*                                                                    *  16500000
*    Registers   : See comments on register equates.                 *  17000000
*                                                                    *  17500000
**********************************************************************  18000000
*    @START_COPYRIGHT@                                               *  18500000
*   Statement:     Licensed Materials - Property of IBM              *  19000000
*                                                                    *  19500000
*                  5695-137                                          *  20000000
*                  (C) Copyright IBM Corporation. 1993, 1997         *  20500000
*                                                                    *  21000000
*   Status:        Version 1 Release 2                               *  21500000
*    @END_COPYRIGHT@                                                 *  22000000
*                                                                    *  22500000
**********************************************************************  23000000
*                                                                       23500000
&X8_NAME CSECT ,                                                        24000000
&X8_NAME AMODE 31                                                       24500000
&X8_NAME RMODE ANY                                                      25000000
*                                                                       25500000
R0       EQU   0                                                        26000000
R1       EQU   1                                                        26500000
R2       EQU   2                       MQDXP address                    27000000
R3       EQU   3                       MQMD  address                    27500000
R4       EQU   4                                                        28000000
R5       EQU   5                                                        28500000
R6       EQU   6                                                        29000000
R7       EQU   7                                                        29500000
R8       EQU   8                       Parameter list address           30000000
R9       EQU   9                       Internal subroutine linkage      30500000
R10      EQU   10                                                       31000000
R11      EQU   11                                                       31500000
R12      EQU   12                      Base register                    32000000
R13      EQU   13                      Save and work area address       32500000
R14      EQU   14                                                       33000000
R15      EQU   15                                                       33500000
*                                                                       34000000
*********************************************************************** 34500000
*        MQ API CONSTANTS AND DSECTS                                  * 35000000
*********************************************************************** 35500000
*                                                                       36000000
         CMQA    LIST=NO                                                36500000
         CMQXA   LIST=NO                                                37000000
MQDXP    CMQDXPA DSECT=YES,LIST=YES    DSECT for MQDXP structure        37500000
MQMD     CMQMDA  DSECT=YES,LIST=YES    DSECT for MQMD structure         38000000
*                                                                       38500000
*********************************************************************** 39000000
*        SAVE AND WORK AREA DSECT                                     * 39500000
*********************************************************************** 40000000
*                                                                       40500000
X8_DATA  DSECT ,                                                        41000000
X8_SAVE  DS 18F                        Save area                        41500000
*                                                                       42000000
*                                                                       42500000
PARMLIST CALL  ,(0,0,0,0,0,0,0,0,0,0,0),VL,MF=L                         43000000
COMPCODE DS    F                       Completion code                  43500000
REASON   DS    F                       Reason code                      44000000
OUTLEN   DS    F                       Output data length               45500000
*                                                                       46000000
X8_DLEN  EQU   *-X8_DATA                                                46500000
*                                                                       47000000
*********************************************************************** 47500000
*        START OF PROGRAM                                             * 48000000
*********************************************************************** 48500000
*                                                                       49000000
&X8_NAME CSECT ,                                                        49500000
         STM   R14,R12,12(R13)              Save registers              50000000
         LR    R12,R15                      Set base register           50500000
         USING &X8_NAME,R12                 Set addressability          51000000
         LR    R8,R1                        Save parmlist address       51500000
*                                           Get storage for work area   52000000
       GETMAIN RU,LV=X8_DLEN,LOC=(RES,ANY)                              52500000
         ST    R13,4(,R1)                   Chain save areas            53000000
         ST    R1,8(,R13)                                               53500000
         LR    R13,R1                       Set save area address       54000000
         USING X8_DATA,R13                  Set addressability          54500000
*                                                                       55000000
         LM    R2,R7,0(R8)                  Get parameter addresses     55500000
         USING MQDXP,R2                     MQDXP address               56000000
         USING MQMD,R3                      MQMD address                56500000
*              R4                           Source data length address  57000000
*              R5                           Source buffer address       57500000
*              R6                           Target data length address  58000000
*              R7                           Target buffer address       58500000
*                                                                       59000000
*                                                                       59500000
*********************************************************************** 60000000
*        MAIN PROCESSING                                              * 60500000
*********************************************************************** 61000000
*                                                                       61500000
         SR    R0,R0                        Clear output parameters     62000000
         ST    R0,COMPCODE                                              62500000
         ST    R0,REASON                                                63000000
         ST    R0,OUTLEN                                                63500000
*                                                                       64000000
*           Call MQXCNVC to convert the character string.               64500000
*           Note that it requires the buffers themselves to be passed   65000000
*           as arguments, and NOT the addresses of the buffers.         65500000
*                                                                       66000000
         CALL  MQXCNVC,                                                +66500000
               (MQDXP_HCONN,                Hconn                      +67000000
               MQDXP_APPOPTIONS,            Options                    +67500000
               MQMD_CODEDCHARSETID,         SourceCCSID                +68000000
               0(,R4),                      SourceLength               +68500000
               (R5),                        SourceBuffer               +69000000
               MQDXP_CODEDCHARSETID,        TargetCCSID                +69500000
               0(,R6),                      TargetLength               +70000000
               (R7),                        TargetBuffer               +70500000
               OUTLEN,                      DataLength                 +71000000
               COMPCODE,                    CompCode                   +71500000
               REASON),VL,                  Reason                     +72000000
               MF=(E,PARMLIST)                                          72500000
*                                                                       73000000
*********************************************************************** 73500000
*        CHECK RESULTS OF CONVERSION                                  * 74000000
*********************************************************************** 74500000
*                                                                       75000000
         L     R15,COMPCODE                 Get conversion return code  75500000
         C     R15,=A(MQCC_OK)              Check result                76000000
         BE    X8_OK                                                    76500000
*                                                                       77000000
X8_ERROR DS    0H                      CONVERSION FAILED:               77500000
         L     R0,REASON                                                78000000
         L     R0,=A(MQXDR_CONVERSION_FAILED)                           78500000
         ST    R0,MQDXP_EXITRESPONSE        - Show conversion failure   79000000
         L     R0,=A(MQCC_WARNING)          - Show MQGET failure        79500000
         ST    R0,MQDXP_COMPCODE                                        80000000
         L     R0,REASON                                                80500000
         ST    R0,MQDXP_REASON                                          81000000
         B     X8_EXIT                                                  81500000
*                                                                       82000000
X8_OK    DS    0H                      CONVERSION SUCCEEDED:            82500000
         L     R0,=A(MQXDR_OK)              - Show conversion success   83000000
         ST    R0,MQDXP_EXITRESPONSE                                    83500000
         L     R0,OUTLEN                                                84000000
         ST    R0,MQDXP_DATALENGTH                                      84500000
         L     R0,MQDXP_REASON              Get original reason code    85000000
         C     R0,=A(MQRC_TRUNCATED_MSG_ACCEPTED)                       85500000
         BE    X8_EXIT                      Was message truncated?      86000000
*                                           Yes - leave MQGET codes     86500000
         ST    R15,MQDXP_COMPCODE           No - show MQGET success     87000000
         L     R0,=A(MQRC_NONE)                                         87500000
         ST    R0,MQDXP_REASON                                          88000000
         L     R15,MQDXP_CODEDCHARSETID     - Set new values            88100000
         ST    R15,MQMD_CODEDCHARSETID                                  88200000
         L     R15,MQDXP_ENCODING                                       88300000
         ST    R15,MQMD_ENCODING                                        88400000
*                                                                       88500000
*********************************************************************** 89000000
*        END OF PROGRAM                                               * 89500000
*********************************************************************** 90000000
*                                                                       90500000
X8_EXIT  DS    0H                                                       91000000
         L     R13,4(,R13)                  Restore callers save area   91500000
         L     R1,8(,R13)                                               92000000
      FREEMAIN RU,LV=X8_DLEN,A=(1)          Free save area              92500000
         LM    R14,R12,12(R13)              Restore registers           93000000
         SR    R15,R15                      Return with RC=0            93500000
         BR    R14                                                      94000000
*                                                                       94500000
*********************************************************************** 95000000
*        CONSTANTS                                                    * 95500000
*********************************************************************** 96000000
*                                                                       96500000
         LTORG ,                                                        97000000
*                                                                       97500000
*********************************************************************** 98000000
*        End Of Module                                                * 98500000
*********************************************************************** 99000000
         END   &X8_NAME                                                 99500000
