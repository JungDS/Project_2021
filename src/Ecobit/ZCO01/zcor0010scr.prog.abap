*&---------------------------------------------------------------------*
*& Include          ZCOR0010SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN FUNCTION KEY 1.
SELECTION-SCREEN FUNCTION KEY 2.

SELECTION-SCREEN: BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-T01.
PARAMETERS PA_KOKRS TYPE KOKRS  DEFAULT '1000'.
*PARAMETERS PA_KOKRS TYPE KOKRS MEMORY ID CAC  DEFAULT '1000'.

PARAMETERS :
  PA_FILE TYPE RLGRAP-FILENAME OBLIGATORY DEFAULT 'C:\',
  PA_MODE TYPE RFPDO-ALLGAZMD DEFAULT 'N' MODIF ID A.

SELECTION-SCREEN: END OF BLOCK B1.
