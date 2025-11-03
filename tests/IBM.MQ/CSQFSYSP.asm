BEGIN_PROGRAM(CSQFSYSP)
*/**** START OF SPECIFICATIONS****************************************/ 01000000
*/*                                                                  */ 02000000
*/*01* MODULE-NAME = CSQFSYSP                                        */ 03000000
*/*                                                                  */ 04000000
*/*01* DESCRIPTIVE-NAME = SYSTEM PARAMETER VALUE TABLE.              */ 05000000
*/*                                                                  */ 06000000
*/* @START_COPYRIGHT@                                                */ 07000000
*/* Statement:     Licensed Materials - Property of IBM              */ 08000000
*/*                                                                  */ 09000000
*/*                5695-137                                          */ 12000000
*/*                (C) Copyright IBM Corporation. 1993, 1997         */ 13000000
*/*                                                                  */ 17000000
*/* Status:        Version 1 Release 2                               */ 18000000
*/* @END_COPYRIGHT@                                                  */ 23000000
*/*                                                                  */ 24000000
*/*01* FUNCTION = THIS MODULE CONTAINS SYSTEM PARAMETER VALUES WHICH */ 25000000
*/*               ARE DETERMINED AT SUBSYSTEM INSTALLATION TIME.     */ 26000000
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
*/*                                                                  */ 40000000
*/*02*  PROCESSOR = ASSEMBLER H                                      */ 42000000
*/*                                                                  */ 44000000
*/*02*  MODULE-SIZE = SEE ASSEMBLER LISTING.                         */ 46000000
*/*                                                                  */ 48000000
*/*02*  ATTRIBUTES = NON-EXECUTABLE, REFRESHABLE.                    */ 50000000
*/*                                                                  */ 52000000
*/*01* ENTRY-POINT = NONE.                                           */ 54000000
*/*                                                                  */ 56000000
*/*01* INPUT = NONE.                                                 */ 58000000
*/*                                                                  */ 60000000
*/*01* OUTPUT = NONE.                                                */ 62000000
*/*                                                                  */ 64000000
*/*01* EXIT-NORMAL = NONE.                                           */ 66000000
*/*                                                                  */ 68000000
*/*01* EXIT-ERROR = NONE.                                            */ 70000000
*/*                                                                  */ 72000000
*/*01* EXTERNAL REFERENCES = NONE.                                   */ 74000000
*/*                                                                  */ 76000000
*/*01* TABLES = NONE.                                                */ 78000000
*/*                                                                  */ 80000000
*/*01* MACROS = NONE.                                                */ 82000000
*/*                                                                  */ 84000000
*/*01* CHANGE-ACTIVITY =                                             */ 85000000
*/*   \D1   DCR101 950814 RDM     DCR101 Add IMS bridge fields       */ 86000000
*/*  $P1= P5239    120 970212 KA    : Set back to defaults           */ 87000000
*/*                                                                  */ 88000000
*/*01* SERIALIZATION-(LATCHES/LOCKS) = NONE.                         */ 90000000
*/*                                                                  */ 92000000
*/**** END OF SPECIFICATIONS******************************************/ 94000000
CSQNEW   CSQ6SYSP TRACSTR=YES      Global Trace auto start, class 1     95000000
         END                                                            98000000

END_PROGRAM