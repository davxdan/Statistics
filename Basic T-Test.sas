/* Boxplot */
proc boxplot data=WORK.LEDUCATION;
	plot loggedIncome2005*Educ;	/* 	Get the Critical Value for the permutation test */
	data critval;
	cv=quantile("T", .05, 998); /*Be sure to use .025 for 2 sided or .05 for 1 sided. In this case desired alpha is .05 and df is 998*//* Log Transform the Education Data */
data lEducation;
set Education;
loggedIncome2005 = log(Income2005);
DATA  WORK.LEDUCATION(DROP =  Income2005); 
SET  WORK.LEDUCATION;
RUN;                                                                                                                                                                                                                             
data creativity;                                                                                                                           
input treatment score;   /* 1 is extrinsic and 0 in intrinsic*/                                                                                                                                                                                                     
datalines;                                                                                                                                                                                                                   
1	5
1	5.4
1	6.1
1	10.9
1	11.8
1	12
1	12.3
1	14.8
1	15
1	16.8
1	17.2
1	17.2
1	17.4
1	17.5
1	18.5
1	18.7
1	18.7
1	19.2
1	19.5
1	20.7
1	21.2
1	22.1
1	24
0	12
0	12
0	12.9
0	13.6
0	16.6
0	17.2
0	17.5
0	18.2
0	19.1
0	19.3
0	19.8
0	20.3
0	20.5
0	20.6
0	21.3
0	21.6
0	22.1
0	22.2
0	22.6
0	23.1
0	24
0	24.3
0	26.7
0	29.7
;                                                                                                                                                                                                                            
                                                                                                                                                                                                                             
* To get the observed difference;                                                                                                                                                                                            
proc ttest data=creativity;  * You will need to change the dataset name here.;                                                                                                                                                     
                                                                                                                                                                                                                             
   class treatment;    *and change the class variable to match yours here;                                                                                                                                                  
                                                                                                                                                                                                                             
   var score;          * and change the var name here.;                                                                                                                                                                      
                                                                                                                                                                                                                             
run;                                                                                                                                                                                                                         

ods output off;
ods exclude all;
                                                                                                                                                                                                                         
*borrowed code from internet ... randomizes observations and creates a matrix ... one row per randomization ;                                                                                                                
proc iml;                                                                                                                                                                                                                    
use creativity;                        * change data set name here to match your data set name above;                                                                                                                              
read all var{treatment score} into x;   *change varibale names here ... make sure it is class then var ... in that order.;                                                                                                  
p = t(ranperm(x[,2],1000));    *Note that the "1000" here is the number of permutations. ;                                                                                                                                    
paf = x[,1]||p;                                                                                                                                                                                                              
create newds from paf;                                                                                                                                                                                                       
append from paf;                                                                                                                                                                                                             
quit;                                                                                                                                                                                                                        
                                                                                                                                                                                                                             
*calculates differences and creates a histogram;                                                                                                                                                                             
ods output conflimits=diff;                                                                                                                                                                                                  
proc ttest data=newds plots=none;                                                                                                                                                                                            
  class col1;                                                                                                                                                                                                                
  var col2 - col1001;                                                                                                                                                                                                        
run;                                                                                                                                                                                                                         

ods output on;
ods exclude none;       
                  
proc univariate data=diff;                                                                                                                                                                                                   
  where method = "Pooled";                                                                                                                                                                                                   
  var mean;                                                                                                                                                                                                                  
  histogram mean;                                                                                                                                                                                                            
run;                                                                                                                                                                                                                         
                                                                                                                                                                                  
*The code below calculates the number of randomly generated differences that are as extreme or more extreme thant the one observed (divide this number by 1000 you have the pvalue);                                         
*check the log to see how many observations are in the data set.... divide this by 1000 (or however many permutations you generated) and that is the (one sided)p-value;                                                     
data numdiffs;                                                                                                                                                                                                               
set diff;                                                                                                                                                                                                                    
where method = "Pooled";                                                                                                                                                                                                     
if abs(mean) >= 4.1142;   *you will need to put the observed difference you got from t test above here.  note if you have a one or two tailed test.;                                                                           
run;                                                                                                                                                                                                                         
* just a visual of the rows produced ... you can get the number of obersvations from the last data step and the Log window.;                                                                                                 
proc print data = numdiffs;                                                                                                                                                                                                  
where method = "Pooled";                                                                                                                                                                                                     
run;                                                                                                                                                                                                                         
                                                                                                                                                                                                                             
                                                                                                                                                                                                                             
*Idea from http://sas-and-r.blogspot.com/2011/10/example-912-simpler-ways-to-carry-out.html ;                                                                                                                                
                              proc power;
twosamplemeans
meandiff = 1.9238 
stddev = 6.1519
ntotal = .
power = .8;
plot x = effect min =.5 max = 2;
run;

proc power;
twosamplemeans
meandiff = 1.9238 
stddev = 6.1519
ntotal = .
power = .8 .7 .6;
plot y = effect min =.5 max = 2;
run;

proc power;
twosamplemeans
meandiff = 1.9238 
stddev = 6.1519
ntotal = .
power = .8 .6;
plot x = effect min = .6  max =1;
run;
proc Sort data=SamoaEmployees;
	by EmploymentStatus;proc Sort data=SamoaEmployees;
	by EmploymentStatus;*To address ANOVA assumptions on log transformed data with scatter plots;
proc sgplot data = Education;
scatter x= Educ y = Income2005;
run;proc univariate data=Education;
	by Educ;
	histogram;
	qqplot Income2005;proc glm data = incomedata;
class educ;
model income2005 = educ;
means educ / hovtest = bf welch;
run;	proc ttest data=SamoaEmployees sides=2;
		class EmploymentStatus;
		var Age;