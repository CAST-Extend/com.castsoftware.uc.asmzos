CSQ4BAX0 TITLE 'MQSeries SAMPLE DQM USER EXIT PROGRAM - ASSEMBLER'      00200000
**********************************************************************  00400000
*                                                                    *  00600000
*    Product Number        : 5695-137                                *  00800000
*                                                                    *  01000000
*    Module Name           : CSQ4BAX0                                *  01200000
*                                                                    *  01400000
*    Environment           : Distributed queueing without CICS       *  01600000
*                            user exit;  assembler                   *  01800000
*                                                                    *  02000000
*    Description : Sample program to illustrate parameter access     *  02200000
*                  and the MQXWAIT call in a user exit               *  02400000
*                  for distributed queueing without CICS.            *  02600000
*                                                                    *  02800000
*    Function    : This program is a distributed queueing message    *  03000000
*                  user exit.  It illustrates how to access the      *  03200000
*                  parameters by simply displaying the values of     *  03400000
*                  some of them, and it illustrates how to use the   *  03600000
*                  MQXWAIT call to wait for an event.                *  03800000
*                                                                    *  04000000
*    Parameters  : For parameter details, see the                    *  04200000
*                  "MQSeries Distributed Queue Management Guide".    *  04400000
*                                                                    *  04600000
*    Link-editing: Use the MQSeries libraries, and include CSQXSTUB. *  04800000
*                                                                    *  05000000
*    Notes       : Parameter access is exactly the same for the      *  05200000
*                  security, send, and receive user exits.           *  05400000
*                                                                    *  05600000
*                  For simplicity, WTO is used to display parameter  *  05800000
*                  values, and WTOR is used to provide an event to   *  06000000
*                  wait for.  User exits should not normally use     *  06100000
*                  WTOs.                                             *  06200000
*                                                                    *  06400000
*                  Although various error conditions are checked, no *  06600000
*                  action is taken to stop processing when an error  *  06800000
*                  is found.                                         *  07000000
*                                                                    *  07200000
*    Registers   : See comments on register equates.                 *  07400000
*                                                                    *  07600000
**********************************************************************  07800000
*    @START_COPYRIGHT@                                               *  08000000
*   Statement:     Licensed Materials - Property of IBM              *  08200000
*                                                                    *  08400000
*                  5695-137                                          *  08500000
*                  (C) Copyright IBM Corporation. 1993, 1997         *  08600000
*                                                                    *  08800000
*   Status:        Version 1 Release 2                               *  09000000
*    @END_COPYRIGHT@                                                 *  09400000
*                                                                    *  09600000
**********************************************************************  09800000
*                                                                       10000000
CSQ4BAX0 CSECT ,                                                        10200000
CSQ4BAX0 AMODE 31                                                       10400000
CSQ4BAX0 RMODE ANY                                                      10600000
*                                                                       10800000
R0       EQU   0                       WORK                             11000000
R1       EQU   1                                                        11200000
R2       EQU   2                                                        11400000
R3       EQU   3                       MQCXP ADDRESS                    11600000
R4       EQU   4                       MQCD ADDRESS                     11800000
R5       EQU   5                                                        12000000
R6       EQU   6                       SUBROUTINE LEVEL 1 RETURN        12200000
R7       EQU   7                       SUBROUTINE LEVEL 2 RETURN        12400000
R8       EQU   8                       PARAMETER LIST ADDRESS           12600000
R9       EQU   9                                                        12800000
R10      EQU   10                                                       13000000
R11      EQU   11                                                       13200000
R12      EQU   12                      BASE REGISTER                    13400000
R13      EQU   13                      SAVE AND WORK AREA               13600000
R14      EQU   14                                                       13800000
R15      EQU   15                                                       14000000
*                                                                       14200000
*********************************************************************** 14400000
*        MQ API CONSTANTS AND DSECTS                                  * 14600000
*********************************************************************** 14800000
*                                                                       15000000
         CMQA    LIST=NO                                                15200000
         CMQXA   LIST=NO                                                15400000
