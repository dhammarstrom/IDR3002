/*
Update1: Body composition changes presented in Figure 3D are adjusted for 14 days because the body compositions were not measured exactly 14 days apart.
In the previous version of SAS code and data, such adjustment was not provided. Here we have updated the SAS code at the section "data for figure 3D" and added a dataset "DeltaBCadj14"; 
*/
%let path = C:\Users\guojuen\Documents\ADL\Manuscript\documentation;

/*table 1  
and baseline BMI =BMI=27±1.5*/
data demo1; set "&path\baseline.sas7bdat"; run; 
proc means data=Demo1 n mean stderr ;
*class Sex;
var age height bw FM FatContent bmi REE;
run;

/*Table 3 chamber part*/
data Chamber; set "&path\Chamber.sas7bdat"; 
if Visit = 'Day03' then VisitWithinDiet = 'Day01'; else if Visit = 'Day04' then VisitWithinDiet = 'Day02'; else VisitWithinDiet = Visit;
run;
ods exclude all;
proc glm data=Chamber;
class subID Diet;
model Intake FQ TotalEE TotalRQ  SMR   EEsedentary SPA  = subID Diet;
lsmeans diet /stderr pdiff;
estimate 'Proc vs Unproc' diet 1 -1;
ods output lsmeans=tem; 
ods output Estimates=tem2;
*where VisitWithinDiet = 'Day01';  /*only the first week*/
*where VisitWithinDiet = 'Day02';  /*only the second week*/
quit;
ods exclude none;
data tem; set tem;
if Dependent in ("SMR", "EEsedentary",  "SPA") then do;
LSMean = 1440*LSMEan;
StdErr = 1440*StdErr;
end;
run;
proc print data=tem; run;
proc print data=tem2; run;

/*Table 3 DLW part*/
data DLW; set "&path\DLW.sas7bdat"; 
DLW_ChamberEE = DLWEEadjEB - ChamberEE; 
EI_DLW = AveEI - DLWEEadjEB;
run;            /*DLW calculation for the whole two week period*/
data DLW; set "&path\DLWwkOne.sas7bdat"; run;    /*DLW calculation for the first week period*/
data DLW; set "&path\DLWwkTwo.sas7bdat"; run;    /*DLW calculation for the secon week period*/
ods select none;
proc glm data=DLW;
class subID Diet;
model AveEI FQ RQrevised rCO2 DLWEEadjEB   = subID Diet;
lsmeans diet/stderr pdiff;
estimate 'Ultra vs Unproce' Diet 1 -1;
ods output LSmeans = tem1;
ods output Estimates = tem;
run;
ods select all;
proc print data=tem1 ; run;
proc print data=tem ; run;
proc means data=DLW n mean stderr probt;
class diet;
var DLW_ChamberEE EI_DLW; 
run;

