         TITLE 'MQSeries for MVS/ESA - SAMPLE API CROSSING EXIT'        00100000
********************************************************************    00200000
* File Name:    CSQCAPX (Must be called this)                      *    00300000
*                                                                  *    00400000
* @START_COPYRIGHT@                                                *    00500000
*   Statement:     Licensed Materials - Property of IBM            *    00600000
*                                                                  *    00700000
*                  5695-137                                        *    00760000
*                  (C) Copyright IBM Corporation. 1993, 1997       *    00800000
*                                                                  *    00900000
*   Status:        Version 1 Release 2                             *    01000000
* @END_COPYRIGHT@                                                  *    01200000
*                                                                  *    01300000
* Environment:  CICS/ESA Version 3.3; BAL                          *    01400000
*                                                                  *    01500000
* Function:     The CICS implementation of the API                 *    01600000
*               crossing EXIT                                      *    01700000
*                                                                  *    01800000
* Description:  Sample program to show the use of the API crossing *    01900000
*               exit                                               *    02000000
*                                                                  *    02100000
* Function:     To show the operation of the exit this sample      *    02200000
*               writes messages to CICS temporary queue CSQ1EXIT.  *    02300000
*               The message identifies whether the exit is being   *    02400000
*               invoked before or after the MQ API call. If after  *    02500000
*               the message contains the completion code and       *    02600000
*               reason returned by the call.                       *    02700000
*               No MQ API calls are made from within the sample    *    02800000
*               exit though most are allowed.                      *    02900000
*                                                                  *    03000000
* Performance Note:                                                *    03100000
*               This exit issues 6 EXEC CICS calls for each MQ API *    03200000
*               call invoked - if this is in use performance       *    03300000
*               will be impacted                                   *    03400000
*                                                                  *    03500000
* Restrictions: AMODE(31),RMODE(ANY)                               *    03600000
*               EXECKEY(CICS)                                      *    03700000
*               If problems occur writing to the CICS TS queue the *    03800000
*               sample exit may abend.                             *    03900000
*                                                                  *    04000000
********************************************************************    04100000
         EJECT                                                          04200000
********************************************************************    04300000
*                                                                  *    04400000
* ENTRY POINT =  CSQCAPX                                           *    04500000
*                                                                  *    04600000
*    INPUT  = PARAMETERS EXPLICITLY PASSED TO THIS FUNCTION:       *    04700000
*             = Address of the exit parameter block (MQXP)         *    04800000
*             = Address of each parameter of the call which caused *    04900000
*               the exit to be invoked                             *    05000000
*                                                                  *    05100000
*    OUTPUT  = PARAMETERS EXPLICITLY RETURNED:                     *    05200000
*             = Address of the exit parameter block (MQXP)         *    05300000
*             = Address of each paramter of the call which caused  *    05400000
*               the exit to be invoked                             *    05500000
*                                                                  *    05600000
********************************************************************    05700000
*                                                                  *    05800000
* REGISTER USAGE :                                                 *    05900000
*         REGISTER R0  is work register                            *    06000000
*         REGISTER R1  is not used                                 *    06100000
*         REGISTER R2  is work register                            *    06200000
*         REGISTER R3  is work register                            *    06300000
*         REGISTER R4  is work register                            *    06400000
*         REGISTER R5  is BEFORE, AFTER return address             *    06500000
*         REGISTER R6  is HEADER, OPERATE, TOXQUE, CODES return    *    06600000
*                         address                                  *    06700000
*         REGISTER R7  is BAFTA return address                     *    06800000
*         REGISTER R8  is not used                                 *    06900000
*         REGISTER R9  is not used                                 *    07000000
*         REGISTER R10 is MQXP address register                    *    07100000
*         REGISTER R11 is not used                                 *    07200000
*         REGISTER R12 is base address register                    *    07300000
*         REGISTER R13 is automatic storage address register       *    07400000
*         REGISTER R14 is return address                           *    07500000
*         REGISTER R15 is work register                            *    07600000
*                                                                  *    07700000
********************************************************************    07800000
*                                                                  *    07900000
* EXECUTABLE MACROS                                                *    08000000
*                                                                  *    08100000
*    DFHEIENT  -  To obtain dynamic storage                        *    08200000
*                                                                  *    08300000
********************************************************************    08400000
*                                                                  *    08500000
* EXEC CICS CALLS                                                  *    08600000
*                                                                  *    08700000
*    WRITEQ TS  - To put a message on a temporary storage queue    *    08800000
*                                                                  *    08900000
*    ASKTIME    - To get the current time                          *    09000000
*                                                                  *    09100000
*    FORMATTIME - To format the time for display in the message    *    09200000
*                                                                  *    09300000
********************************************************************    09400000
         EJECT                                                          09500000
