*&---------------------------------------------------------------------*
*& Include          ZCOR0230SCR
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL1 WITH FRAME TITLE TEXT-T01.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(12) TEXT-001 FOR FIELD PA_KOKRS.
SELECTION-SCREEN POSITION 33.
PARAMETERS: PA_KOKRS TYPE KOKRS MEMORY ID CAC OBLIGATORY
                                MATCHCODE OBJECT CSH_TKA01
                                MODIF ID MG1 DEFAULT '1000'.
SELECTION-SCREEN COMMENT 45(20) PA_KTXT MODIF ID MG1.
SELECTION-SCREEN END OF LINE.

PARAMETERS: PA_GJAHR TYPE GJAHR OBLIGATORY DEFAULT SY-DATUM(4),
            PA_PERBL TYPE PERBL OBLIGATORY DEFAULT SY-DATUM+4(2),
            PA_VERSN TYPE VERSN OBLIGATORY DEFAULT '000'
                                MATCHCODE OBJECT ZH_TKA09.
SELECTION-SCREEN: END OF BLOCK BL1.

SELECTION-SCREEN: BEGIN OF BLOCK BL2 WITH FRAME TITLE TEXT-T02.
PARAMETERS: PA_BUKRS TYPE BUKRS OBLIGATORY MEMORY ID BUK
                                MATCHCODE OBJECT ZSH_BUKRS.

SELECT-OPTIONS: SO_POSID FOR PRPS-POSID MODIF ID WBS
                                       MATCHCODE OBJECT PRP.

PARAMETERS: PA_PDGR TYPE POSIDGR MODIF ID WBS.

SELECTION-SCREEN BEGIN OF LINE.

PARAMETERS: PA_RAD1 RADIOBUTTON GROUP RD1 DEFAULT 'X' USER-COMMAND US1.
SELECTION-SCREEN COMMENT 2(12) TEXT-005 FOR FIELD PA_RAD1.


SELECTION-SCREEN POSITION 20.
PARAMETERS  PA_RAD2 RADIOBUTTON GROUP RD1.

SELECTION-SCREEN COMMENT 23(12) TEXT-006 FOR FIELD PA_RAD2.

SELECTION-SCREEN POSITION 40.
PARAMETERS  PA_RAD3 RADIOBUTTON GROUP RD1.
SELECTION-SCREEN COMMENT 43(12) TEXT-007 FOR FIELD PA_RAD3.

SELECTION-SCREEN END OF LINE.

*--------------------------------------------------------------------*
* [ESG_CO] DEV_ESG 기존PGM 고도화 #2 - 2021.11.18 13:24:41
*--------------------------------------------------------------------*
SELECTION-SCREEN SKIP 1.
PARAMETERS PA_EQWBS AS CHECKBOX.

SELECTION-SCREEN: END OF BLOCK BL2.

"__ help
SELECTION-SCREEN FUNCTION KEY 1.