/*Table 3 accelerometry part*/
Data PA ; set "&path\Accelerometry.sas7bdat"; run;
ods select none;
proc glm data=PA;
class subID diet;
model  AvgDailyMET  = subID diet;
lsmeans diet/pdiff stderr;
ods output LSmeans = tem;
*where also DaysOnDiet between 1 and 7;  /*only first week*/
where also DaysOnDiet between 8 and 14; /*only second week*/
run;
ods select all;
proc print data=tem; run;
/* Table 4 part one*/
%include "&path\FilterBloodMeasures.sas";
Data BloodPartOne; set "&path\BloodPartOne"; run;
proc sort data=BloodPartOne; by flag; run;
ods select none;
proc glm data=BloodPartOne;
class subjectID diet;
model ObservedValue = subjectID diet;
estimate 'Process vs Unprocess' diet 0 1 -1;
estimate 'Process vs BaseLine' diet -1 1 0;
estimate 'Unprocess vs BaseLine' diet -1 0 1;
lsmeans diet /stderr;
ods output estimates=tem; 
ods output lsmeans=tem2;
by flag;
run;
ods select all;
proc sql;
create table Results as 
select put (flag, filterRev.) as Name, LSMean as BaseLineMean, StdErr as BaseLineSE,
(select LSMean from tem2 inside where inside.flag=outside.flag and diet='Processe') as ProcessedMean,
(select StdErr from tem2 inside where inside.flag=outside.flag and diet='Processe') as ProcessedSE,
(select LSMean from tem2 inside where inside.flag=outside.flag and diet='Unproces') as UnProcessedMean,
(select StdErr from tem2 inside where inside.flag=outside.flag and diet='Unproces') as UnProcessedSE,
(select Estimate from tem where tem.flag=outside.flag and tem.Parameter= 'Process vs Unprocess') as ProVsUnpro,
(select StdErr from tem where tem.flag=outside.flag and tem.Parameter= 'Process vs Unprocess') as ProVsUnproSE format= 5.3,
(select Probt from tem where tem.flag=outside.flag and tem.Parameter= 'Process vs Unprocess') as ProVsUnpro_Pvalue,
(select Estimate from tem where tem.flag=outside.flag and tem.Parameter= 'Process vs BaseLine') as ProVsBaseLine,
(select StdErr from tem where tem.flag=outside.flag and tem.Parameter= 'Process vs BaseLine') as ProVsBaseLineSE format= 5.3,
(select Probt from tem where tem.flag=outside.flag and tem.Parameter= 'Process vs BaseLine') as ProVsBaseLine_Pvalue,
(select Estimate from tem where tem.flag=outside.flag and tem.Parameter= 'Unprocess vs BaseLine') as UnProcessVsBaseLine,
(select StdErr from tem where tem.flag=outside.flag and tem.Parameter= 'Unprocess vs BaseLine') as UnProcessVsBaseLineSE format= 5.3,
(select Probt from tem where tem.flag=outside.flag and tem.Parameter= 'Unprocess vs BaseLine') as UnProcessVsBaseLine_Pvalue
from tem2 outside where diet ='BaseLine';
quit;
proc print data=results; run;

/* Table 4 part two*/
Data BloodPartTwo; set "&path\BloodPartTwo"; run;
ods select none;
proc glm data=BloodPartTwo;
class subjectID diet;
model  Adiponectin TotalGIP activeGIP FGF21 ActiveGhrelin Leptin PYY Resistin PAI1 ActiveGLP1 Glucagon= subjectID diet;
estimate 'Process vs Unprocess' diet 0 1 -1;
estimate 'Process vs BaseLine' diet -1 1 0;
estimate 'Unprocess vs BaseLine' diet -1 0 1;
lsmeans diet /stderr;
ods output estimates=tem; 
ods output lsmeans=tem2;
run;
ods select all;
proc sql;
create table Results as 
select Dependent, LSMean as BaseLineMean, StdErr as BaseLineSE,
(select LSMean from tem2 inside where inside.Dependent=outside.Dependent and diet='Processe') as ProcessedMean,
(select StdErr from tem2 inside where inside.Dependent=outside.Dependent and diet='Processe') as ProcessedSE,
(select LSMean from tem2 inside where inside.Dependent=outside.Dependent and diet='Unproces') as UnProcessedMean,
(select StdErr from tem2 inside where inside.Dependent=outside.Dependent and diet='Unproces') as UnProcessedSE,
(select Estimate from tem where tem.Dependent=outside.Dependent and tem.Parameter= 'Process vs Unprocess') as ProVsUnpro,
(select StdErr from tem where tem.Dependent=outside.Dependent and tem.Parameter= 'Process vs Unprocess') as ProVsUnproSE format= 5.3,
(select Probt from tem where tem.Dependent=outside.Dependent and tem.Parameter= 'Process vs Unprocess') as ProVsUnpro_Pvalue,
(select Estimate from tem where tem.Dependent=outside.Dependent and tem.Parameter= 'Process vs BaseLine') as ProVsBaseLine,
(select StdErr from tem where tem.Dependent=outside.Dependent and tem.Parameter= 'Process vs BaseLine') as ProVsBaseLineSE format= 5.3,
(select Probt from tem where tem.Dependent=outside.Dependent and tem.Parameter= 'Process vs BaseLine') as ProVsBaseLine_Pvalue,
(select Estimate from tem where tem.Dependent=outside.Dependent and tem.Parameter= 'Unprocess vs BaseLine') as UnProcessVsBaseLine,
(select StdErr from tem where tem.Dependent=outside.Dependent and tem.Parameter= 'Unprocess vs BaseLine') as UnProcessVsBaseLineSE format= 5.3,
(select Probt from tem where tem.Dependent=outside.Dependent and tem.Parameter= 'Unprocess vs BaseLine') as UnProcessVsBaseLine_Pvalue
from tem2 outside where diet ='BaseLine';
quit;
proc print data=Results; run;
/* Matsudo data*/
data OGTTIndex ; set "&path\OGTTIndex "; run;
ods graphics off;
proc glm data=OGTTIndex;
class Study_ID Diet;
model Matsuda = study_ID Diet;
lsmeans diet/stderr pdiff;
quit;