********************************************************************    09600000
*                                                                       09700000
*                         Program logic                                 09800000
*                         -------------                                 09900000
*        MAIN                                                           10000000
*        ----                                                           10100000
*           Initialize                                                  10200000
*                                                                       10300000
*           If no commarea passed                                       10400000
*             perform ERRCLEN (and exit from the program)               10500000
*           End-If                                                      10600000
*                                                                       10700000
*           Establish addressability of parameter list                  10800000
*                                                                       10900000
*           Perform BAFTA                                               11000000
*                                                                       11100000
*           EndProg                                                     11200000
*            Return to CICS                                             11300000
*                                                                       11400000
*        BAFTA                                                          11500000
*        -----                                                          11600000
*           If exit invocation is before MQ call                        11700000
*              perform BEFORE                                           11800000
*           Else if exit invocation is after MQ call                    11900000
*              perform AFTER                                            12000000
*           Else                                                        12100000
*              perform HEADER                                           12200000
*              Move error message to message field                      12300000
*              Put invalid exitreason in message field                  12400000
*              Perform TOXQUE to write message to temporary queue       12500000
*           End-If                                                      12600000
*           Return to caller                                            12700000
*                                                                       12800000
*        BEFORE                                                         12900000
*        ------                                                         13000000
*           Perform HEADER to build message header                      13100000
*           Move before message to message field                        13200000
*           Perform OPERATE to add MQ operation to message              13300000
*           Perform TOXQUE to write message to temporary queue          13400000
*           Return to caller                                            13500000
*                                                                       13600000
*        AFTER                                                          13700000
*        -----                                                          13800000
*           Perform HEADER to build message header                      13900000
*           Move after message to message field                         14000000
*           Perform OPERATE to add MQ operation to message              14100000
*           Perform CODES to add completion code and reason to message  14200000
*           Perform TOXQUE to write message to temporary queue          14300000
*           Return to caller                                            14400000
*                                                                       14500000
*        OPERATE                                                        14600000
*        -------                                                        14700000
*           If exitcommand is MQOPEN                                    14800000
*              put command name in message                              14900000
*           Else if exitcommand is MQCLOSE                              15000000
*              put command name in message                              15100000
*           Else if exitcommand is MQGET                                15200000
*              put command name in message                              15300000
*           Else if exitcommand is MQPUT                                15400000
*              put command name in message                              15500000
*           Else if exitcommand is MQPUT1                               15600000
*              put command name in message                              15700000
*           Else if exitcommand is MQINQ                                15800000
*              put command name in message                              15900000
*           Else if exitcommand is MQSET                                16000000
*              put command name in message                              16100000
*           Else                                                        16200000
*              perform HEADER                                           16300000
*              Move error message to message field                      16400000
*              Put invalid exitcommand in message field                 16500000
*              Perform TOXQUE to write message to temporary queue       16600000
*              Return to BAFTA                                          16700000
*           End-If                                                      16800000
*           Return to caller                                            16900000
*                                                                       17000000
*        CODES                                                          17100000
*        -----                                                          17200000
*           Get compcode from parameter list                            17300000
*           Make it displayable and put it in message                   17400000
*           Get reason from parameter list                              17500000
*           Make it displayable and put it in message                   17600000
*                                                                       17700000
*        TOXQUE                                                         17800000
*        ------                                                         17900000
*           Write message to CICS Temporary Storage queue               18000000
*                                                                       18100000
*        HEADER                                                         18200000
*        ------                                                         18300000
*           Move transaction name to header                             18400000
*           Move task number to header                                  18500000
*           Get current time from CICS and put it in the header         18600000
*           Return to caller                                            18700000
*                                                                       18800000
*        ERRCLEN                                                        18900000
*        -------                                                        19000000
*           Perform HEADER to build message header                      19100000
*           Move error message to message field                         19200000
*           Perform TOXQUE to write message to temporary queue          19300000
*           Return to caller                                            19400000
* *************************************************************         19500000
         EJECT                                                          19600000
