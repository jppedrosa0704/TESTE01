REPORT ZSALES_ORDER_BLOCK_ALV.          "Nome do programa

*----------------------------------------------------------------
DATA: lt_vbeln TYPE vbeln_va.           "Auxiliar para SELECT-OPTIONS
*----------------------------------------------------------------

*----------------------------------------------------------------
"Fieldcatalog para o bloco VBAK (cabeçalho)
DATA: lt_fieldcat_vbak TYPE SLIS_T_FIELDCAT_ALV,
      lwa_fieldcat_vbak TYPE slis_fieldcat_alv.

"Fieldcatalog para o bloco VBAP (itens)
DATA: lt_fieldcat_vbap TYPE SLIS_T_FIELDCAT_ALV,
      lwa_fieldcat_vbap TYPE slis_fieldcat_alv.
*----------------------------------------------------------------

*----------------------------------------------------------------
"Layout e eventos para ALV (não utilizados, mas declarados)
DATA: lwa_layout_vbak TYPE SLIS_LAYOUT_ALV.
DATA: lt_events_vbak TYPE SLIS_T_EVENT.

DATA: lwa_layout_vbap TYPE SLIS_LAYOUT_ALV.
DATA: lt_events_vbap TYPE SLIS_T_EVENT.
*----------------------------------------------------------------

*----------------------------------------------------------------
"Definição da estrutura interna para dados de cabeçalho (VBAK)
TYPES: BEGIN OF lty_vbak,
        VBELN TYPE VBELN_VA,            "Número do documento
        ERDAT TYPE ERDAT,               "Data de criação
        ERZET TYPE ERZET,               "Hora de criação
        ERNAM TYPE ERNAM,               "Usuário criador
        VBTYP TYPE VBTYP,               "Tipo de documento
       END OF lty_vbak.

"Tabelas internas para cabeçalho
DATA: lt_vbak TYPE TABLE OF lty_vbak,
      lwa_vbak TYPE lty_vbak.
*----------------------------------------------------------------

*----------------------------------------------------------------
"Definição da estrutura interna para itens (VBAP)
TYPES: BEGIN OF lty_vbab,
        VBELN TYPE VBELN_VA,            "Número do documento
        POSNR TYPE POSNR_VA,            "Número do item
        MATNR TYPE MATNR,               "Material
       END OF lty_vbab.

"Tabelas internas para itens
DATA: lt_vbap TYPE TABLE OF lty_vbab,
      lwa_vbap TYPE lty_vbab.
*----------------------------------------------------------------

*----------------------------------------------------------------
"Seleção de documentos de venda
SELECT-OPTIONS: s_vbeln FOR lt_vbeln.
*----------------------------------------------------------------

*----------------------------------------------------------------
"Busca dados de cabeçalho (VBAK)
SELECT VBELN ERDAT ERZET ERNAM VBTYP
  FROM vbak
  INTO TABLE LT_VBAK
  WHERE vbeln IN s_vbeln.

"Busca itens (VBAP) somente se houver cabeçalhos
IF lt_vbak IS NOT INITIAL.
  SELECT VBELN POSNR MATNR
    FROM vbap
    INTO TABLE lt_vbap
    FOR ALL ENTRIES IN lt_vbak
    WHERE vbeln = lt_vbak-vbeln.
ENDIF.
*----------------------------------------------------------------

*----------------------------------------------------------------
"Montagem do fieldcatalog para o bloco VBAK (cabeçalho)
lwa_fieldcat_vbak-col_pos = '1'.
lwa_fieldcat_vbak-fieldname = 'VBELN'.
lwa_fieldcat_vbak-tabname  = 'lt_vbak'.
lwa_fieldcat_vbak-seltext_l = TEXT-000. "Sales Document Number
APPEND lwa_fieldcat_vbak TO lt_fieldcat_vbak.
CLEAR lwa_fieldcat_vbak.

lwa_fieldcat_vbak-col_pos = '2'.
lwa_fieldcat_vbak-fieldname = 'ERDAT'.
lwa_fieldcat_vbak-tabname  = 'lt_vbak'.
lwa_fieldcat_vbak-seltext_l = TEXT-001. "Creation Date
APPEND lwa_fieldcat_vbak TO lt_fieldcat_vbak.
CLEAR lwa_fieldcat_vbak.

