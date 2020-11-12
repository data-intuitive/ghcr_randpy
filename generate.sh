#!/bin/bash

fol_os=src/1_os
fol_r=src/2_r
fol_py=src/3_python

for os in $(fol_os); do
  for r in $(fol_r); do
    for py in $(fol_py); do
      out=${os}_r${r}_py${py}.Dockerfile
      cat $fol_os/$os/Dockerfile > $out
      cat $fol_r/$r/Dockerfile >> $out
      cat $fol_py/$py/Dockerfile >> $out
    done
  done
done
