#------------------------------------------
# INSTALL R
# Interpreted from bioconductor/bioconductor_docker:3.12
# https://github.com/Bioconductor/bioconductor_docker/blob/master/Dockerfile
#------------------------------------------

# PART 1: install scripts
RUN cd / && \
  wget https://github.com/Bioconductor/bioconductor_docker/archive/refs/heads/master.zip && \
  unzip master.zip && \
  mv /bioconductor_docker-master/bioc_scripts /bioc_scripts && \
  rm -r master.zip /bioconductor_docker-master

## Set Dockerfile version number
ARG BIOCONDUCTOR_VERSION=3.15

##### IMPORTANT ########
## The PATCH version number should be incremented each time
## there is a change in the Dockerfile.
ARG BIOCONDUCTOR_PATCH=24

ARG BIOCONDUCTOR_DOCKER_VERSION=${BIOCONDUCTOR_VERSION}.${BIOCONDUCTOR_PATCH}

##  Add Bioconductor system dependencies
RUN bash /bioc_scripts/install_bioc_sysdeps.sh

## Add host-site-library
RUN echo "R_LIBS=/usr/local/lib/R/host-site-library:\${R_LIBS}" > /usr/local/lib/R/etc/Renviron.site

## Install specific version of BiocManager
RUN R -f /bioc_scripts/install.R

# DEVEL: Add sys env variables to DEVEL image
# Variables in Renviron.site are made available inside of R.
# Add libsbml CFLAGS
RUN curl -O http://bioconductor.org/checkResults/devel/bioc-LATEST/Renviron.bioc \
    && cat Renviron.bioc | grep -o '^[^#]*' | sed 's/export //g' >>/etc/environment \
    && cat Renviron.bioc >> /usr/local/lib/R/etc/Renviron.site \
    && echo BIOCONDUCTOR_VERSION=${BIOCONDUCTOR_VERSION} >> /usr/local/lib/R/etc/Renviron.site \
    && echo BIOCONDUCTOR_DOCKER_VERSION=${BIOCONDUCTOR_DOCKER_VERSION} >> /usr/local/lib/R/etc/Renviron.site \
    && echo 'LIBSBML_CFLAGS="-I/usr/include"' >> /usr/local/lib/R/etc/Renviron.site \
    && echo 'LIBSBML_LIBS="-lsbml"' >> /usr/local/lib/R/etc/Renviron.site \
    && rm -rf Renviron.bioc

ENV LIBSBML_CFLAGS="-I/usr/include"
ENV LIBSBML_LIBS="-lsbml"
ENV BIOCONDUCTOR_DOCKER_VERSION=$BIOCONDUCTOR_DOCKER_VERSION
ENV BIOCONDUCTOR_VERSION=$BIOCONDUCTOR_VERSION

# install some bioconductor dependencies
RUN Rscript -e 'remotes::install_cran(c("BiocManager", "Seurat", "rmarkdown", "reticulate", "pheatmap", "hdf5r"))' && \
  Rscript -e 'BiocManager::install(version="3.15", update=TRUE, ask=FALSE)' && \
  Rscript -e 'BiocManager::install(c("SingleCellExperiment", "GenomicFeatures", "rtracklayer", "Rsamtools", "scater"))'