*                                                                       19700000
         DFHREGS                        Register equates                19800000
*                                                                       19900000
MQXP     CMQXPA LIST=YES                                                20000000
*                                                                       20100000
DFHEISTG DSECT                                                          20200000
*                                                                       20300000
WRITEMSG DS    0CL74                    Message area                    20400000
MSGHDR   DS    CL23                     Header of output messages       20500000
MSGTEXT  DS    CL51                     Body of output messages         20600000
*                                                                       20700000
CURTIME  DS    PL08                     Target for absolute time        20800000
WRKDWORD DS    D                        Work double word                20900000
WORKBYTE DS    CL1                      Work byte                       21000000
WORKSTOR DS    CL1                      Work storage byte               21100000
WORKHALF DS    H                        Work half word                  21200000
WORKFLD1 DS    CL8                      Used for data conversion        21400000
*                                                                       21600000
COMPTR   DS    F                        Save commarea address           21800000
COMLEN   DS    H                        Store commarea length           22000000
*                                                                       22200000
COMPCODE DS    F                        Completion code                 22400000
REASON   DS    F                        Reason                          22600000
*                                                                       22800000
         EJECT                                                          23000000
********************************************************************    23200000
*  Code start                                                      *    23400000
********************************************************************    23600000
*                                                                  *    23800000
*  Macro DFHEIENT is used to obtain working storage.               *    24000000
*  In our example a single register for code (R12) and             *    24200000
*   storage (R13) is sufficient                                    *    24400000
*                                                                  *    24600000
********************************************************************    24800000
CSQCAPX  DFHEIENT CODEREG=(R12),DATAREG=(R13)                           25000000
         B     MAIN                                                     25200000
         DC    C'MQSeries SAMPLE API EXIT PROGRAM '                     25400000
         DC    C'NAME : '                                               25600000
         DC    C'CSQCAPX'                                               25800000
         DC    C' DATE AND TIME ASSEMBLED : '                           26000000
         DC    C'&SYSDATE',C','                                         26200000
         DC    C'&SYSTIME '                                             26400000
         DC    C'&SYSPARM '                                             26600000
*                                                                       26800000
         SPACE 4                                                        27000000
********************************************************************    27200000
*  SECTION NAME : MAIN                                             *    27400000
*                                                                  *    27600000
*  FUNCTION     : Controls flow of program                         *    27800000
*                                                                  *    28000000
*  CALLED BY    : MQSeries CICS adapter                            *    28200000
*                                                                  *    28400000
*  CALLS        : BAFTA, ERRCLEN                                   *    28600000
*                                                                  *    28800000
*  RETURN       : EXEC CICS RETURN                                 *    29000000
*                                                                  *    29200000
********************************************************************    29400000
MAIN     DS    0H                                                       29600000
*                                                                       29800000
* Check that the paramters have been passed                             30000000
*                                                                       30200000
         CLC   EIBCALEN,FZERO           Check commarea length           30400000
         BE    ERRCLEN                  Is not zero                     30600000
*                                                                       30800000
* Establish addressability                                              31000000
*                                                                       31200000
         L     R10,DFHEICAP             Load address of commarea        31400000
         ST    R10,COMPTR               Save commarea pointer           31600000
         MVC   COMLEN,EIBCALEN          Save commarea length            31800000
         USING MQXP_COPYPLIST,R10       Address the parameter list      32000000
         L     R10,MQXP_PXPB            Address of XPB from parmlist    32200000
         USING MQXP,R10                 and address it                  32400000
*                                                                       32600000
********************************************************************    32700000
*                                                                       32800000
* Your exit code, for example....                                       33000000
*                                                                       33200000
*                                                                       33400000
         BAL   R7,BAFTA                 Do the exit processing          33600000
*                                                                       33800000
********************************************************************    33860000
*                                                                       33930000
* Exit from the program                                                 34000000
*                                                                       34200000
ENDPROG  DS    0H                                                       34400000
         EXEC  CICS RETURN                                              34600000
*                                                                       34800000
         EJECT                                                          35000000
