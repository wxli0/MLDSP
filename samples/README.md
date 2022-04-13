Enhanced Machine Learning with Digital Signal Processing (eMLDSP)

MLDSP is an is an alignment-free software tool for ultrafast, accurate, and scalable genome classification at all taxonomic ranks. See [MLDSP](https://github.com/grandhawa/MLDSP). In addition to MLDSP, eMLDSP has the capability to handle the special case where the parent taxon has only one child taxon, as well as to output classification confidences for its classifications

To run a task for a taxon <mark>c</mark>, outputs stored in outputs-<mark>data_type<\mark>, training and test datasets stored in <mark>base_path<\mark>, test directory being <mark>test_dir<\mark> and with partial classifications

- cd ~/MLDSP; bash phase.sh -s '+c + ' -d ' +  data_type + ' -b ' +base_path + ' -t '+ test_dir + ' -p '

To run a task for a taxon <mark>c</mark>, outputs stored in outputs-<mark>data_type<\mark>, training and test datasets stored in <mark>base_path<\mark>, test directory being <mark>test_dir<\mark> and without partial classifications

- cd ~/MLDSP; bash phase.sh -s '+c + ' -d ' +  data_type + ' -b ' +base_path + ' -t '+ test_dir
