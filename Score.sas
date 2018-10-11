%let NUM=5000; /* The maximum number of rules created by the Association Node. This needs to be entered manually. */
 
data _NULL_ &EM_LIB..Rec_others; /*&EM_LIB. is the macro variable that refers to this flow; Rec is the chosen dataset name.*/
	set &EM_IMPORT_SCORE.; /* &EM_IMPORT_SCORE is the macro variable that refers to incoming Score data. */
	length RULE_LABEL $200; /* Sets the maximum number of characters alloted to the rule label */
	array rule_array(*) RULE1-RULE&NUM. ; /* Collects all the rules into an array so that they can be iterated over */
	do i=1 to dim(rule_array);
		if rule_array(i) = 1 then do;
			RULE_ID = cats("RULE",i);		
			call label(rule_array(i),RULE_LABEL); /* Extracts the label from the rule so that the label can be displayed */
			keep LAST_SUSG_REF RULE_ID RULE_LABEL; output &EM_LIB..Rec_others;
		end;
	end;
run;
proc print data=&EM_LIB..Rec_others; /* Prints out the results */
run;
 