********************************************************************    35200000
*  SECTION NAME : BAFTA                                            *    35400000
*                                                                  *    35600000
*  FUNCTION     : Determines whether exit invocation is before or  *    35800000
*                 after the API call                               *    36000000
*                                                                  *    36200000
*  CALLED BY    : MAIN                                             *    36400000
*                                                                  *    36600000
*  CALLS        : BEFORE, AFTER, HEADER, TOXQUE                    *    36800000
*                                                                  *    37000000
*  RETURN       : To Register 7                                    *    37200000
*                                                                  *    37400000
********************************************************************    37600000
*                                                                       37800000
BAFTA    DS    0H                                                       38000000
         LA    R0,MQXR_BEFORE              Load                         38200000
         C     R0,MQXP_EXITREASON          Is it before?                38400000
         BNE   TSTAFTER                    No .. try another            38600000
         BAL   R5,BEFORE                   Yes                          38800000
         B     BAFTA_END                   Go to end                    39000000
*                                                                       39200000
TSTAFTER DS    0H                                                       39400000
         LA    R0,MQXR_AFTER               Load                         39600000
         C     R0,MQXP_EXITREASON          Is it after?                 39800000
         BNE   XR_UNKWN                    No .. go to error            40000000
         BAL   R5,AFTER                    Yes                          40200000
         B     BAFTA_END                   Go to end                    40400000
*                                                                       40600000
XR_UNKWN DS    0H                                                       40800000
         BAL   R6,HEADER                   Construct header             41000000
         MVC   MSGTEXT,M_INVO              Move in error message        41200000
         L     R0,MQXP_EXITREASON          Load incokation reason       41400000
         CVD   R0,WRKDWORD                 Convert to packed decimal    41600000
         UNPK  MSGTEXT+40(8),WRKDWORD+4(4) Convert to zoned decimal     41800000
         MVZ   MSGTEXT+47(1),MSGTEXT+46    Make it display              42000000
         BAL   R6,TOXQUE                   Write to exit TS queue       42200000
*                                                                       42400000
BAFTA_END  DS    0H                                                     42600000
           BR    R7                        Return to caller             42800000
*                                                                       43000000
         EJECT                                                          43200000
********************************************************************    43400000
*  SECTION NAME : BEFORE                                           *    43600000
*                                                                  *    43800000
*  FUNCTION     : Build and write message to TS queue              *    44000000
*                                                                  *    44200000
*  CALLED BY    : BAFTA                                            *    44400000
*                                                                  *    44600000
*  CALLS        : HEADER, OPERATE, TOXQUE                          *    44800000
*                                                                  *    45000000
*  RETURN       : To Register 5                                    *    45200000
*                                                                  *    45400000
********************************************************************    45600000
BEFORE   DS    0H                                                       45800000
         BAL   R6,HEADER                Construct header                46000000
         MVC   MSGTEXT,M_BEFORE         Move in before message          46200000
         BAL   R6,OPERATE               Put operation into message      46400000
         BAL   R6,TOXQUE                Write to exit TS queue          46600000
         BR    R5                       Return to caller                46800000
*                                                                       47000000
         EJECT                                                          47200000
********************************************************************    47400000
*  SECTION NAME : AFTER                                            *    47600000
*                                                                  *    47800000
*  FUNCTION     : Build and write message to TS queue              *    48000000
*                                                                  *    48200000
*  CALLED BY    : BAFTA                                            *    48400000
*                                                                  *    48600000
*  CALLS        : HEADER, OPERATE, CODES, TOXQUE                   *    48800000
*                                                                  *    49000000
*  RETURN       : To Register 5                                    *    49200000
*                                                                  *    49400000
********************************************************************    49600000
AFTER    DS    0H                                                       49800000
         BAL   R6,HEADER                Construct header                50000000
         MVC   MSGTEXT,M_AFTER          Move in after message           50200000
         BAL   R6,OPERATE               Put operation into message      50400000
         BAL   R6,CODES                 Put in compcode and reason      50600000
         BAL   R6,TOXQUE                Write to exit TS queue          50800000
         BR    R5                       Return to caller                51000000
*                                                                       51200000
         EJECT                                                          51400000
