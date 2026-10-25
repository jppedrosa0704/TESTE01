REPORT ZPRG_INTERECTIVE_JP.

DATA: lv_vbeln          TYPE VBELN_VA.
DATA: lt_fieldcat_vbak  TYPE SLIS_T_FIELDCAT_ALV,
      ls_fieldcat_vbak  TYPE slis_fieldcat_alv.
DATA: lt_fieldcat_vbap  TYPE SLIS_T_FIELDCAT_ALV,
      ls_fieldcat_vbap  TYPE slis_fieldcat_alv.

TYPES: BEGIN OF lty_vbak,
        VBELN   TYPE VBELN_VA,
        ERDAT	  TYPE ERDAT,
        ERZET	  TYPE ERZET,
        ERNAM	  TYPE ERNAM,
        VBTYP   TYPE VBTYP,
       END OF lty_vbak.

DATA: lt_vbak TYPE TABLE OF lty_vbak,
      ls_vbak TYPE lty_vbak.


TYPES: BEGIN OF lty_vbap,
        VBELN    TYPE VBELN_VA,
        POSNR    TYPE POSNR_VA,
        MATNR    TYPE MATNR,
       END OF lty_vbap.

DATA: lt_vbap TYPE TABLE OF lty_vbap,
      ls_vbap TYPE lty_vbap.

SELECT-OPTIONS: s_vbeln FOR lv_vbeln.

SELECT VBELN ERDAT ERZET ERNAM VBTYP
  FROM VBAK
  INTO TABLE lt_vbak
  WHERE vbeln IN s_vbeln.


ls_fieldcat_vbak-COL_POS    = '1'.
ls_fieldcat_vbak-FIELDNAME  = 'VBELN'.
ls_fieldcat_vbak-TABNAME    = 'lt_vbak'.
ls_fieldcat_vbak-HOTSPOT    = 'X'.
ls_fieldcat_vbak-SELTEXT_L  = 'Sales Order Number'.
APPEND ls_fieldcat_vbak to lt_fieldcat_vbak.
CLEAR ls_fieldcat_vbak.

ls_fieldcat_vbak-COL_POS    = '2'.
ls_fieldcat_vbak-FIELDNAME  = 'ERDAT'.
ls_fieldcat_vbak-TABNAME    = 'lt_vbak'.
ls_fieldcat_vbak-SELTEXT_L  = 'Creation Date'.
APPEND ls_fieldcat_vbak to lt_fieldcat_vbak.
CLEAR ls_fieldcat_vbak.

ls_fieldcat_vbak-COL_POS    = '3'.
ls_fieldcat_vbak-FIELDNAME  = 'ERZET'.
ls_fieldcat_vbak-TABNAME    = 'lt_vbak'.
ls_fieldcat_vbak-SELTEXT_L  = 'Time'.
APPEND ls_fieldcat_vbak to lt_fieldcat_vbak.
CLEAR ls_fieldcat_vbak.

ls_fieldcat_vbak-COL_POS    = '4'.
ls_fieldcat_vbak-FIELDNAME  = 'ERNAM'.
ls_fieldcat_vbak-TABNAME    = 'lt_vbak'.
ls_fieldcat_vbak-SELTEXT_L  = 'User'.
APPEND ls_fieldcat_vbak to lt_fieldcat_vbak.
CLEAR ls_fieldcat_vbak.

ls_fieldcat_vbak-COL_POS    = '5'.
ls_fieldcat_vbak-FIELDNAME  = 'VBTYP'.
ls_fieldcat_vbak-TABNAME    = 'lt_vbak'.
ls_fieldcat_vbak-SELTEXT_L  = 'Document Category'.
APPEND ls_fieldcat_vbak to lt_fieldcat_vbak.
CLEAR ls_fieldcat_vbak.


CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                = ' '
*   I_BUFFER_ACTIVE                   = ' '
    I_CALLBACK_PROGRAM                = sy-repid
    I_CALLBACK_PF_STATUS_SET          = 'PF_STATUS'
    I_CALLBACK_USER_COMMAND           = 'USER_CMD'
*   I_CALLBACK_TOP_OF_PAGE            = ' '
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  =
*   I_BACKGROUND_ID                   = ' '
*   I_GRID_TITLE                      =
*   I_GRID_SETTINGS                   =
*   IS_LAYOUT                         =
    IT_FIELDCAT                       = lt_fieldcat_vbak
*   IT_EXCLUDING                      =
*   IT_SPECIAL_GROUPS                 =
*   IT_SORT                           =
*   IT_FILTER                         =
*   IS_SEL_HIDE                       =
*   I_DEFAULT                         = 'X'
*   I_SAVE                            = ' '
*   IS_VARIANT                        =
*   IT_EVENTS                         =
*   IT_EVENT_EXIT                     =
*   IS_PRINT                          =
*   IS_REPREP_ID                      =
*   I_SCREEN_START_COLUMN             = 0
*   I_SCREEN_START_LINE               = 0
*   I_SCREEN_END_COLUMN               = 0
*   I_SCREEN_END_LINE                 = 0
*   I_HTML_HEIGHT_TOP                 = 0
*   I_HTML_HEIGHT_END                 = 0
*   IT_ALV_GRAPHICS                   =
*   IT_HYPERLINK                      =
*   IT_ADD_FIELDCAT                   =
*   IT_EXCEPT_QINFO                   =
*   IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER           =
*   ES_EXIT_CAUSED_BY_USER            =
  TABLES
    T_OUTTAB                          = lt_vbak
 EXCEPTIONS
   PROGRAM_ERROR                     = 1
   OTHERS                            = 2
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

