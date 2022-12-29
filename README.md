# ABAP
## Useful ABAP code sinpets
###### Get value from another program using assign field symbol
```
ASSIGN ('(SAPLCOKO1)AFVGD[]') TO <FS_AFVGD>.
```
###### correct Timezone for particular Warehouse
```
  CALL FUNCTION '/SCWM/LGNUM_TZONE_READ'
    EXPORTING
      iv_lgnum        = m_lgnum
    IMPORTING
      ev_tzone        = lv_timezone
    EXCEPTIONS
      interface_error = 1
      data_not_found  = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

* Get timestamp
  GET TIME STAMP FIELD ls_item_wa-count_date.

  CONVERT TIME STAMP ls_item_wa-count_date TIME ZONE lv_timezone
           INTO DATE lv_act_date
                TIME lv_act_time.

  CONVERT DATE lv_act_date TIME lv_act_time
               INTO TIME STAMP ls_item_wa-count_date TIME ZONE lv_timezone.
```