********************************************************************    51600000
*  SECTION NAME : OPERATE                                          *    51800000
*                                                                  *    52000000
*  FUNCTION     : Put MQ API operation in to message               *    52200000
*                                                                  *    52400000
*  CALLED BY    : AFTER, BEFORE                                    *    52600000
*                                                                  *    52800000
*  CALLS        : CODES, TOXQUE                                    *    53000000
*                                                                  *    53200000
*  RETURN       : Normal to Register 6                             *    53400000
*                 Error  to Register 5                             *    53600000
*                                                                  *    53800000
********************************************************************    54000000
OPERATE  DS    0H                                                       54200000
*                                                                       54400000
ISOPEN   DS    0H                                                       54600000
         LA    R0,MQXC_MQOPEN           Load                            54800000
         C     R0,MQXP_EXITCOMMAND      Is it open?                     55000000
         BNE   ISCLOSE                  No .. try another               55200000
         MVC   MSGTEXT+16(7),OP_OPEN    Yes, put operation in message   55400000
         B     OPERATE_END              Go to end                       55600000
*                                                                       55800000
ISCLOSE  DS    0H                                                       56000000
         LA    R0,MQXC_MQCLOSE          Load                            56200000
         C     R0,MQXP_EXITCOMMAND      Is it close?                    56400000
         BNE   ISGET                    No .. try another               56600000
         MVC   MSGTEXT+16(7),OP_CLOSE   Yes, put operation in message   56800000
         B     OPERATE_END              Go to end                       57000000
*                                                                       57200000
ISGET    DS    0H                                                       57400000
         LA    R0,MQXC_MQGET            Load                            57600000
         C     R0,MQXP_EXITCOMMAND      Is it get?                      57800000
         BNE   ISPUT                    No .. try another               58000000
         MVC   MSGTEXT+16(7),OP_GET     Yes, put operation in message   58200000
         B     OPERATE_END              Go to end                       58400000
*                                                                       58600000
ISPUT    DS    0H                                                       58800000
         LA    R0,MQXC_MQPUT            Load                            59000000
         C     R0,MQXP_EXITCOMMAND      Is it put?                      59200000
         BNE   ISPUT1                   No .. try another               59400000
         MVC   MSGTEXT+16(7),OP_PUT     Yes, put operation in message   59600000
         B     OPERATE_END              Go to end                       59800000
*                                                                       60000000
ISPUT1   DS    0H                                                       60200000
         LA    R0,MQXC_MQPUT1           Load                            60400000
         C     R0,MQXP_EXITCOMMAND      Is it put1?                     60600000
         BNE   ISINQ                    No .. try another               60800000
         MVC   MSGTEXT+16(7),OP_PUT1    Yes, put operation in message   61000000
         B     OPERATE_END              Go to end                       61200000
*                                                                       61400000
ISINQ    DS    0H                                                       61600000
         LA    R0,MQXC_MQINQ            Load                            61800000
         C     R0,MQXP_EXITCOMMAND      Is it inquire?                  62000000
         BNE   ISSET                    No .. try another               62200000
         MVC   MSGTEXT+16(7),OP_INQ     Yes, put operation in message   62400000
         B     OPERATE_END              Go to end                       62600000
*                                                                       62800000
ISSET    DS    0H                                                       63000000
         LA    R0,MQXC_MQSET            Load                            63200000
         C     R0,MQXP_EXITCOMMAND      Is it set?                      63400000
         BNE   OP_UNKWN                 No .. try another               63600000
         MVC   MSGTEXT+16(7),OP_SET     Yes, put operation in message   63800000
         B     OPERATE_END              Go to end                       64000000
*                                                                       64200000
OP_UNKWN DS    0H                                                       64400000
         MVC   MSGTEXT,M_OPER              Move in error message        64600000
         L     R0,MQXP_EXITCOMMAND         Load exit command            64800000
         CVD   R0,WRKDWORD                 Convert to packed decimal    65000000
         UNPK  MSGTEXT+41(8),WRKDWORD+4(4) Convert to zoned decimal     65200000
         MVZ   MSGTEXT+48(1),MSGTEXT+47    Make it display              65400000
         BAL   R6,TOXQUE                   Write to exit TS queue       65600000
         BR    R5                          Abnormal return to BAFTA     65800000
*                                                                       66000000
OPERATE_END  DS    0H                                                   66200000
             BR    R6                   Return to caller                66400000
*                                                                       66600000
         EJECT                                                          66800000