lwa_fieldcat_vbak-col_pos = '3'.
lwa_fieldcat_vbak-fieldname = 'ERZET'.
lwa_fieldcat_vbak-tabname  = 'lt_vbak'.
lwa_fieldcat_vbak-seltext_l = TEXT-002. "Time
APPEND lwa_fieldcat_vbak TO lt_fieldcat_vbak.
CLEAR lwa_fieldcat_vbak.

lwa_fieldcat_vbak-col_pos = '4'.
lwa_fieldcat_vbak-fieldname = 'ERNAM'.
lwa_fieldcat_vbak-tabname  = 'lt_vbak'.
lwa_fieldcat_vbak-seltext_l = TEXT-003. "User
APPEND lwa_fieldcat_vbak TO lt_fieldcat_vbak.
CLEAR lwa_fieldcat_vbak.

lwa_fieldcat_vbak-col_pos = '5'.
lwa_fieldcat_vbak-fieldname = 'VBTYP'.
lwa_fieldcat_vbak-tabname  = 'lt_vbak'.
lwa_fieldcat_vbak-seltext_l = TEXT-004. "Document Category
APPEND lwa_fieldcat_vbak TO lt_fieldcat_vbak.
CLEAR lwa_fieldcat_vbak.
*----------------------------------------------------------------

*----------------------------------------------------------------
"Montagem do fieldcatalog para o bloco VBAP (itens)
lwa_fieldcat_vbap-col_pos = '1'.
lwa_fieldcat_vbap-fieldname = 'VBELN'.
lwa_fieldcat_vbap-tabname  = 'lt_vbab'.
lwa_fieldcat_vbap-seltext_l = TEXT-000. "Sales Document Number
APPEND lwa_fieldcat_vbap TO lt_fieldcat_vbap.
CLEAR lwa_fieldcat_vbap.

lwa_fieldcat_vbap-col_pos = '2'.
lwa_fieldcat_vbap-fieldname = 'POSNR'.
lwa_fieldcat_vbap-tabname  = 'lt_vbab'.
lwa_fieldcat_vbap-seltext_l = TEXT-005. "Item Number
APPEND lwa_fieldcat_vbap TO lt_fieldcat_vbap.
CLEAR lwa_fieldcat_vbap.

lwa_fieldcat_vbap-col_pos = '3'.
lwa_fieldcat_vbap-fieldname = 'MATNR'.
lwa_fieldcat_vbap-tabname  = 'lt_vbab'.
lwa_fieldcat_vbap-seltext_l = TEXT-006. "Material Number
APPEND lwa_fieldcat_vbap TO lt_fieldcat_vbap.
CLEAR lwa_fieldcat_vbap.
*----------------------------------------------------------------

*----------------------------------------------------------------
"Inicializa o ALV Block List
CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_INIT'
  EXPORTING
    I_CALLBACK_PROGRAM = sy-repid.
*----------------------------------------------------------------

*----------------------------------------------------------------
"Adiciona o bloco de cabeçalho (VBAK) ao ALV
CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
  EXPORTING
    IS_LAYOUT   = lwa_layout_vbak
    IT_FIELDCAT = lt_fieldcat_vbak
    I_TABNAME   = 'lt_vbak'
    IT_EVENTS   = lt_events_vbak
  TABLES
    T_OUTTAB    = lt_vbak.
*----------------------------------------------------------------

*----------------------------------------------------------------
"Adiciona o bloco de itens (VBAP) ao ALV
CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
  EXPORTING
    IS_LAYOUT   = lwa_layout_vbap
    IT_FIELDCAT = lt_fieldcat_vbap
    I_TABNAME   = 'lt_vbap'
    IT_EVENTS   = lt_events_vbap
  TABLES
    T_OUTTAB    = lt_vbap.
*----------------------------------------------------------------

*----------------------------------------------------------------
"Exibe os blocos na tela
CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_DISPLAY'.
*----------------------------------------------------------------