MQCXP    CMQCXPA DSECT=YES,LIST=YES    DSECT FOR MQCXP STRUCTURE        15600000
MQCD     CMQCDA  DSECT=YES,LIST=YES    DSECT FOR MQCD STRUCTURE         15800000
*                                                                       16000000
*********************************************************************** 16200000
*        SAVE AND WORK AREA DSECT                                     * 16400000
*********************************************************************** 16600000
*                                                                       16800000
WORKAREA DSECT ,                                                        17000000
SAVEAREA DS    18F                     SAVE AREA                        17200000
*                                                                       17400000
PARMLIST CALL  ,(0,0,0,0,0,0,0,0,0,0,0),VL,MF=L                         17600000
QMGRNAME DS    CL48                    QUEUE MANAGER NAME               17800000
COMPCODE DS    F                       COMPLETION CODE                  18000000
REASON   DS    F                       REASON CODE                      18200000
HCONN    DS    F                       CONNECTION HANDLE                18400000
*                                                                       18600000
REPLY    DS    CL4                     WTOR REPLY AREA                  18800000
XMQXWD   CMQXWDA DSECT=NO,LIST=YES     MQXWD AREA                       19000000
*                                                                       19200000
WORKDWRD DS    D                       WORK AREA FOR NUMBER CONVERSION  19400000
*                                                                       19600000
WTOLIST  DS    0F                      WTO PARMLIST                     19800000
WTOLEN   DS    H                       - TEXT LENGTH                    20000000
WTOFLAG  DS    H                       - FLAGS                          20200000
WTOTEXT  DS    0CL68                   - TEXT                           20400000
WTOTEXT1 DS    CL20                                                     20600000
WTOTEXT2 DS    0CL48                                                    20800000
WTOTEXTC DS    CL8                                                      21000000
WTOTEXT3 DS    CL8                                                      21200000
WTOTEXTR DS    CL8                                                      21400000
         DS    CL24                                                     21600000
*                                                                       21800000
         DS    0F                      WTOR PARMLIST                    22000000
WTORLIST DS    CL(WTORLEN)                                              22200000
*                                                                       22400000
WORKLEN  EQU   *-WORKAREA                                               22600000
*                                                                       22800000
*********************************************************************** 23000000
*        START OF PROGRAM                                             * 23200000
*********************************************************************** 23400000
*                                                                       23600000
CSQ4BAX0 CSECT ,                                                        23800000
         STM   R14,R12,12(R13)              SAVE REGISTERS              24000000
         LR    R12,R15                      SET BASE REGISTER           24200000
         USING CSQ4BAX0,R12                 SET ADDRESSABILITY          24400000
         LR    R8,R1                        SAVE PARMLIST ADDRESS       24600000
*                                           GET STORAGE FOR WORK AREA   24800000
         GETMAIN RU,LV=WORKLEN,LOC=(RES,ANY)                            25000000
         ST    R13,4(,R1)                   CHAIN SAVE AREAS            25200000
         ST    R1,8(,R13)                                               25400000
         LR    R13,R1                       SET SAVE AREA ADDRESS       25600000
         USING WORKAREA,R13                 SET ADDRESSABILITY          25800000
*                                                                       26000000
         WTO   MF=(E,MSGSTART)              DISPLAY START MESSAGE       26200000
*                                                                       26400000
*********************************************************************** 26600000
*        MAIN PROCESSING                                              * 26800000
*********************************************************************** 27000000
*                                                                       27200000
         LA    R0,L'WTOTEXT                 SET WTO TEXT LENGTH         27400000
         STH   R0,WTOLEN                                                27600000
         XC    WTOFLAG,WTOFLAG              CLEAR WTO FLAGS             27800000
*                                                                       28000000
         BAL   R6,CXPCHECK                  CHECK AND DISPLAY MQCXP     28200000
         BAL   R6,CDCHECK                   CHECK AND DISPLAY MQCD      28400000
