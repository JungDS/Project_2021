*&---------------------------------------------------------------------*
*& Include          ZCOR0400SCR
*&---------------------------------------------------------------------*
SELECTION-SCREEN FUNCTION KEY 1.
SELECTION-SCREEN: BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-t01.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(12) TEXT-001 FOR FIELD pa_kokrs.
SELECTION-SCREEN POSITION 33.
PARAMETERS: pa_kokrs TYPE kokrs MEMORY ID cac OBLIGATORY
                                MATCHCODE OBJECT csh_tka01
                                MODIF ID mg1 DEFAULT '1000'.
SELECTION-SCREEN COMMENT 45(20) pa_ktxt MODIF ID mg1.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(12) TEXT-002 FOR FIELD pa_versn.
SELECTION-SCREEN POSITION 33.
PARAMETERS  pa_versn TYPE versn OBLIGATORY MATCHCODE
                                 OBJECT zh_tka09
                                 DEFAULT 'B1'
                                 MODIF ID mg1.
SELECTION-SCREEN COMMENT 45(20) pa_vtxt MODIF ID mg1.
SELECTION-SCREEN END OF LINE.

PARAMETERS pa_gjahr TYPE gjahr OBLIGATORY DEFAULT sy-datum(4).

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(12) TEXT-005 FOR FIELD pa_kstar.
SELECTION-SCREEN POSITION 33.
PARAMETERS  pa_kstar LIKE cska-kstar OBLIGATORY.
SELECTION-SCREEN COMMENT 45(30) pa_ktext.
SELECTION-SCREEN END OF LINE.

SELECT-OPTIONS so_bukrs  FOR t001-bukrs  NO INTERVALS.
SELECT-OPTIONS so_prctr  FOR zcot0320-prctr1 NO-DISPLAY.
SELECT-OPTIONS so_pspid  FOR PRPS-POSID NO-DISPLAY.

SELECTION-SCREEN: END OF BLOCK bl1.

SELECTION-SCREEN: BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-t02.

SELECTION-SCREEN BEGIN OF LINE.

PARAMETERS: pa_rad1 RADIOBUTTON GROUP rd1 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 2(12) TEXT-003 FOR FIELD pa_rad1.

SELECTION-SCREEN POSITION 20.
PARAMETERS  pa_rad2 RADIOBUTTON GROUP rd1.

SELECTION-SCREEN COMMENT 23(12) TEXT-004 FOR FIELD pa_rad2.

SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN: END OF BLOCK bl2.
