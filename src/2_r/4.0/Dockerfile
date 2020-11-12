#------------------------------------------
# INSTALL R
# Interpreted from rocker/r-ver:4.0
# https://github.com/rocker-org/rocker-versioned2/tree/master/dockerfiles
#------------------------------------------

# PART 1: install scripts
RUN cd / && \
  wget https://github.com/rocker-org/rocker-versioned2/archive/master.zip && \
  unzip master.zip && \
  mv /rocker-versioned2-master/scripts /rocker_scripts && \
  rm -r master.zip /rocker-versioned2-master
  
## PART 2: install R
ENV BUILD_DATE=2020-11-12 \
    R_VERSION=4.0.3 \
    CRAN="https://cran.rstudio.com" \ 
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TERM=xterm \
    R_HOME=/usr/local/lib/R \
    TZ=Etc/UTC \
    UBUNTU_VERSION=bionic
    
RUN /rocker_scripts/install_R.sh
  

## PART 3: install pandoc & rstudio
ENV S6_VERSION=v1.21.7.0 \
    RSTUDIO_VERSION=latest \
    PATH=/usr/lib/rstudio-server/bin:$PATH

RUN /rocker_scripts/install_rstudio.sh
RUN /rocker_scripts/install_pandoc.sh

EXPOSE 8787

## PART 4: install tidyverse
RUN /rocker_scripts/install_tidyverse.sh

## PART 5: install verse
ENV CTAN_REPO=http://mirror.ctan.org/systems/texlive/tlnet \
    PATH=/usr/local/texlive/bin/x86_64-linux:$PATH

RUN /rocker_scripts/install_verse.sh

