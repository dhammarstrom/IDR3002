proc format;
invalue filter
'Acute Care PanelGlucose'=6
'Lipid PanelCholesterol, Total'=15
'Lipid PanelTriglycerides'=16
'Lipid PanelHDL Cholesterol'=17
'Lipid PanelLDL Cholest. Calculated'=18
'Lipid PanelLDL Cholest., Direct'=18
'Lipid PanelLDL Cholesterol-Calculated'=18
'Uric AcidUric Acid'=25
'Hemoglobin A1CHgb A1C'=27
'Thyroid Stimulating HormoneThyroid Stimulating Hormone'=28
'T3, FreeFree T3'=29
'Thyroxine, FreeFT4 (Free Thyroxine)'=30
'Thyroxine, FreeThyroxine, Free'=30
'ThyroxineT4'=31
'ThyroxineThyroxine'=31
'TriiodothyronineT3'=32
'TriiodothyronineTriiodothyronine'=32
'CRP, High Sensitivity, ComprehensiveC-React Prot. High Sensitivi'=33
'CRP, High Sensitivity, ComprehensiveCRP,High Sensitivity, Compre'=33
'C-Peptide, SensitiveC-Peptide, Sensitive'=34
'C-PeptideC-Peptide, Serum'=34
'Free Fatty Acids, TotalFree Fatty Acids,Serum'=35
'Insulin Serum LevelInsulin'=36
other=0
;
run;

proc format;
value filterRev
6='Glucose'
15='Cholesterol, Total'
16='Triglycerides'
17='HDL Cholesterol'
18='LDL'
25='Uric Acid'
27='Hgb A1C'
28='Thyroid Stimulating Hormone'
29='Free T3'
30='FT4 (Free Thyroxine)'
31='T4'
32='T3'
33='C-React Prot. High Sensitivi'
34='C-Peptide, Sensitive'
35='Free Fatty Acids,Serum'
36='Insulin'
37='HOMA IR'
38='HOMA Beta'
;
run;
