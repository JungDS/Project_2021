*&---------------------------------------------------------------------*
*& Include          ZCOR0100SCR
*&---------------------------------------------------------------------*

*-- Source
SELECTION-SCREEN: BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-T01.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(12) TEXT-001 FOR FIELD PA_KOKRS.
SELECTION-SCREEN POSITION 33.
PARAMETERS: PA_KOKRS TYPE KOKRS MEMORY ID CAC OBLIGATORY
                                MATCHCODE OBJECT CSH_TKA01 DEFAULT '1000'.
SELECTION-SCREEN COMMENT 45(40) PA_KTXT.
SELECTION-SCREEN END OF LINE.

*--------------------------------------------------------------------*
* [ESG_CO] DEV_ESG 기존PGM 고도화 #11, 2022.02.22 13:07:55, MDP_06
*--------------------------------------------------------------------*
* 화면 필드 삭제 ( WBS 시작일자 ~ 종료일자 )
* 화면 필드 추가 ( WBS 생성일 / WBS ID )
*--------------------------------------------------------------------*
*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN COMMENT 1(12) TEXT-002 FOR FIELD PA_PSTRT.
*SELECTION-SCREEN POSITION 33.
*PARAMETERS: PA_PSTRT TYPE PS_PSTRT OBLIGATORY.
*
*SELECTION-SCREEN COMMENT 50(12) TEXT-003 FOR FIELD PA_PENDE.
*SELECTION-SCREEN POSITION 65.
*PARAMETERS: PA_PENDE TYPE PS_PENDE OBLIGATORY.
*SELECTION-SCREEN END OF LINE.

SELECT-OPTIONS: SO_ERDAT FOR PRPS-ERDAT.
SELECT-OPTIONS: SO_POSID FOR PRPS-POSID.


SELECTION-SCREEN: END OF BLOCK B1.

SELECTION-SCREEN: BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-T02.
PARAMETERS: PA_PBUKR TYPE PS_PBUKR MATCHCODE OBJECT ZSH_BUKRS "C_T001
                                   MODIF ID BUK,
            PA_PRCTR TYPE PRCTR    MODIF ID PRC.
SELECTION-SCREEN: END OF BLOCK B2.

"__ help
SELECTION-SCREEN FUNCTION KEY 1.
