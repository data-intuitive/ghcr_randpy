#!/bin/bash

fol_os=src/1_os
fol_r=src/2_r
fol_py=src/3_python
for os in buster; do
  for r in 3.6.3 4.0.2; do
    for py in 3.6.11 3.7.8 3.8.3; do
      out=dockerfiles/${os}_r${r}_py${py}.Dockerfile
      cat $fol_os/$os/Dockerfile > $out
      echo >> $out
      cat $fol_r/$r/Dockerfile >> $out
      echo >> $out
      cat $fol_py/$py/Dockerfile >> $out
    done
  done
done
