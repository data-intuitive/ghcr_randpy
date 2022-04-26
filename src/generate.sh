#!/bin/bash

fol_os=src/1_os
fol_r=src/2_r
fol_py=src/3_python
fol_bioc=src/4_bioc

# generate r + python dockerfiles
for os in $(ls $fol_os); do
  for r in $(ls $fol_r); do
    for py in $(ls $fol_py); do
      out=dockerfiles/r${r}_py${py}.Dockerfile
      cat $fol_os/$os/Dockerfile > $out
      echo >> $out
      cat $fol_r/$r/Dockerfile >> $out
      echo >> $out
      cat $fol_py/$py/Dockerfile >> $out
      
      if [ $r == "4.2" ]; then
        bioc=3.15
        out2=${out%.Dockerfile}_bioc$bioc.Dockerfile
        cat $out > $out2
        echo >> $out2
        cat $fol_bioc/$bioc/Dockerfile >> $out2
      fi
      
      if [ $r == "4.1" ]; then
        bioc=3.14
        out2=${out%.Dockerfile}_bioc$bioc.Dockerfile
        cat $out > $out2
        echo >> $out2
        cat $fol_bioc/$bioc/Dockerfile >> $out2
      fi
      
      if [ $r == "4.1" ]; then
        bioc=3.13
        out2=${out%.Dockerfile}_bioc$bioc.Dockerfile
        cat $out > $out2
        echo >> $out2
        cat $fol_bioc/$bioc/Dockerfile >> $out2
      fi
      
      if [ $r == "4.0" ]; then
        bioc=3.12
        out2=${out%.Dockerfile}_bioc$bioc.Dockerfile
        cat $out > $out2
        echo >> $out2
        cat $fol_bioc/$bioc/Dockerfile >> $out2
      fi
      if [ $r == "4.0" ]; then
        bioc=3.11
        out2=${out%.Dockerfile}_bioc$bioc.Dockerfile
        cat $out > $out2
        echo >> $out2
        cat $fol_bioc/$bioc/Dockerfile >> $out2
      fi
      if [ $r == "3.6" ]; then
        bioc=3.10
        out2=${out%.Dockerfile}_bioc$bioc.Dockerfile
        cat $out > $out2
        echo >> $out2
        cat $fol_bioc/$bioc/Dockerfile >> $out2
      fi
      if [ $r == "3.6" ]; then
        bioc=3.9
        out2=${out%.Dockerfile}_bioc$bioc.Dockerfile
        cat $out > $out2
        echo >> $out2
        cat $fol_bioc/$bioc/Dockerfile >> $out2
      fi
    done
  done
done

# generate r dockerfiles
for os in $(ls $fol_os); do
  for r in $(ls $fol_r); do
    out=dockerfiles/r${r}.Dockerfile
    cat $fol_os/$os/Dockerfile > $out
    echo >> $out
    cat $fol_r/$r/Dockerfile >> $out
      
    if [ $r == "4.0" ]; then
      bioc=3.12
      out2=${out%.Dockerfile}_bioc$bioc.Dockerfile
      cat $out > $out2
      echo >> $out2
      cat $fol_bioc/$bioc/Dockerfile >> $out2
    fi
    if [ $r == "4.0" ]; then
      bioc=3.11
      out2=${out%.Dockerfile}_bioc$bioc.Dockerfile
      cat $out > $out2
      echo >> $out2
      cat $fol_bioc/$bioc/Dockerfile >> $out2
    fi
    if [ $r == "3.6" ]; then
      bioc=3.10
      out2=${out%.Dockerfile}_bioc$bioc.Dockerfile
      cat $out > $out2
      echo >> $out2
      cat $fol_bioc/$bioc/Dockerfile >> $out2
    fi
    if [ $r == "3.6" ]; then
      bioc=3.9
      out2=${out%.Dockerfile}_bioc$bioc.Dockerfile
      cat $out > $out2
      echo >> $out2
      cat $fol_bioc/$bioc/Dockerfile >> $out2
    fi
  done
done

# generate python dockerfiles
for os in $(ls $fol_os); do
    for py in $(ls $fol_py); do
    out=dockerfiles/py${py}.Dockerfile
    cat $fol_os/$os/Dockerfile > $out
    echo >> $out
    cat $fol_py/$py/Dockerfile >> $out
  done
done
