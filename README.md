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
###### Get serials for particular  matid in warehouse
```
 try.
    /scwm/cl_serial=>get_serial(
      exporting
        iv_lgnum = p_lgnum
        iv_matid = <fs_item>-data-stock_item-matid
      importing
        ev_stock = lv_ser_stock ).
  catch /scwm/cx_serial.
    clear lv_ser_stock.
endtry.
```
###### Timestamp helper class
```
CL_ABAP_TIMESTAMP_UTIL
    TSTMP_SECONDS_BETWEEN
    TSTMPL_SECONDS_BETWEEN
    TSTMP_ADD_SECONDS
    TSTMPL_ADD_SECONDS
    GET_USER_TIME_ZONE_STRING
```
###### Read outbound delivery using Service Provider
```
DATA(lo_dlv) = NEW /scdl/cl_sp_fd_out(
  iv_mode              = /scdl/cl_sp=>sc_mode_classic
  iv_enable_extensions = abap_true
  iv_doccat            = /scdl/if_dl_doc_c=>sc_doccat_out_prd
).

DATA: lt_inkeys TYPE /scdl/t_sp_k_head_partyloc,
      lt_outrecords type /scdl/t_sp_a_head_partyloc.

lt_inkeys = value #( ( docid = '[.....]' ) ).

lo_dlv->select(
    EXPORTING aspect = /scdl/if_sp_c=>sc_asp_head_partyloc
              inkeys = lt_inkeys
    IMPORTING outrecords = lt_outrecords
).
```
## RFUI
###### Debugging
by pressing CTRL+Shift+F1 within the RF Screen
set a breakpoint in method CALL_FLOW_PROCESS (class /SCWM/CL_RF_BLL_SRVC) to find the function module.

## Database tables 
###### for deliveries

|Database Table|Description|
|-----|------------|
|/SCDL/DB_PROCH_I|Inbound Delivery Header|
|/SCDL/DB_PROCI_I|Inbound Delivery Item|
|/SCDL/DB_PROCH_O|Outbound Delivery Order Header|
|/SCDL/DB_PROCI_O|Outbound Delivery Order Item|
|/SCDL/DB_DLVH_O|Outbound Delivery Header|
|/SCDL/DB_DLVI_O|Outbound Delivery Item|

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
###### Operational TCoded
|TCode|Description|
|-----|------------|
|`SIMGH`|IMG Structure Maintenance |

## T&T
###### (Un)release task
Step 1: Go to SE38-> enter program name : RDDIT076 -> execute
Step 2: Enter TR/Task which status you want to convert from released to modifiable -> execute program
Step 3: you will find TR with R (Released) status.

###### Compare objects
SE39
SREPO
SCMP
SCU0
CCAPPS