/*Daily intake comparisons*/
data four; set "&path\DailyIntake"; run;
proc sql;
create table five as select distinct  StudyID, Period, DietOrder, Gender, mean(water) as AveWater, 
mean(Mass) as AveMass, mean(EI) as AveEI, mean(EI/Mass) as EnergyDensity, mean(EI/(Mass-EDWater)) as EDexWater,
mean(CHO_Kcal/EI) as CarbPerc, mean(fat_Kcal/EI) as FatPerc, mean(Protein_Kcal/EI) as ProtPerc,
mean(0.994*CHO_Kcal/EI + 0.694*fat_Kcal/EI + 0.828*Protein_Kcal/EI) as FQ,
mean(CHO_Kcal) as Carb, mean(fat_Kcal) as Fat, mean(Protein_Kcal) as Prot,
mean(Sugars) as AveSugars, mean(Fiber) as AveFiber, mean(Sodium) as AveSodium
from four group by StudyID, Period;
create table five1 as select distinct StudyID, Period,  mean(EI) as AveEI from four  where day between 22 and 28 or day between 7 and 14  group by StudyID, Period;
create table six as select distinct  StudyID,  Gender, DietOrder,
AveEI - (select aveEI from five inside where inside.studyID=outside.StudyID and period='UNPROC') as deltaEI,
(select BMI from Demo1 where Demo1.subjectID = outside.studyID ) as BMI
from five outside where period='PROC';
quit;

ods select none;
proc glm data=five;
class StudyID period ;
model AveEI Carb Prot Fat  AveSugars AveFiber AveSodium = StudyID period ;
lsmeans Period/stderr pdiff;
estimate 'Proc Vs Unproc' period 1 -1; 
ods output Estimates=tem;
ods output LSmeans=tem1;
run;
ods select all;
proc print data=tem;  run;
proc print data=tem1;  run;
/* figure 2A */
proc sgplot data=four noborder;
vline DaysOnDiet/ response = EI stat=mean limitstat=stderr numstd=1 group=period LIMITATTRS =(thickness=2) LineAttrs=(thickness=2 pattern= solid);
xaxis label='Time, day' Labelattrs=(size=15 weight=bold)  Valueattrs=(size=15 weight=bold);
yaxis label='Energy Intake, kcal/d' Labelattrs=(size=15 weight=bold)  Valueattrs=(size=15 weight=bold);
quit;
/*data for figure 2B*/
proc means data=five n mean stderr;
class period;
var Carb Prot Fat; 
run;

/*correlation between baseline BMI and delta EI*/
proc corr data=six; var DeltaEI BMI; run;

/*compare EI during the final week of each diet*/
ods graphics off;
proc glm data=five1;
class StudyID period ;
model AveEI = StudyID period ;
lsmeans Period/stderr pdiff;
estimate 'Proc Vs Unproc' period 1 -1; 
run;
ods graphics on;
/*Diet order effect and sex effect*/
ods graphics off;
proc glm data=six;
class  DietOrder Gender;
model deltaEI = DietOrder Gender;
quit;
ods graphics on;
/*Intake trend over the two week period*/
ods graphics off;
proc glm data=four;
class studyID Period;
model EI = studyID Period DaysOnDiet DaysOnDiet*Period;
estimate 'slope of Unprocessed' DaysOnDiet 1 DaysOnDiet*Period 0 1;
estimate 'slope of Processed' DaysOnDiet 1 DaysOnDiet*Period 1 0 ;
estimate 'diff in slope' DaysOnDiet*Period 1 -1 ;
quit;
ods graphics on;


