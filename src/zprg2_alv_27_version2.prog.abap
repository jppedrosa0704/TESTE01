REPORT ZPRG2_ALV_27_VERSION2.

"------------------------------------------------------------
*2) Steps to Create ALV
*
*Step-1 : Create a Field catalog.
*a) Use SAP Function Module (REUSE_ALV_FIELDCATALOG_MERGE) to create a field catalog.
*b) Manually create a Fieldcatalog.
"------------------------------------------------------------


"------------------------------------------------------------
" Estrutura para armazenar dados do cabeçalho do documento (VBAK)
"------------------------------------------------------------
TYPES: BEGIN OF lty_vbak,
        VBELN TYPE VBELN_VA,   " Número do documento de vendas
        ERDAT TYPE ERDAT,      " Data de criação
        ERZET TYPE ERZET,      " Hora de criação
        ERNAM TYPE ERNAM,      " Usuário que criou
        VBTYP TYPE VBTYP,      " Tipo de documento
       END OF lty_vbak.

" Tabela interna e work area para VBAK
DATA: LT_VBAK TYPE TABLE OF lty_vbak,
      LS_VBAK TYPE lty_vbak.

DATA: lt_fieldcat TYPE SLIS_T_FIELDCAT_ALV,
      ls_fieldcat TYPE slis_fieldcat_alv.


"------------------------------------------------------------
" Estrutura para armazenar dados dos itens do documento (VBAP)
"------------------------------------------------------------
TYPES: BEGIN OF lty_vbab,
        VBELN TYPE VBELN_VA,   " Número do documento
        POSNR TYPE POSNR_VA,   " Número do item
        MATNR TYPE MATNR,      " Código do material
       END OF lty_vbab.

" Tabela interna e work area para VBAP
DATA: LT_VBAB TYPE TABLE OF lty_vbab,
      LS_VBAB TYPE lty_vbab.

" Tabela interna e work area para TABELA_FINAL
DATA: LT_FINAL TYPE TABLE OF ZSTR_SALE_27,
      LS_FINAL TYPE ZSTR_SALE_27.

"------------------------------------------------------------
" Select-options para permitir seleção de pedidos
"------------------------------------------------------------
DATA: lv_vbeln TYPE VBELN_VA.
SELECT-OPTIONS: s_vbeln FOR lv_vbeln.

"------------------------------------------------------------
" Seleção dos dados do cabeçalho (VBAK)
"------------------------------------------------------------
SELECT VBELN ERDAT ERZET ERNAM VBTYP
  FROM VBAK
  INTO TABLE LT_VBAK
  WHERE VBELN IN s_vbeln.

"------------------------------------------------------------
" Se encontrou cabeçalhos, busca os itens correspondentes (VBAP)
" FOR ALL ENTRIES → evita SELECT dentro de LOOP
"------------------------------------------------------------
IF LT_VBAK IS NOT INITIAL.
  SELECT VBELN POSNR MATNR
    FROM VBAP
    INTO TABLE LT_VBAB
    FOR ALL ENTRIES IN LT_VBAK
    WHERE VBELN = LT_VBAK-VBELN.
ENDIF.


LOOP AT LT_VBAK INTO LS_VBAK.
  LOOP AT LT_VBAB INTO LS_VBAB WHERE VBELN = LS_VBAK-VBELN.
    LS_FINAL-VBELN = LS_VBAK-VBELN.
    LS_FINAL-ERDAT = LS_VBAK-ERDAT.
    LS_FINAL-ERZET = LS_VBAK-ERZET.
    LS_FINAL-ERNAM = LS_VBAK-ERNAM.
    LS_FINAL-VBTYP = LS_VBAK-VBTYP.
    LS_FINAL-POSNR = LS_VBAB-POSNR.
    LS_FINAL-MATNR = LS_VBAB-MATNR.
    APPEND LS_FINAL TO LT_FINAL.
    CLEAR LS_FINAL.
  ENDLOOP.
ENDLOOP.




*CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
* EXPORTING
*   I_STRUCTURE_NAME             = 'ZSTR_SALE_27'
*  CHANGING
*    CT_FIELDCAT                  = lt_fieldcat
* EXCEPTIONS
*   INCONSISTENT_INTERFACE       = 1
*   PROGRAM_ERROR                = 2
*   OTHERS                       = 3
*          .
*IF SY-SUBRC <> 0.
** Implement suitable error handling here
*ENDIF.
*
*
*LOOP AT lt_fieldcat INTO ls_fieldcat.
*  IF ls_fieldcat-fieldname = 'VBELN'.
*    ls_fieldcat-seltext_l = 'Document Number'.
*    MODIFY lt_fieldcat FROM LS_FIELDCAT TRANSPORTING seltext_l.
*  ENDIF.
*  IF ls_fieldcat-fieldname = 'ERDAT'.
*    ls_fieldcat-col_pos = 3.
*    MODIFY lt_fieldcat FROM LS_FIELDCAT TRANSPORTING col_pos.
*  ENDIF.
*  IF ls_fieldcat-fieldname = 'ERZET'.
*    ls_fieldcat-col_pos = 2.
*    MODIFY lt_fieldcat FROM LS_FIELDCAT TRANSPORTING col_pos.
*  ENDIF.
*ENDLOOP.

"------------------------------------------------------------
*Step-2 : Bind Data with Fieldcatalog
*a) REUSE_ALV_LIST_DISPLAY
*b) REUSE_ALV_GRID_DISPLAY
*c) REUSE_ALV_HIERSEQ_LIST_DISPLAY
"------------------------------------------------------------

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                = ' '
*   I_BUFFER_ACTIVE                   = ' '
*   I_CALLBACK_PROGRAM                = ' '
*   I_CALLBACK_PF_STATUS_SET          = ' '
*   I_CALLBACK_USER_COMMAND           = ' '
*   I_CALLBACK_TOP_OF_PAGE            = ' '
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
   I_STRUCTURE_NAME                  = 'ZSTR_SALE_27'
*   I_BACKGROUND_ID                   = ' '
*   I_GRID_TITLE                      =
*   I_GRID_SETTINGS                   =
*   IS_LAYOUT                         =
*   IT_FIELDCAT                       =
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
    T_OUTTAB                          = lt_final
* EXCEPTIONS
*   PROGRAM_ERROR                     = 1
*   OTHERS                            = 2
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.
