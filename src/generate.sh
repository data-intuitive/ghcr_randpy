#!/bin/bash

fol_os=src/1_os
fol_r=src/2_r
fol_py=src/3_python

for os in $(ls $fol_os); do
  for r in $(ls $fol_r); do
    for py in $(ls $fol_py); do
      out=dockerfiles/r${r}_py${py}.Dockerfile
      cat $fol_os/$os/Dockerfile > $out
      echo >> $out
      cat $fol_r/$r/Dockerfile >> $out
      echo >> $out
      cat $fol_py/$py/Dockerfile >> $out
    done
  done
done

for os in $(ls $fol_os); do
  for r in $(ls $fol_r); do
    out=dockerfiles/r${r}.Dockerfile
    cat $fol_os/$os/Dockerfile > $out
    echo >> $out
    cat $fol_r/$r/Dockerfile >> $out
  done
done

for os in $(ls $fol_os); do
    for py in $(ls $fol_py); do
    out=dockerfiles/py${py}.Dockerfile
    cat $fol_os/$os/Dockerfile > $out
    echo >> $out
    cat $fol_py/$py/Dockerfile >> $out
  done
done
