*-------------------------------------------------------------------------------------------------------*
|                              SAS | U.S. Academic Programs | Asset Creation                   	        |
|                        01 - AirLincoln Data Simulation - Scoring Data - 07.30.2021                    |
*-------------------------------------------------------------------------------------------------------*;
libname 	air "C:\Users\ligrov\OneDrive - SAS\SAS Engagements\Embry Riddle\SAS Data";
options 	orientation=landscape mlogic symbolgen pageno=1 error=3;

title1 		"SAS | U.S. Academic Programs | Asset Creation";
title2 		"Simulate AirLincoln Data for Predictive Modeling Exercise";
footnote 	"File = 01 - AirLincoln Data Simulation - Scoring Data - 07.30.2021";


*-------------------------------------------------------------------------------------*
|                             Import Data Structure from Excel                        |
*-------------------------------------------------------------------------------------*;
filename REF1 "C:\Users\ligrov\OneDrive - SAS\SAS Engagements\Embry Riddle\Predicting Airline Passenger No Show Rates.xlsx";

proc import datafile=REF1
	dbms=xlsx replace
	out=link1;
	getnames=yes;
run;


*-------------------------------------------------------------------------------------*
|                		       Begin Data Simulation                			      |
*-------------------------------------------------------------------------------------*;
data AirLincolnData_Score;
	set link1 ;

	where Customer_ID <= 1000 ;		*******************  Limit to 1000 cases ;


**************************************** Set the Seed to Allow Replication ;
	call streaminit(27613);

**************************************** Assign Distributions ;
	array dd_prob1[7] (.20 .12 .12 .15 .15 .12 .14) ;
	array dd_prob2[7] (.14 .14 .14 .14 .14 .16 .14) ;

	array dh_prob1[3] (.45 .1 .45) ;
	array dh_prob2[3] (.30 .4 .30) ;

	array bc_prob1[3] (.15 .25 .60) ;
	array bc_prob2[3] (.01 .20 .79) ;

	array tp_prob1[3] (.15 .25 .60) ;
	array tp_prob2[3] (.01 .20 .79) ;

	array ag_prob1[4] (.10 .45 .35 .10) ;
	array ag_prob2[4] (.20 .35 .25 .20) ;


**************************************** No-Show target missing = ~10% ;
	if customer_id <= 100 and 	no_show = . then No_Show = 1 ;
	if 							no_show = . then No_Show = 0 ;


****************************  Conditional Value Assignment ; 
****************************  Premise ==> use two different conditional probability distributions to separate shows from no_shows ;
****************************  Goal: business travlers more likely to miss flights ;


	if No_Show = 1 and _n_>2 then do ;

*****************************************  Binary Variables ;
		if rand("Uniform")>.40 	then 	major_hub_departure = 1 ;
								else 	major_hub_departure = 0 ;

		if rand("Uniform")>.45	then 	Connections = 1 ;
								else 	Connections = 0 ;
		
		if rand("Uniform")>.90	then 	International_Flight = 1 ;
								else 	International_Flight = 0 ;


		if rand("Uniform")>.75	then 	Business_Traveler = 1 ;
								else 	Business_Traveler = 0 ;

		if rand("Uniform")>.60	then 	Gender___Female = 1 ;
								else 	Gender___Female = 0 ;

		if rand("Uniform")>.8	then 	Frequent_Flier_Status = 1 ;
								else 	Frequent_Flier_Status = 0 ;

		if rand("Uniform")>.5	then 	Weather_Issues = 1 ;
								else 	Weather_Issues = 0 ;


*****************************************  Categorical Variables ;
		departure_day 			= rand("Table", of dd_prob1[*]);
		departure_hour 			= rand("Table", of dh_prob1[*]);
		booking_class			= rand("Table", of bc_prob1[*]);
		when_ticket_purchased	= rand("Table", of tp_prob1[*]);
		age						= rand("Table", of ag_prob1[*]);


*****************************************  Interactions ;
		Connection___International_Fligh 	= Connections * International_Flight ;
		Weather_Issues___Connection 		= Weather_Issues * Connections ;

	end;
		

	if No_Show = 0 and _n_>2 then do ;

*****************************************  Binary Variables ;
		if rand("Uniform")>.60 	then 	major_hub_departure = 1 ;
								else 	major_hub_departure = 0 ;

		if rand("Uniform")>.80	then 	Connections = 1 ;
								else 	Connections = 0 ;

		if rand("Uniform")>.98	then 	International_Flight = 1 ;
								else 	International_Flight = 0 ;

		if rand("Uniform")>.92	then 	Business_Traveler = 1 ;
								else 	Business_Traveler = 0 ;

		if rand("Uniform")>.50	then 	Gender___Female = 1 ;
								else 	Gender___Female = 0 ;


		if rand("Uniform")>.95	then 	Frequent_Flier_Status = 1 ;
								else 	Frequent_Flier_Status = 0 ;

		if rand("Uniform")>.90	then 	Weather_Issues = 1 ;
								else 	Weather_Issues = 0 ;


*****************************************  Categorical Variables ;
		departure_day 			= rand("Table", of dd_prob2[*]);
		departure_hour 			= rand("Table", of dh_prob2[*]);
		booking_class			= rand("Table", of bc_prob2[*]);
		when_ticket_purchased	= rand("Table", of tp_prob2[*]);
		age						= rand("Table", of ag_prob2[*]);
		

*****************************************  Interactions ;
		Connection___International_Fligh 	= Connections * International_Flight ;
		Weather_Issues___Connection 		= Weather_Issues * Connections ;

	end;


*****************************************  Drop Irrelevant Data ;
	drop dd_prob11 -- ag_prob24;


*****************************************  Partition ID for Honest Assessment ;
	if rand("Uniform")>.40 		then 	Partition_ID = 1 ;
								else 	Partition_ID = 0 ;
run;


*------------------------------------------------------------*
|				Set No_Show = ., so we can score it			 |
*------------------------------------------------------------*;
data air.AirLincolnData_Score;
	set AirLincolnData_Score ;

	No_Show = . ;
run;
