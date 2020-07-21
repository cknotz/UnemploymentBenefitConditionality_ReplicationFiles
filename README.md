# UnemploymentBenefitConditionality_ReplicationFiles
This repository contains `Stata` (v.13) replication code for the compilation of the Unemployment Benefit Conditions &amp; Sanctions Dataset and the aggregate indicators.

The repository contains three replication files: 
  1) the `cond_xlstodta_18.do` file, which reads the original coded data into Stata; 
  2) the `cond_dataprep_18.do` file, which does some data mangling; 
  3) the `condsanc_compilation_18.do` file, which does the actual computation of the aggregate indicators 
    (and also calls the first two automatically).