********************************************************************    67000000
*  SECTION NAME : CODES                                            *    67200000
*                                                                  *    67400000
*  FUNCTION     : Gets compcode and reason from parameter list and *    67600000
*                 puts them in the output message                  *    67800000
*                                                                  *    68000000
*  CALLED BY    : AFTER                                            *    68200000
*                                                                  *    68400000
*  CALLS        : Nothing                                          *    68600000
*                                                                  *    68800000
*  RETURN       : To Register 6                                    *    69000000
*                                                                  *    69200000
********************************************************************    69400000
CODES    DS    0H                                                       69600000
*                                                                       69800000
* Get compcode from parameter list                                      70000000
*                                                                       70200000
         L     R2,MQXP_EXITPARMCOUNT    Load number of parameters       70400000
         BCTR  R2,0                     Reduce count by 1               70600000
         L     R3,COMPTR                Load start of call parmlist     70800000
         SLL   R2,2                     Multiply parms-1 by 4           71000000
         L     R4,0(R2,R3)              to get offset of compcode       71200000
         L     R0,0(0,R4)               Load compcode                   71400000
         ST    R0,COMPCODE              Store                           71600000
*                                                                       71800000
* Make it displayable                                                   72000000
*                                                                       72200000
         L     R0,COMPCODE              Load compcode                   72400000
         CVD   R0,WRKDWORD              Convert to packed decimal       72600000
         UNPK  WORKFLD1,WRKDWORD+4(4)   Convert to zoned decimal        72800000
         MVZ   WORKFLD1+7(1),WORKFLD1+6 Make it display                 73000000
         MVC   MSGTEXT+34(4),WORKFLD1+4 Move value to message           73200000
*                                                                       73400000
* Get reason from parameter list                                        73600000
*                                                                       73800000
         L     R2,MQXP_EXITPARMCOUNT    Load number of parameters       74000000
         L     R3,COMPTR                Load start of call parmlist     74200000
         SLL   R2,2                     Multiply parms by 4             74400000
         L     R4,0(R2,R3)              to get offset of reason         74600000
         L     R0,0(0,R4)               Load reason                     74800000
         ST    R0,REASON                Store                           75000000
*                                                                       75200000
* Make it displayable                                                   75400000
*                                                                       75600000
         L     R0,REASON                Load reason                     75800000
         CVD   R0,WRKDWORD              Convert to packed decimal       76000000
         UNPK  WORKFLD1,WRKDWORD+4(4)   Convert to zoned decimal        76200000
         MVZ   WORKFLD1+7(1),WORKFLD1+6 Make it display                 76400000
         MVC   MSGTEXT+46(4),WORKFLD1+4 Move value to message           76600000
         BR    R6                                                       76800000
*                                                                       77000000
         EJECT                                                          77200000
********************************************************************    77400000
*  SECTION NAME : TOXQUE                                           *    77600000
*                                                                  *    77800000
*  FUNCTION     : Writes message to TS queue                       *    78000000
*                                                                  *    78200000
*  CALLED BY    : ERRCLEN, BAFTA, OPERATE, BEFORE, AFTER           *    78400000
*                                                                  *    78600000
*  CALLS        : Nothing                                          *    78800000
*                                                                  *    79000000
*  RETURN       : To Register 6                                    *    79200000
*                                                                  *    79400000
********************************************************************    79600000
TOXQUE   DS    0H                                                       79800000
*                                                                       80000000
         EXEC  CICS WRITEQ TS QUEUE(CSQ1TS) FROM(WRITEMSG)             X80200000
               LENGTH(WMSGLEN)                                          80400000
*                                                                       80600000
         BR    R6                                                       80800000
*                                                                       81000000
         EJECT                                                          81200000
********************************************************************    81400000
*  SECTION NAME : HEADER                                           *    81600000
*                                                                  *    81800000
*  FUNCTION     : Constructs the 22 byte message header            *    82000000
*                                                                  *    82200000
*  CALLED BY    : ERRCLEN, BAFTA, BEFORE, AFTER                    *    82400000
*                                                                  *    82600000
*  CALLS        : Nothing                                          *    82800000
*                                                                  *    83000000
*  RETURN       : To Register 6                                    *    83200000
*                                                                  *    83400000
********************************************************************    83600000
HEADER   DS    0H                                                       83800000
         MVC   MSGHDR,M_HDR             Move in skeleton                84000000
         MVC   MSGHDR(4),EIBTRNID       Move in transaction name        84200000
         UNPK  MSGHDR+5(8),EIBTASKN     Unpack task number              84400000
         MVZ   MSGHDR+12(1),MSGHDR+11   Make it display                 84600000
