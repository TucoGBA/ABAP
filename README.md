# SAP - EWM

## Useful ABAP code sinpets
###### Get value from another program using assign field symbol
```
ASSIGN ('(SAPLCOKO1)AFVGD[]') TO <FS_AFVGD>.
```
###### Fast way to get rid off leading zeros

`WRITE is_doc_ref-doc_number TO lv_doc_number NO-ZERO.`

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
## TCodes
###### Physical Inventory
|TCode|Description|
|-----|------------|
|`/SCWM/PI_COMPL_DEL`|Delete Completeness Data Sets|
|`/SCWM/PI_COUNT`|Enter Physical Inventory Count|
|`/SCWM/PI_COUNTLIST`|	Create Phys. Inventory Count in List|
|`/SCWM/PI_CREATE`|Create Physical Inventory Document|
|`/SCWM/PI_DOC_CREATE`|	Create Physical Inventory Document|
|`/SCWM/PI_DOWNLOAD`|Download Storage Bins and Count Data|
|`/SCWM/PI_PROCESS`|Process Physical Inventory Document|
|`/SCWM/PI_SAMP_CR`|Upload Sample to Create PI Documents|
|`/SCWM/PI_SAMP_STOCK`|Download Stock Population|
|`/SCWM/PI_SAMP_UPDATE`|Download Results or Stock Population|
|`/SCWM/PI_UPLOAD`|Upload Storage Bins and Count Data|
|`/SCWM/PI_USER`|User Maint. Tolerance Gr. Phys.Inv.|
|`/SCWM/PI_USER_DIFF`|Assign Users to Tol. Group for Diff.|
|`/SCWM/PIDO`|Number Range Maintenance: /SCWM/PIDO|