*                                                                       28600000
         BAL   R6,CONNECT                   CONNECT TO QUEUE MANAGER    28800000
         BAL   R6,WTORWAIT                  WRITE WTOR AND WAIT         29000000
         BAL   R6,DISCONN                   DISCONNECT QUEUE MANAGER    29200000
*                                                                       29400000
*********************************************************************** 29600000
*        END OF PROGRAM                                               * 29800000
*********************************************************************** 30000000
*                                                                       30200000
         L     R3,0(,R8)                    GET MQCXP ADDRESS           30400000
         USING MQCXP,R3                                                 30600000
         L     R0,=A(MQXCC_OK)              SET RESPONSE CODES          30800000
         ST    R0,MQCXP_EXITRESPONSE                                    31000000
         LA    R0,0                                                     31200000
         ST    R0,MQCXP_EXITRESPONSE2                                   31400000
         ST    R0,MQCXP_FEEDBACK                                        31600000
*                                                                       31800000
         WTO   MF=(E,MSGENDED)              DISPLAY END MESSAGE         32000000
*                                                                       32200000
         L     R13,4(,R13)                  RESTORE CALLERS SAVE AREA   32400000
         L     R1,8(,R13)                                               32600000
         FREEMAIN RU,LV=WORKLEN,A=(1)       FREE SAVE AREA              32800000
         LM    R14,R12,12(R13)              RESTORE REGISTERS           33100000
         SR    R15,R15                      RETURN WITH RC=0            33400000
         BR    R14                                                      33700000
*                                                                       34000000
*********************************************************************** 34300000
*        CHECK AND DISPLAY MQCXP                                      * 34600000
*********************************************************************** 34900000
*                                                                       35200000
CXPCHECK DS    0H                                                       35500000
         L     R3,0(,R8)                    GET MQCXP ADDRESS           35800000
         USING MQCXP,R3                                                 36100000