*                                                                       84800000
         EXEC  CICS ASKTIME ABSTIME(CURTIME)                            85000000
*                                                                       85200000
         EXEC  CICS FORMATTIME ABSTIME(CURTIME) TIME(MSGHDR+14)        X85400000
               TIMESEP(':')                                             85600000
*                                                                       85800000
         BR    R6                                                       86000000
*                                                                       86200000
         EJECT                                                          86400000
********************************************************************    86600000
*  SECTION NAME : ERRCLEN                                          *    86800000
*                                                                  *    87000000
*  FUNCTION     : Build and writes error message if commarea       *    87200000
*                 length passed was zero                           *    87400000
*                                                                  *    87600000
*  CALLED BY    : MAIN                                             *    87800000
*                                                                  *    88000000
*  CALLS        : HEADER, TOXQUE                                   *    88200000
*                                                                  *    88400000
*  RETURN       : To ENDPROG in MAIN                               *    88600000
*                                                                  *    88800000
********************************************************************    89000000
ERRCLEN  DS    0H                                                       89200000
         BAL   R6,HEADER                Construct message header        89400000
         MVC   MSGTEXT,M_CZERO          move in error message           89600000
         BAL   R6,TOXQUE                Write to exit TS queue          89800000
         B     ENDPROG                  Abnormal return to program end  90000000
*                                                                       90200000
         EJECT                                                          90400000
*-------------------------------------------------------------*         90600000
* CONSTANTS, EQUATES & MESSAGES                               *         90800000
*-------------------------------------------------------------*         91000000
FZERO    DC    F'0'                     A fullword                      91200000
CSQ1TS   DC    CL8'CSQ1EXIT'            API Exit TS queue name          91400000
*                                                                       91600000
*                                                                       91800000
OP_OPEN  DC   CL08'MQOPEN '             MQI call                        92000000
OP_CLOSE DC   CL08'MQCLOSE'             MQI call                        92200000
OP_GET   DC   CL08'MQGET  '             MQI call                        92400000
OP_PUT   DC   CL08'MQPUT  '             MQI call                        92600000
OP_PUT1  DC   CL08'MQPUT1 '             MQI call                        92800000
OP_INQ   DC   CL08'MQINQ  '             MQI call                        93000000
OP_SET   DC   CL08'MQSET  '             MQI call                        93200000
*                                                                       93400000
WMSGLEN  DC    AL2(L'WRITEMSG)                                          93600000
*                                                                       93800000
M_CZERO  DS    0CL51                                                    94000000
         DC    C'CSQCAPX: NO COMMAREA PASSED TO EXIT                '   94200000
*                                                                       94400000
M_INVO   DS    0CL51                                                    94600000
         DC    C'CSQCAPX: EXITREASON IS INVALID VALUE IS XXXXXXXX   '   94800000
*                                                                       95000000
M_OPER   DS    0CL51                                                    95200000
         DC    C'CSQCAPX: EXITCOMMAND IS INVALID VALUE IS XXXXXXXX  '   95400000
*                                                                       95600000
M_BEFORE DS    0CL51                                                    95800000
         DC    C'CSQCAPX: BEFORE XXXXXXX                            '   96000000
*                                                                       96200000
M_AFTER  DS    0CL51                                                    96400000
         DC    C'CSQCAPX:  AFTER XXXXXXX. COMPCODE=CCCC REASON=RRRR '   96600000
*                                                                       96800000
M_HDR    DS    0CL23                                                    97000000
         DS    CL04                         Transaction name            97200000
         DC    CL01' '                      Space                       97400000
         DS    CL08                         Taskid                      97600000
         DC    CL01' '                      Space                       97800000
         DS    CL08                         Time                        98000000
         DC    CL01' '                      Space                       98200000
****************************                                            98400000
* MQI CONSTANTS            *                                            98600000
****************************                                            98800000
         CMQA  LIST=NO                                                  99000000
*                                                                       99200000
         LTORG                                                          99400000
*                                                                       99600000
         END  CSQCAPX                                                   99800000
