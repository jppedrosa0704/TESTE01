REPORT ZPRG3_ALV_27_TOP_OF_PAGE.

"------------------------------------------------------------
*2) Steps to Create ALV
*
*Step-1 : Create a Field catalog.
*a) Use SAP Function Module (REUSE_ALV_FIELDCATALOG_MERGE) to create a field catalog.
*b) Manually create a Fieldcatalog.
"------------------------------------------------------------

DATA: lt_list TYPE SLIS_T_LISTHEADER,
      ls_list TYPE slis_listheader.

DATA: lv_input TYPE string.
DATA: lv_lines(5) TYPE C.

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


DATA: lt_fieldcat TYPE SLIS_T_FIELDCAT_ALV.
DATA: ls_fieldcat TYPE slis_fieldcat_alv.

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

ls_fieldcat-COL_POS = '1'.
ls_fieldcat-FIELDNAME = 'VBELN'.
ls_fieldcat-TABNAME = 'lt_final'.
ls_fieldcat-seltext_l = 'Seles Document Number'.
APPEND ls_fieldcat TO lt_fieldcat.
clear ls_fieldcat.

ls_fieldcat-COL_POS = '2'.
ls_fieldcat-FIELDNAME = 'ERDAT'.
ls_fieldcat-TABNAME = 'lt_final'.
ls_fieldcat-seltext_l = 'Creation Date'.
APPEND ls_fieldcat TO lt_fieldcat.
clear ls_fieldcat.

ls_fieldcat-COL_POS = '3'.
ls_fieldcat-FIELDNAME = 'ERZET'.
ls_fieldcat-TABNAME = 'lt_final'.
ls_fieldcat-seltext_l = 'time'.
APPEND ls_fieldcat TO lt_fieldcat.
clear ls_fieldcat.

ls_fieldcat-COL_POS = '4'.
ls_fieldcat-FIELDNAME = 'ERNAM'.
ls_fieldcat-TABNAME = 'lt_final'.
ls_fieldcat-seltext_l = 'Name'.
APPEND ls_fieldcat TO lt_fieldcat.
clear ls_fieldcat.

ls_fieldcat-COL_POS = '5'.
ls_fieldcat-FIELDNAME = 'VBTYP'.
ls_fieldcat-TABNAME = 'lt_final'.
ls_fieldcat-seltext_l = 'Type of Document'.
APPEND ls_fieldcat TO lt_fieldcat.
clear ls_fieldcat.

ls_fieldcat-COL_POS = '6'.
ls_fieldcat-FIELDNAME = 'POSNR'.
ls_fieldcat-TABNAME = 'lt_final'.
ls_fieldcat-seltext_l = 'Number of Type'.
APPEND ls_fieldcat TO lt_fieldcat.
clear ls_fieldcat.

ls_fieldcat-COL_POS = '7'.
ls_fieldcat-FIELDNAME = 'MATNR'.
ls_fieldcat-TABNAME = 'lt_final'.
ls_fieldcat-seltext_l = 'Material Code'.
APPEND ls_fieldcat TO lt_fieldcat.
clear ls_fieldcat.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
   I_CALLBACK_PROGRAM                = sy-repid
   I_CALLBACK_TOP_OF_PAGE            = 'TOP_PAGE'
   IT_FIELDCAT                       = LT_FIELDCAT


  TABLES
    T_OUTTAB                         = LT_FINAL
 EXCEPTIONS
   PROGRAM_ERROR                     = 1
   OTHERS                            = 2
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

FORM TOP_PAGE.
  ls_list-typ = 'H'.
  ls_list-info = 'Sales Order Display'.
  APPEND ls_list TO lt_list.
  CLEAR ls_list.

  CONCATENATE s_vbeln-low 'TO' s_vbeln-high INTO lv_input SEPARATED BY space.

  ls_list-typ = 'S'.
  ls_list-key = 'Sales Input'.
  ls_list-info = lv_input.
  APPEND ls_list TO lt_list.
  CLEAR ls_list.


  DESCRIBE TABLE lt_final LINES lv_lines.
  CONCATENATE 'The Number of Lines' lv_lines INTO lv_input SEPARATED BY space.

  ls_list-typ = 'A'.
  ls_list-info = lv_input.
  APPEND ls_list TO lt_list.
  CLEAR ls_list.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY       = lt_list.
*     I_LOGO                   =
*     I_END_OF_LIST_GRID       =
*     I_ALV_FORM               =
            .

ENDFORM.
