FROM ubuntu:focal

LABEL org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/data-intuitive/ghcr_randpy" \
      org.opencontainers.image.vendor="randpy: R and Python in one container" \
      org.opencontainers.image.authors="Robrecht Cannoodt <robrecht@data-intuitive.com>"

#------------------------------------------
# INSTALL build deps
# Interpreted from 
# https://github.com/docker-library/buildpack-deps/blob/master/debian/buster/curl/Dockerfile
# https://github.com/docker-library/buildpack-deps/blob/master/debian/buster/scm/Dockerfile
# https://github.com/docker-library/buildpack-deps/blob/master/debian/buster/Dockerfile
#------------------------------------------

## PART 1: https://github.com/docker-library/buildpack-deps/blob/master/debian/buster/curl/Dockerfile
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		netbase \
		wget \
	; \
	rm -rf /var/lib/apt/lists/*

RUN set -ex; \
	if ! command -v gpg > /dev/null; then \
		apt-get update; \
		apt-get install -y --no-install-recommends \
			gnupg \
			dirmngr \
		; \
		rm -rf /var/lib/apt/lists/*; \
	fi


## PART 2: https://github.com/docker-library/buildpack-deps/blob/master/debian/buster/scm/Dockerfile
# procps is very common in build systems, and is a reasonably small package
RUN apt-get update && apt-get install -y --no-install-recommends \
		git \
		mercurial \
		openssh-client \
		subversion \
		\
		procps \
	&& rm -rf /var/lib/apt/lists/*

## PART 3: https://github.com/docker-library/buildpack-deps/blob/master/debian/buster/Dockerfile
# prepend apt-get install with DEBIAN_FRONTEND=noninteractive -> make sure debconf doesn't try to prompt (e.g. tzdata on Ubuntu)
RUN set -ex; \
	apt-get update; \
	DEBIAN_FRONTEND=noninteractive \
	apt-get install -y --no-install-recommends \
		autoconf \
		automake \
		bzip2 \
		dpkg-dev \
		file \
		g++ \
		gcc \
		imagemagick \
		libbz2-dev \
		libc6-dev \
		libcurl4-openssl-dev \
		libdb-dev \
		libevent-dev \
		libffi-dev \
		libgdbm-dev \
		libglib2.0-dev \
		libgmp-dev \
		libjpeg-dev \
		libkrb5-dev \
		liblzma-dev \
		libmagickcore-dev \
		libmagickwand-dev \
		libmaxminddb-dev \
		libncurses5-dev \
		libncursesw5-dev \
		libpng-dev \
		libpq-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		libtool \
		libwebp-dev \
		libxml2-dev \
		libxslt-dev \
		libyaml-dev \
		make \
		patch \
		unzip \
		xz-utils \
		zlib1g-dev \
		\
# https://lists.debian.org/debian-devel-announce/2016/09/msg00000.html
		$( \
# if we use just "apt-cache show" here, it returns zero because "Can't select versions from package 'libmysqlclient-dev' as it is purely virtual", hence the pipe to grep
			if apt-cache show 'default-libmysqlclient-dev' 2>/dev/null | grep -q '^Version:'; then \
				echo 'default-libmysqlclient-dev'; \
			else \
				echo 'libmysqlclient-dev'; \
			fi \
		) \
	; \
	rm -rf /var/lib/apt/lists/*


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
# https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/r-ver_4.2.0.Dockerfile
ENV R_VERSION=4.2.0
ENV TERM=xterm
ENV R_HOME=/usr/local/lib/R
ENV TZ=Etc/UTC

RUN /rocker_scripts/install_R_source.sh

ENV CRAN=https://packagemanager.rstudio.com/cran/__linux__/focal/latest
ENV LANG=en_US.UTF-8

RUN /rocker_scripts/setup_R.sh

## PART 3: install pandoc & rstudio
# https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/rstudio_4.2.0.Dockerfile
ENV S6_VERSION=v2.1.0.2
ENV RSTUDIO_VERSION=2022.02.1+461
ENV DEFAULT_USER=rstudio
ENV PANDOC_VERSION=default
ENV PATH=/usr/lib/rstudio-server/bin:$PATH

RUN /rocker_scripts/install_rstudio.sh
RUN /rocker_scripts/install_pandoc.sh

EXPOSE 8787

## PART 4: install tidyverse
# https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/tidyverse_4.2.0.Dockerfile
RUN /rocker_scripts/install_tidyverse.sh

## PART 5: install verse
# https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/verse_4.2.0.Dockerfile
ENV CTAN_REPO=https://mirror.ctan.org/systems/texlive/tlnet
ENV PATH=$PATH:/usr/local/texlive/bin/x86_64-linux
ENV QUARTO_VERSION=latest

RUN /rocker_scripts/install_verse.sh
RUN /rocker_scripts/install_quarto.sh


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