FORM PF_STATUS USING RT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'SALES'.
ENDFORM.

FORM USER_CMD  USING R_UCOMM LIKE SY-UCOMM
                                  RS_SELFIELD TYPE SLIS_SELFIELD.

  IF r_ucomm = 'DISPLAY'.
    READ TABLE lt_vbak INTO ls_vbak INDEX RS_SELFIELD-TABINDEX.
      IF sy-subrc = 0.
        SELECT VBELN POSNR MATNR
          FROM VBAP
          INTO TABLE lt_vbap
          WHERE VBELN = ls_vbak-vbeln.

*      SELECT VBELN POSNR MATNR
*        FROM VBAP
*        INTO TABLE lt_vbap
*        WHERE VBELN = RS_SELFIELD-VALUE.

        ls_fieldcat_vbap-COL_POS   = '1'.
        ls_fieldcat_vbap-FIELDNAME = 'VBELN'.
        ls_fieldcat_vbap-TABNAME   = 'lt_vbap'.
        ls_fieldcat_vbap-SELTEXT_L = 'Sales Order Number'.
        APPEND ls_fieldcat_vbap TO lt_fieldcat_vbap.
        CLEAR ls_fieldcat_vbap.

        ls_fieldcat_vbap-COL_POS   = '2'.
        ls_fieldcat_vbap-FIELDNAME = 'POSNR'.
        ls_fieldcat_vbap-TABNAME   = 'lt_vbap'.
        ls_fieldcat_vbap-SELTEXT_L = 'Sales Document Item'.
        APPEND ls_fieldcat_vbap TO lt_fieldcat_vbap.
        CLEAR ls_fieldcat_vbap.

        ls_fieldcat_vbap-COL_POS   = '3'.
        ls_fieldcat_vbap-FIELDNAME = 'MATNT'.
        ls_fieldcat_vbap-TABNAME   = 'lt_vbap'.
        ls_fieldcat_vbap-SELTEXT_L = 'Material Number'.
        APPEND ls_fieldcat_vbap TO lt_fieldcat_vbap.
        CLEAR ls_fieldcat_vbap.

        CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
         EXPORTING
*           I_INTERFACE_CHECK                 = ' '
*           I_BYPASSING_BUFFER                = ' '
*           I_BUFFER_ACTIVE                   = ' '
*           I_CALLBACK_PROGRAM                = ' '
*           I_CALLBACK_PF_STATUS_SET          = ' '
*           I_CALLBACK_USER_COMMAND           = ' '
*           I_CALLBACK_TOP_OF_PAGE            = ' '
*           I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*           I_CALLBACK_HTML_END_OF_LIST       = ' '
*           I_STRUCTURE_NAME                  =
*           I_BACKGROUND_ID                   = ' '
*           I_GRID_TITLE                      =
*           I_GRID_SETTINGS                   =
*           IS_LAYOUT                         =
            IT_FIELDCAT                       = lt_fieldcat_vbap
*           IT_EXCLUDING                      =
*           IT_SPECIAL_GROUPS                 =
*           IT_SORT                           =
*           IT_FILTER                         =
*           IS_SEL_HIDE                       =
*           I_DEFAULT                         = 'X'
*           I_SAVE                            = ' '
*           IS_VARIANT                        =
*           IT_EVENTS                         =
*           IT_EVENT_EXIT                     =
*           IS_PRINT                          =
*           IS_REPREP_ID                      =
*           I_SCREEN_START_COLUMN             = 0
*           I_SCREEN_START_LINE               = 0
*           I_SCREEN_END_COLUMN               = 0
*           I_SCREEN_END_LINE                 = 0
*           I_HTML_HEIGHT_TOP                 = 0
*           I_HTML_HEIGHT_END                 = 0
*           IT_ALV_GRAPHICS                   =
*           IT_HYPERLINK                      =
*           IT_ADD_FIELDCAT                   =
*           IT_EXCEPT_QINFO                   =
*           IR_SALV_FULLSCREEN_ADAPTER        =
*         IMPORTING
*           E_EXIT_CAUSED_BY_CALLER           =
*           ES_EXIT_CAUSED_BY_USER            =
          TABLES
            T_OUTTAB                          = lt_vbap
         EXCEPTIONS
           PROGRAM_ERROR                     = 1
           OTHERS                            = 2
                  .
        IF SY-SUBRC <> 0.
*   Implement suitable error handling here
        ENDIF.
      ENDIF.
  ENDIF.

  IF r_ucomm = '&IC1'.
    SET PARAMETER ID 'AUN' FIELD RS_SELFIELD-VALUE.
    CALL TRANSACTION 'VA03'.
  ENDIF.

ENDFORM.