*                                                                       36400000
         CLC   MQCXP_STRUCID,=AL(L'MQCXP_STRUCID)(MQCXP_STRUC_ID)       36700000
         BE    CXP_STR                                                  37000000
         WTO   MF=(E,MSGXSTRE)              DISPLAY ERROR MESSAGE       37300000
CXP_STR  DS    0H                                                       37600000
*                                                                       37900000
         L     R0,MQCXP_VERSION             CHECK VERSION               38200000
         C     R0,=A(MQCXP_CURRENT_VERSION)                             38500000
         BE    CXP_VER                                                  38800000
         WTO   MF=(E,MSGXVERE)              DISPLAY ERROR MESSAGE       39100000
CXP_VER  DS    0H                                                       39400000
*                                                                       39700000
         L     R0,MQCXP_EXITID              CHECK EXITID                40000000
         C     R0,=A(MQXT_CHANNEL_MSG_EXIT)                             40300000
         BNE   CXP_XID1                                                 40600000
         WTO   MF=(E,MSGXXIDM)              DISPLAY EXITID MESSAGE      40900000
         B     CXP_XID2                                                 41200000
CXP_XID1 DS    0H                                                       41500000
         WTO   MF=(E,MSGXXIDE)              DISPLAY ERROR MESSAGE       41800000
CXP_XID2 DS    0H                                                       42100000
*                                                                       42400000
         L     R0,MQCXP_EXITREASON          CHECK EXIT REASON           42700000
         C     R0,=A(MQXR_INIT)                                         43000000
         BNE   CXP_REA1                                                 43300000
         WTO   MF=(E,MSGXREAI)              DISPLAY INITIALIZE MESSAGE  43600000
         B     CXP_REA9                                                 43900000
CXP_REA1 DS    0H                                                       44200000
         C     R0,=A(MQXR_TERM)                                         44500000
         BNE   CXP_REA2                                                 44800000
         WTO   MF=(E,MSGXREAT)              DISPLAY TERMINATION MESSAGE 45100000
         B     CXP_REA9                                                 45400000
CXP_REA2 DS    0H                                                       45700000
         C     R0,=A(MQXR_MSG)                                          46000000
         BNE   CXP_REA3                                                 46300000
         WTO   MF=(E,MSGXREAP)              DISPLAY PROCESS MESSAGE     46600000
         B     CXP_REA9                                                 46900000
CXP_REA3 DS    0H                                                       47200000
         WTO   MF=(E,MSGXREAE)              DISPLAY ERROR MESSAGE       47500000
CXP_REA9 DS    0H                                                       47800000
*                                                                       48100000
         CLC   MQCXP_EXITUSERAREA,=XL(L'MQCXP_EXITUSERAREA)'00'         48400000
         BE    CXP_USA                      CHECK USER AREA             48700000
         WTO   MF=(E,MSGXUSAE)              DISPLAY ERROR MESSAGE       49000000
CXP_USA  DS    0H                                                       49300000
*                                                                       49600000
         CLC   MQCXP_EXITDATA,=CL(L'MQCXP_EXITDATA)' '                  49900000
         BE    CXP_DAT                      CHECK EXIT DATA             50200000
         WTO   MF=(E,MSGXDATE)              DISPLAY ERROR MESSAGE       50500000
CXP_DAT  DS    0H                                                       50800000
*                                                                       51100000
         BR    R6                           RETURN                      51400000
*                                                                       51700000
*********************************************************************** 52000000
*        CHECK AND DISPLAY MQCD                                       * 52300000
*********************************************************************** 52600000
*                                                                       52900000
CDCHECK  DS    0H                                                       53200000
         L     R4,4(,R8)                    GET MQCD ADDRESS            53500000
         USING MQCD,R4                                                  53800000
*                                                                       54100000
         L     R0,MQCD_VERSION              CHECK VERSION               54400000
         C     R0,=A(MQCD_CURRENT_VERSION)                              54700000
         BE    CD_VER                                                   55000000
         WTO   MF=(E,MSGCVERE)              DISPLAY ERROR MESSAGE       55300000
CD_VER   DS    0H                                                       55600000
*                                                                       55900000
         MVC   WTOTEXT,WTOBLANK                                         56200000
         MVC   WTOTEXT1,MSGCCHAN            DISPLAY CHANNEL NAME        56500000
         MVC   WTOTEXT2(L'MQCD_CHANNELNAME),MQCD_CHANNELNAME            56800000
         WTO   MF=(E,WTOLIST)                                           57100000
*                                                                       57400000
         MVC   WTOTEXT,WTOBLANK                                         57700000
         MVC   WTOTEXT1,MSGCXMIT            DISPLAY XMITQ NAME          58000000
         MVC   WTOTEXT2,MQCD_XMITQNAME                                  58300000
         WTO   MF=(E,WTOLIST)                                           58600000
*                                                                       58900000
         MVC   WTOTEXT,WTOBLANK                                         59200000
         MVC   WTOTEXT1,MSGCSCON            DISPLAY SHORT CONN NAME     59500000
      MVC WTOTEXT2(L'MQCD_SHORTCONNECTIONNAME),MQCD_SHORTCONNECTIONNAME 59800000
         WTO   MF=(E,WTOLIST)                                           60100000
*                                                                       60400000
         BR    R6                           RETURN                      60700000
*                                                                       61000000
*********************************************************************** 61300000
*        CONNECT TO QUEUE MANAGER                                     * 61600000
*********************************************************************** 61900000
*                                                                       62200000
CONNECT  DS    0H                                                       62500000
         MVC   WTOTEXT,WTOBLANK             PREPARE TO                  62800000
         MVC   WTOTEXT1,MSGMQCON            DISPLAY MQCONN RESULTS      63100000
         MVC   WTOTEXT3,MSGMQRC                                         63400000
*                                                                       63700000
         XC    COMPCODE,COMPCODE            CLEAR MQCONN PARAMETERS     64000000
         XC    REASON,REASON                                            64300000
         MVI   QMGRNAME,C' '                                            64600000
         MVC   QMGRNAME+1(L'QMGRNAME-1),QMGRNAME                        64900000
         XC    HCONN,HCONN                                              65200000
*                                                                       65500000
         CALL  MQCONN,(QMGRNAME,HCONN,COMPCODE,REASON),VL,             +65800000
               MF=(E,PARMLIST)              CONNECT TO QUEUE MANAGER    66100000
         BAL   R7,TESTRC                    CHECK COMPLETION CODE       66400000
*                                                                       66700000
         BR    R6                           RETURN                      67000000
*                                                                       67300000
*********************************************************************** 67600000
*        DISCONNECT QUEUE MANAGER                                     * 67900000
*********************************************************************** 68200000
*                                                                       68500000
DISCONN  DS    0H                                                       68800000
         MVC   WTOTEXT,WTOBLANK             PREPARE TO                  69100000
         MVC   WTOTEXT1,MSGMQDIS            DISPLAY MQDISC RESULTS      69400000
         MVC   WTOTEXT3,MSGMQRC                                         69700000
*                                                                       70000000
         XC    COMPCODE,COMPCODE            CLEAR MQDISC PARAMETERS     70300000
         XC    REASON,REASON                                            70600000
*                                                                       70900000
         CALL  MQDISC,(HCONN,COMPCODE,REASON),VL,                      +71200000
               MF=(E,PARMLIST)              DISCONNECT QUEUE MANAGER    71500000
         BAL   R7,TESTRC                    CHECK COMPLETION CODE       71800000
*                                                                       72100000
         BR    R6                           RETURN                      72400000
*                                                                       72700000
*********************************************************************** 73000000
*        WRITE WTOR AND WAIT FOR REPLY                                * 73300000
*********************************************************************** 73600000
*                                                                       73900000
WTORWAIT DS    0H                                                       74200000
         MVC   WTOTEXT,WTOBLANK             PREPARE TO                  74500000
         MVC   WTOTEXT1,MSGMQXWA            DISPLAY MQXWAIT RESULTS     74800000
         MVC   WTOTEXT3,MSGMQRC                                         75100000
*                                                                       75400000
         XC    XMQXWD_ECB,XMQXWD_ECB        CLEAR ECB                   75700000
         MVC   REPLY,=CL(L'REPLY)' '        CLEAR REPLY AREA            76000000
         MVC   WTORLIST,MSGWTOR             ISSUE WTOR                  76300000
         WTOR  ,REPLY,L'REPLY,XMQXWD_ECB,MF=(E,WTORLIST)                76600000
*                                                                       76900000
         XC    COMPCODE,COMPCODE            SET MQXWAIT PARAMETERS      77200000
         XC    REASON,REASON                                            77500000
         MVC   XMQXWD_STRUCID,=AL(L'XMQXWD_STRUCID)(MQXWD_STRUC_ID)     77800000
         L     R0,=A(MQXWD_VERSION_1)                                   78100000
         ST    R0,XMQXWD_VERSION                                        78400000
         XC    XMQXWD_RESERVED1,XMQXWD_RESERVED1                        78700000
         XC    XMQXWD_RESERVED2,XMQXWD_RESERVED2                        79000000
         XC    XMQXWD_RESERVED3,XMQXWD_RESERVED3                        79300000
*                                                                       79600000
         CALL  MQXWAIT,(HCONN,XMQXWD,COMPCODE,REASON),VL,              +79900000
               MF=(E,PARMLIST)              WAIT FOR REPLY              80200000
         BAL   R7,TESTRC                    CHECK COMPLETION CODE       80500000
*                                                                       80800000
         BR    R6                           RETURN                      81100000
*                                                                       81400000
*********************************************************************** 81700000
*        CHECK COMPLETION CODE                                        * 82000000
*********************************************************************** 82300000
*                                                                       82600000
TESTRC   DS    0H                                                       82900000
         L     R0,COMPCODE                  DISPLAY COMPCODE            83200000
         CVD   R0,WORKDWRD                                              83500000
         UNPK  WTOTEXTC,WORKDWRD+4(4)                                   83800000
         OI    WTOTEXTC+7,X'F0'                                         84100000
*                                                                       84400000
         L     R0,REASON                    DISPLAY REASON              84700000
         CVD   R0,WORKDWRD                                              85000000
         UNPK  WTOTEXTR,WORKDWRD+4(4)                                   85300000
         OI    WTOTEXTR+7,X'F0'                                         85600000
*                                                                       85900000
         WTO   MF=(E,WTOLIST)                                           86200000
         BR    R6                           RETURN                      86500000
*                                                                       86800000
*********************************************************************** 87100000
*        MESSAGES FOR DISPLAY                                         * 87400000
*********************************************************************** 87700000
*                                                                       88000000
WTOBLANK DC    CL(L'WTOTEXT)' '             BLANKS TO CLEAR WTO TEXT    88300000
*                                                                       88600000
MSGSTART WTO   'CSQ4BAX0 SAMPLE USER EXIT STARTED       ',MF=L          88900000
MSGENDED WTO   'CSQ4BAX0 SAMPLE USER EXIT ENDED         ',MF=L          89200000
*                                                                       89500000
MSGWTOR  WTOR  'CSQ4BAX0 WAITING FOR REPLY              ',MF=L          89800000
WTORLEN  EQU   *-MSGWTOR                                                90100000
*                                                                       90400000
MSGXSTRE WTO   'MQCXP STRUCID ERROR                     ',MF=L          90700000
MSGXVERE WTO   'MQCXP VERSION ERROR                     ',MF=L          91000000
MSGXXIDM WTO   'MESSAGE EXIT                            ',MF=L          91300000
MSGXXIDE WTO   'NOT A MESSAGE EXIT                      ',MF=L          91600000
MSGXREAI WTO   'INITIALIZATION                          ',MF=L          91900000
MSGXREAT WTO   'TERMINATION                             ',MF=L          92200000
MSGXREAP WTO   'PROCESS A MESSAGE                       ',MF=L          92500000
MSGXREAE WTO   'INVALID EXITREASON FOR MESSAGE EXIT     ',MF=L          92800000
MSGXUSAE WTO   'EXIT USER AREA IS NON-NULL              ',MF=L          93100000
MSGXDATE WTO   'EXIT DATA IS NON-BLANK                  ',MF=L          93400000
*                                                                       93700000
MSGCVERE WTO   'MQCD VERSION ERROR                      ',MF=L          94000000
MSGCCHAN DC    CL(L'WTOTEXT1)'CHANNELNAME ='                            94300000
MSGCXMIT DC    CL(L'WTOTEXT1)'XMITQNAME ='                              94600000
MSGCSCON DC    CL(L'WTOTEXT1)'SHORTCONNNAME ='                          94900000
*                                                                       95200000
MSGMQCON DC    CL(L'WTOTEXT1)'MQCONN:        MQCC='                     95500000
MSGMQDIS DC    CL(L'WTOTEXT1)'MQDISC:        MQCC='                     95800000
MSGMQXWA DC    CL(L'WTOTEXT1)'MQXWAIT:       MQCC='                     96100000
MSGMQRC  DC    CL(L'WTOTEXT3)'   MQRC='                                 96400000
*                                                                       96700000
***************************************************************         97000000
*        CONSTANTS                                            *         97300000
***************************************************************         97600000
*                                                                       97900000
         LTORG ,                                                        98200000
*                                                                       98500000
***************************************************************         98800000
* End Of CSQ4BAX0                                             *         99100000
***************************************************************         99400000
         END   CSQ4BAX0                                                 99700000
