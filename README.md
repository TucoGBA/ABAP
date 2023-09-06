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
###### Read GUID for given entitled
```
CALL FUNCTION 'BUPA_NUMBERS_GET'
  EXPORTING
    iv_partner      = iv_bp_id
  IMPORTING
    ev_partner_guid = ev_bp_guid.
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

## Fiori
###### Cache Management in SAP Fiori
There are different Layers that handle caching:

The browser itself HTTP caching
Your frontend server (ICM) - If you take a look at transaction SMICM you can see for example that views/controllers of an UI5 Application are getting stored with an validity period
Backend Server (only Metadata Caching of your services/service definition)
Good blog post about Cache Management in SAP Fiori

Solutions:
When deploying your UI5 App via WEBIDE the app_index get's calculated. Sometimes this fails. So inbefore saying Test now! run the report /UI5/APP_INDEX_CALCULATE for your specific SAPUI5 application in your frontend server.
If your OData service changed run the transaction /IWFND/CACHE_CLEANUP in your frontend server and the transaction /IWBEP/CACHE_CLEANUP in the backend server.
For myself in developement and quality management system i sometimes run the report /UI2/INVALIDATE_CLIENT_CACHES if changed translations SE63 doesn't show up.
So in developement & quality management system just run /UI5/APP_INDEX_CALCULATE and /UI2/INVALIDATE_CLIENT_CACHES and you should be good to go.

In Production take care, caching is all about performance, so if you clear all caches and your company has like 500 users opening Fiori Launchpad at 08:00 am things can get messy.
Source: https://stackoverflow.com/questions/65904453/sapui5-application-is-not-updated-immediately-from-sap-netweaver

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

Main Tables
FUNCTION	TABLE	DESCRIPTION
STOCK
	/SCWM/AQUA	Available stock for warehouse task creation
 	/SCWM/QUAN	Physical stock attributes
 	/LIME/NQUAN	Physical stock
 	/SCWM/STOCK_IW01	

Normal stock
 	/SCWM/STOCK_IW02	Batch managed stock
 	/SCWM/STOCK_IW03	Reference stock (PDI, PDO)
 	/SCWM/STOCK_IW04	Special stock
 	 	 
WAREHOUSE TASK (WT)
	/SCWM/ORDIM_C	Warehouse tasks confirmed
 	/SCWM/ORDIM_CS	Serial number for confirmed warehouse task item
 	/SCWM/ORDIM_E	Exception codes for warehouse task
 	/SCWM/ORDIM_H	Warehouse task: Movements of HU items
 	/SCWM/ORDIM_HS	Serial numbers for HU item movements
 	/SCWM/ORDIM_L	Warehouse tasks log table
 	/SCWM/ORDIM_LS	Serial numbers for warehouse task log table
 	/SCWM/ORDIM_O	Warehouse tasks opened
 	 	 
TRANSPORTATION UNIT (TU)
	/SCWM/TU_DLV	Assignment of Deliveries and HUs to Transportation Units
 	/SCWM/TU_DOOR	Relationship between TU activities and door activities
 	/SCWM/TUNIT	Data for the TU itself
 	/SCWM/TU_SR_ACT	Contains start date/times and end dates/times
 	/SCWM/TU_STATUS	Status of the TU activities
 	/SCWM/TU_VEH	Contains one or more vehicle activities with which a TU activity can be linked
 	/SCWM/DOOR_SRACT	S&R Activities of a Door
 	 	 
WAVE
	/SCWM/WAVEHDR	Wave header information
 	/SCWM/WAVEITM	Wave item
 	 	 
OUTBOUND DELIVERY	
	/SCDL/DB_DLVH_O	Outbound Delivery Header
 	/SCDL/DB_DLVI_O	Outbound Delivery Item
 	
/SCDL/DB_PROCH_O

Outbound Delivery Order Header
 	/SCDL/DB_PROCI_O	Outbound Delivery Order Item
 	 	 
INBOUND DELIVERY	
	/SCDL/DB_PROCH_I	Inbound Delivery Header
 	/SCDL/DB_PROCI_I	Inbound Delivery Item
 	 	 
REFERENCE	
	/SCDL/DB_REFDOC	Reference
 	/SCDL/DB_REQH	Header Inbound Delivery Notification / Outbound Delivery Request
 	/SCDL/DB_REQI	Item Inbound Delivery Notification / Outbound Delivery Request
 	 	 
HANDLING UNIT (HU)	
	/SCWM/HUHDR	Handling unit header
 	/SCWM/GMHUIDENT	Additional HU Identifications for a Goods Movement Log
 	/SCWM/HUSSTAT	Individual status for each handling unit
 	/SCWM/HUREF	Handling unit reference
 	/SCWM/HUSTOBJ	Information about handling unit status object
 	/SCWM/GMHUSTAT	HU Status of HUs from Goods Movement Log
 	/SCWM/GMHUITM	Handling Unit Item
 	/SCWM/GMHUHDR	Goods Movement Handling Unit Header Reading details in a HU
 
STORAGE BINS	
	/SCWM/LAGP	Storage Bins
 	/SCWM/LAGPS	Bins for execution areas and activities
 	 	 
MASTER DATA	
	/SAPAPO/MATKEY	Product
 	/SAPAPO/MATMAP	Mapping table for products
 	/SAPAPO/MATEXEC	Product execution data
 	/SAPAPO/MATTXT	Material Descriptions
 	/SAPAPO/MATLWHST	Location product for Location Warehouse and sub location storage type
 	/SAPAPO/MATLWH	Location product for Location Warehouse
 
/SCWM/DOOR_SRACT

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

## Files and catalogues
###### Acces SAP system console
Step 1: Go to SE38-> enter program name : RSBDCOS0 -> execute
###### Browse SAP system files and directories
T-Code: AL11

###### Compare objects
*Tcodes*:
1. SE39
1. SREPO
1. SCMP
1. SCU0
1. CCAPPS
*Reports*:
1. RSYSCOMP
