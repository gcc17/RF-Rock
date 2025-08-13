# Code of RF-Rock

## Overview

We present **RF-Rock**, a novel RFID identification method leveraging intermodulation effects for physical-layer fingerprinting **without requiring tag activation**. While prior work has empirically demonstrated the feasibility of RFID fingerprinting, the underlying theory and scalability remain underexplored.  

This repository provides the implementation of **RF-Rock**, including: **simulation & entropy analysis** for fingerprint distinctness, **channel elimination** for fingerprint consistency, and **metric learning** for fingerprint identification.  



## Fingerprint Distinctness

1. Distinctness origin: LTSpice simulation

   We provide LTspice circuit simulation files (`.asc`) and plotting scripts in the `circuit_simulation` directory.

2. Distinctness quantification: entropy analysis

   We provide the 4-dimensional embeddings of tag signals and entropy analysis scripts in the `entropy_analysis` directory. 



## Fingerprint Consistency

1. We provide download links for:

   - Raw RFID signal measurements
   - Extracted fingerprint features
   - Processed identification features

   The identification features are constructed using the methodology detailed in Section 6 of our paper, and are the inputs for neural network-based tag identification system.

   * [Raw data](https://www.dropbox.com/scl/fo/8rebuswdqcatht3q42m41/APJcevU7VVlILNpgya-QPQk?rlkey=sibzir0ekyxwlbfn8f5u85igt&st=3yd4tply&dl=0)
   * [Fingerprint](https://www.dropbox.com/scl/fo/ywrh1lw4rculup8cpkr11/AIrxtKEAe2lbhUfDZkOLS2A?rlkey=zee70bbso8g7hc1tgizt5lboj&st=owlrcidf&dl=0)
   * [Identification feature](https://www.dropbox.com/scl/fo/0p0rsc6y0ee3p9r8643r0/ADj7VL67IktQazrVkkusqNg?rlkey=1wkeb55n7s1msc1l7el9mvdud&st=vza2qd9k&dl=0)

2. We provide the code for fingerprint extraction and identification feature construction in the `data_processing` directory. 



## Fingerprint Identification

The `metric_learning` directory contains our implementation of the tag identification system, including core metric learning framework for robust fingerprint matching and example scripts demonstrating model training and evaluation. 