data Meals; set "&path\IntakeByMeal"; run;
proc sql;
create table Meal1 as select distinct  StudyID, Period,  meal,  mean(water) as AveWater, 
mean(Mass) as AveMass, mean(EI) as AveEI, mean(EI/Mass) as EnergyDensity,
mean(CHO_Kcal) as Carb, mean(fat_Kcal) as Fat, mean(Protein_Kcal) as Prot
from Meals group by studyID, Period, meal;
create table EDcalculation as select distinct  StudyID, Period, DaysOnDiet, sum(EI) as EI, sum(Mass) as Mass from Meals where meal not in ('Snack') group by studyID, Period, DaysOnDiet;
create table EDcalculation1 as select distinct  StudyID, Period, mean(EI/Mass) as EnergyDensity from  EDcalculation group by studyID, Period;
quit;
proc sort data=Meal1; by meal; run;
ods select none;
proc glm data=Meal1;
class StudyID period ;
model AveEI  Carb Prot Fat EnergyDensity  = studyID period ;
lsmeans period/stderr pdiff;
estimate 'Proc Vs Unproc' period 1 -1; 
by meal;
ods output Estimates=tem;
ods output LSmeans=tem1;
run;
ods select all;
/* data for figure 2C*/
proc print data=tem1;
run;

/*energy density of the combined meals*/
ods graphics off;
proc glm data=EDcalculation1;
class StudyID period ;
model EnergyDensity   = studyID period ;
lsmeans period/stderr pdiff;
quit;
ods graphics on;
/* figure 3A*/
data DeltaBW; set "&path\DeltaBW"; run;
proc sgplot data=DeltaBW noborder;
vline DayInPeriod/ response = DeltaBW stat=mean limitstat=stderr numstd=1 group=period LIMITATTRS =(thickness=2) LineAttrs=(thickness=2 pattern= solid);
xaxis label='Time, day' Labelattrs=(size=15 weight=bold)  Valueattrs=(size=15 weight=bold);
yaxis label='Delta BW, kg' Labelattrs=(size=15 weight=bold)  Valueattrs=(size=15 weight=bold);
quit;

Data BC; set "&path\DeltaBC"; run;

/* correlation between bw change and EI change and BMI
data for figure 3B*/
proc corr data=BC; var deltaSodium DeltaEI BMI;
with DeltadeltaBW DeltaDeltaFFM;
run;
/* data for figure 2D*/
Data DeltaFM; set "&path\DeltaFM"; run;
proc means data=DeltaFM n mean stderr;
class DietforRate;
var DeltaFM71 DeltaFM141;
run;
/* data for figure 3D*/
Data BCadj14; set "&path\DeltaBCadj14"; run;
proc means data=BCadj14 n mean stderr probt;
var DeltaBWProc DeltaBWUnproc DeltaFMProc DeltaFMUnproc DeltaFFMProc DeltaFFMUnproc ;
run;

proc means data=BC  n mean stderr probt;
var  BCEBProcessed BCEBUnproc EIDLWEB_BCEBProcessed EIDLWEB_BCEBUnproc;
where studyID not in ('ADL009');
run;
/* Liver Fat*/
Data LiverFat; set "&path\LiverFat"; run;
ods graphics off;
proc glm data=LiverFat;
class subjectID Diet;
model PDFF_BHT2T1  = subjectID Diet;
lsmeans diet/stderr ;
estimate 'Ultra vs BaseLine' diet -1 1 0;
estimate 'UnPro vs BaseLine' diet -1 0 1;
quit;
ODS graphics on;

Data UCpeptide; set "&path\UCpeptide"; run;
ods graphics off;
proc glm data=UCpeptide;
class subjectID Diet;
model UCPExcreted = subjectID Diet;
estimate 'Processed vs Unprocessed' diet 1 -1;
lsmeans diet/ pdiff stderr;
quit;
ods graphics on; 
Data GCMChamberDays;  set "&path\GCMChamberDays"; run;
ods graphics off;
proc glm data=GCMChamberDays;
class subID Diet;
model DexcomGlucose = subID Diet;
lsmeans Diet/pdiff stderr;
quit;
ods graphics on;
/*pleasant and familiar   results need to be divided by 3 meals before present*/
data FoodMood; set "&path\PleasantFamilar"; run;
ods graphics off;
proc glm data=FoodMood;
class study_ID Diet ;
model pleasant = study_ID diet;
lsmeans diet/ stderr pdiff;
estimate 'Ultra vs Unprocess' diet 1 -1;
ods output Lsmeans=tem;
where Npleasant=3;
quit;
data tem1; set tem;
LSMean = LSMean/3;
stderr =stderr/3;
run;
/* data for figure 2D */
proc print data=tem1; run;

