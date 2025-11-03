BEGIN_PROGRAM(CSQJLOGP)
*/**** START OF SPECIFICATIONS****************************************/ 01000000
*/*                                                                  */ 02000000
*/*01* MODULE-NAME = CSQJLOGP                                        */ 03000000
*/*                                                                  */ 04000000
*/*01* DESCRIPTIVE-NAME = SYSTEM LOG PARAMETER VALUE TABLE.          */ 05000000
*/*                                                                  */ 06000000
*/* @START_COPYRIGHT@                                                */ 07000000
*/* Statement:     Licensed Materials - Property of IBM              */ 08000000
*/*                                                                  */ 09000000
*/*                5695-137                                          */ 12000000
*/*                (C) Copyright IBM Corporation. 1993, 1997         */ 13000000
*/*                                                                  */ 17000000
*/* Status:        Version 1 Release 2                               */ 18000000
*/*                                                                  */ 19000000
*/* @END_COPYRIGHT@                                                  */ 23000000
*/*                                                                  */ 24000000
*/*01* FUNCTION = THIS MODULE CONTAINS SYSTEM LOG PARAMETER VALUES   */ 25000000
*/*         WHICH ARE DETERMINED AT SUBSYSTEM INSTALLATION TIME.     */ 26000000
*/*                                                                  */ 27000000
*/*01* NOTES =                                                       */ 28000000
*/*                                                                  */ 29000000
*/*02*  DEPENDENCIES = NONE.                                         */ 30000000
*/*                                                                  */ 31000000
*/*02*  RESTRICTIONS = NONE.                                         */ 32000000
*/*                                                                  */ 33000000
*/*02*  REGISTER-CONVENTIONS = NONE.                                 */ 34000000
*/*                                                                  */ 35000000
*/*02*  PATCH-LABEL = NONE.                                          */ 36000000
*/*                                                                  */ 37000000
*/*01* MODULE-TYPE = PROCEDURE                                       */ 38000000
*/*                                                                  */ 39000000
*/*02*  PROCESSOR = ASSEMBLER H                                      */ 40000000
*/*                                                                  */ 41000000
*/*02*  MODULE-SIZE = SEE ASSEMBLER LISTING.                         */ 42000000
*/*                                                                  */ 43000000
*/*02*  ATTRIBUTES = NON-EXECUTABLE, REFRESHABLE.                    */ 44000000
*/*                                                                  */ 45000000
*/*01* ENTRY-POINT = NONE.                                           */ 46000000
*/*                                                                  */ 47000000
*/*01* INPUT = NONE.                                                 */ 48000000
*/*                                                                  */ 50000000
*/*01* OUTPUT = NONE.                                                */ 52000000
*/*                                                                  */ 54000000
*/*01* EXIT-NORMAL = NONE.                                           */ 56000000
*/*                                                                  */ 58000000
*/*01* EXIT-ERROR = NONE.                                            */ 60000000
*/*                                                                  */ 62000000
*/*01* EXTERNAL REFERENCES = NONE.                                   */ 64000000
*/*                                                                  */ 66000000
*/*01* TABLES = NONE.                                                */ 68000000
*/*                                                                  */ 70000000
*/*01* MACROS = NONE.                                                */ 72000000
*/*                                                                  */ 74000000
*/*01* CHANGE-ACTIVITY = NONE                                        */ 76000000
*/*                                                                  */ 78000000
*/*01* SERIALIZATION-(LATCHES/LOCKS) = NONE.                         */ 80000000
*/*                                                                  */ 82000000
*/*                                                                  */ 84000000
*/*                                                                  */ 86000000
*/**** END OF SPECIFICATIONS******************************************/ 88000000
*                                                                       90000000
*             Dual copy and log archiving are defaulted on.             92000000
*                                                                       94000000
         CSQ6LOGP                                                       96000000
         END                                                            98000000

END_PROGRAM