### To install the package
```
remotes::install_github("lipikakalson/MESOMICS", build_vignettes = FALSE)
```

### Workflow
#### Step 1
```
MESOMICS::add_sample_to_mofa(test_matrix_path = "inst/extdata/test.csv", python_bin = '/path/to/envs/mofa_env/bin/python')
```
#### Step 2
```
MESOMICS::run_mofa(python_bin = '/path/to/envs/mofa_env/bin/python')
```
#### Step 3
```
MESOMICS::plot_test_samples(python_bin = '/path/to/envs/mofa_env/bin/python')
```
## OR

#### Pipeline wrapper for Steps 1-3
```
MESOMICS::run_1to3(test_matrix_path = "inst/extdata/test.csv", mofa_dir = mofa_dir, python_bin = python_path)
```
#### All sample plot
```
MESOMICS::plot_test_all_samples(python_bin = '/path/to/envs/mofa_env/bin/python')
```

### Latent factors of test samples
```
MESOMICS::collect_testsamples_factors()
```
