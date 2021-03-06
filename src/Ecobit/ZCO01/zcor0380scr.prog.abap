*&---------------------------------------------------------------------*
*& Include          ZCOR0380SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN FUNCTION KEY 1.
SELECTION-SCREEN FUNCTION KEY 2.
SELECTION-SCREEN FUNCTION KEY 3.

SELECTION-SCREEN: BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-T01.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(12) TEXT-001 FOR FIELD PA_KOKRS.
SELECTION-SCREEN POSITION 33.
PARAMETERS: PA_KOKRS TYPE KOKRS OBLIGATORY
                                MATCHCODE OBJECT CSH_TKA01
                                DEFAULT '1000'.
SELECTION-SCREEN COMMENT 45(20) PA_KTXT.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(12) TEXT-002 FOR FIELD PA_BUKRS.
SELECTION-SCREEN POSITION 33.
PARAMETERS  PA_BUKRS TYPE BUKRS OBLIGATORY MEMORY ID BUK.

SELECTION-SCREEN COMMENT 45(20) PA_BUTXT.
SELECTION-SCREEN END OF LINE.

PARAMETERS  PA_MONTH TYPE SPMON DEFAULT SY-DATUM(6) OBLIGATORY.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(12) TEXT-003 FOR FIELD PA_WERKS.
SELECTION-SCREEN POSITION 33.
PARAMETERS : PA_WERKS TYPE WERKS_D OBLIGATORY MEMORY ID WRK.


SELECTION-SCREEN COMMENT 45(20) PA_NAME1.

SELECTION-SCREEN END OF LINE.

PARAMETERS  PA_MTART LIKE T134-MTART DEFAULT 'UNB3' OBLIGATORY.

SELECTION-SCREEN: END OF BLOCK B1.