proc glm data=FoodMood;
class study_ID Diet ;
model familiar = study_ID diet;
lsmeans diet/ stderr pdiff;
means diet;
estimate 'Ultra vs Unprocess' diet 1 -1;
ods output Lsmeans=tem;
where Nfamiliar=3;
quit;
data tem1; set tem;
LSMean = LSMean/3;
stderr =stderr/3;
run;
/* data for figure 2D */
proc print data=tem1; run;
/* Hunger satiety  
data for figure 2E*/
data hungrySatiety; set  "&path\hungrySatiety"; run;
ods graphics off;
proc glm data=hungrySatiety;
class subjectID diet ;
model hungryAve SatisfiedAve FullnessAve EatingCapacityAve = subjectID diet EI; /**/
lsmeans diet/ stderr pdiff;
estimate "Ultra vs. Unprocess" diet 1 -1;
ods output Estimates=tem1;
ods output lsmeans=tem;
where subjectID not in ('ADL001'); 
run;
ods graphics on;

/* Eating Rate 
data for figure 2F*/
Data EatingRate; set "&path\EatRate"; run;
proc sql;
create table DeltaEatingRate as 
select distinct subjectID, 
(select mean(EIrateDaily) from EatingRate inside where inside.subjectID = outside.subjectID and inside.Foodtype = 'Processed') as ProcessedEIRate,
(select mean(EI) from EatingRate inside where inside.subjectID = outside.subjectID and inside.Foodtype = 'Processed') as ProcessedEI,
(select mean(EIrateDaily) from EatingRate inside where inside.subjectID = outside.subjectID and inside.Foodtype = 'Unprocessed') as UnProcessedEIRate,
(select mean(EI) from EatingRate inside where inside.subjectID = outside.subjectID and inside.Foodtype = 'Unprocessed') as UnProcessedEI,
(calculated ProcessedEIRate) - (calculated UnProcessedEIRate) as DeltaEIrate,
(calculated ProcessedEI) - (calculated UnProcessedEI) as DeltaEI
from EatingRate outside;
quit;
proc glm data=EatingRate;
class subjectID FoodType;
model MassRateDaily EIRateDaily = subjectID Foodtype;
estimate "Process vs Unproc" FoodType 1 -1;
lsmeans Foodtype /pdiff stderr;
quit;
proc corr data=DeltaEatingRate;
var  DeltaEIrate  DeltaEI;
run;

/*Figure 4 AB*/
data OGTTgraph; set "&path\OGTTgraph"; run;
Title height = 20pt "Glucose Concentrations during OGTT";
proc sgplot data=OGTTgraph noborder noautolegend;
vline time / response = glucose stat=mean limitstat=stderr markers group = diet lineattrs = (thickness=2 pattern=solid) markerattrs = (symbol = circlefilled) LIMITATTRS =(thickness=2) ;
yaxis label = "Glucose, mg/dl" Labelattrs=(size=15 weight=bold)  Valueattrs=(size=15 weight=bold);
xaxis label = "Time, minute" Labelattrs=(size=15 weight=bold)  Valueattrs=(size=15 weight=bold);
quit;
Title  height = 20pt "Insulin Concentrations during OGTT";
proc sgplot data=OGTTgraph noborder noautolegend;
vline time / response = insulin stat=mean limitstat=stderr markers group = diet  lineattrs = (thickness=2 pattern=solid) markerattrs = (symbol = circlefilled) LIMITATTRS =(thickness=2);
yaxis label = "Insulin" Labelattrs=(size=15 weight=bold)  Valueattrs=(size=15 weight=bold);
xaxis label = "Time, minute" Labelattrs=(size=15 weight=bold)  Valueattrs=(size=15 weight=bold);
quit;

/* figure 4C */
data DexComVariation; set  "&path\DexComVariation"; run;
proc means data = DexComVariation noprint;
class diet;
var GluMean GluCV;
output out=tem  mean= stderr= LCLM=  UCLM= /autoname;
run;
proc print data=tem; run;
