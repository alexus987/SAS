*------------------------------------------------------------*;
* Data Source Setup;
*------------------------------------------------------------*;
*------------------------------------------------------------*;
* Setup Code for Data Source id = ajalugusamsung - name = AJALUGU_TAHVLID;
*------------------------------------------------------------*;
LIBNAME ALEXEY BASE "\\SASETL\Data2\Alexey";
LIBNAME EMWS1 "N:\SAS94_PROD\Data\Eminer\Mob_soovitus\Workspaces\EMWS1";

*------------------------------------------------------------*;
* Ids5: Creating DATA data;
*------------------------------------------------------------*;
data EMWS1.Ids5_DATA (label="")
;
set ALEXEY.MOB_MUDELITE_AJALUGU_TAHVLID;
drop EQUIPMENT_IMEI_CODE;
drop SOCIAL_SECURITY_ID;
run;




*------------------------------------------------------------*;
* Assoc5: Sorting Training Data;
*------------------------------------------------------------*;
proc sort data=EMWS1.Ids5_DATA(keep=EQUIP_FIRST_CALL_DATE MODEL LAST_SUSG_REF) out=WORK.SORTEDTRAIN;
by LAST_SUSG_REF EQUIP_FIRST_CALL_DATE;
run;
*------------------------------------------------------------* ;
* EM: DMDBClass Macro ;
*------------------------------------------------------------* ;
%macro DMDBClass;
    MODEL(DESC)
%mend DMDBClass;
*------------------------------------------------------------* ;
* EM: DMDBVar Macro ;
*------------------------------------------------------------* ;
%macro DMDBVar;
    EQUIP_FIRST_CALL_DATE
%mend DMDBVar;
*------------------------------------------------------------*;
* EM: Create DMDB;
*------------------------------------------------------------*;
proc dmdb batch data=WORK.SORTEDTRAIN
dmdbcat=WORK.EM_DMDB
maxlevel = 100001
normlen= 256
out=WORK.EM_DMDB;
id LAST_SUSG_REF;
class %DMDBClass;
var %DMDBVar;
target MODEL;
run;
quit;
options nocleanup;

proc assoc dmdb dmdbcat=WORK.EM_DMDB out=EMWS1.Assoc5_ASSOC data=WORK.EM_DMDB
pctsup = 0.1
items=2
;
customer LAST_SUSG_REF;
target MODEL;
run;
quit;

proc sequence data=WORK.EM_DMDB dmdbcat=WORK.EM_DMDB assoc=EMWS1.Assoc5_ASSOC out=EMWS1.Assoc5_SEQUENCE nitems = 2
pctsup = 0.1;
customer LAST_SUSG_REF;
target MODEL;
visit EQUIP_FIRST_CALL_DATE;
run;
quit;
*------------------------------------------------------------*;
* Assoc5: Selecting rules;
*------------------------------------------------------------*;
proc sort data=EMWS1.Assoc5_SEQUENCE;
by descending SUPPORT;
run;
data WORK.ASSOCSUBSET;
set EMWS1.Assoc5_SEQUENCE(obs=174);
index=_N_;
label index = "%sysfunc(sasmsg(sashelp.dmine, rpt_ruleIndex_vlabel,  NOQUOTE))";
label _LHAND = "%sysfunc(sasmsg(sashelp.dmine, rpt_leftHandSide_vlabel,  NOQUOTE))";
label _RHAND = "%sysfunc(sasmsg(sashelp.dmine, rpt_rightHandSide_vlabel,  NOQUOTE))";
run;
