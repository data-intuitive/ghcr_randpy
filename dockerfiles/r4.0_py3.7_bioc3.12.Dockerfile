FROM debian:buster

LABEL org.label-schema.license="MIT" \
      org.label-schema.vcs-url="https://github.com/data-intuitive/randpy" \
      org.label-schema.vendor="randpy: R and Python in one container" \
      maintainer="Robrecht Cannoodt <robrecht@data-intuitive.com>"

#------------------------------------------
# INSTALL build deps
# Interpreted from 
# https://github.com/docker-library/buildpack-deps/blob/master/debian/buster/curl/Dockerfile
# https://github.com/docker-library/buildpack-deps/blob/master/debian/buster/scm/Dockerfile
# https://github.com/docker-library/buildpack-deps/blob/master/debian/buster/Dockerfile
#------------------------------------------

## PART 1: https://github.com/docker-library/buildpack-deps/blob/master/debian/buster/curl/Dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		netbase \
		wget \
	&& rm -rf /var/lib/apt/lists/*

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
RUN set -ex; \
	apt-get update; \
# make sure debconf doesn't try to prompt (e.g. tzdata on Ubuntu)
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
ENV BUILD_DATE=2020-11-12 \
    R_VERSION=4.0.3 \
    CRAN="https://cran.rstudio.com" \ 
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TERM=xterm \
    R_HOME=/usr/local/lib/R \
    TZ=Etc/UTC
    
RUN UBUNTU_VERSION=bionic /rocker_scripts/install_R.sh

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


#------------------------------------------
# INSTALL Python
# Interpreted from python:3.7
# https://github.com/docker-library/python/blob/master/3.7/buster/Dockerfile
#------------------------------------------

## PART 1: https://github.com/docker-library/python/blob/master/3.7/buster/Dockerfile

# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# extra dependencies (over what buildpack-deps already includes)
RUN apt-get update && apt-get install -y --no-install-recommends \
		libbluetooth-dev \
		tk-dev \
		uuid-dev \
	&& rm -rf /var/lib/apt/lists/*

ENV GPG_KEY 0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D
ENV PYTHON_VERSION 3.7.9

RUN set -ex \
	\
	&& wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
	&& wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
	&& rm -rf "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	\
	&& cd /usr/src/python \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
		--build="$gnuArch" \
		--enable-loadable-sqlite-extensions \
		--enable-optimizations \
		--enable-option-checking=fatal \
		--enable-shared \
		--with-system-expat \
		--with-system-ffi \
		--without-ensurepip \
	&& make -j "$(nproc)" \
# setting PROFILE_TASK makes "--enable-optimizations" reasonable: https://bugs.python.org/issue36044 / https://github.com/docker-library/python/issues/160#issuecomment-509426916
		PROFILE_TASK='-m test.regrtest --pgo \
			test_array \
			test_base64 \
			test_binascii \
			test_binhex \
			test_binop \
			test_bytes \
			test_c_locale_coercion \
			test_class \
			test_cmath \
			test_codecs \
			test_compile \
			test_complex \
			test_csv \
			test_decimal \
			test_dict \
			test_float \
			test_fstring \
			test_hashlib \
			test_io \
			test_iter \
			test_json \
			test_long \
			test_math \
			test_memoryview \
			test_pickle \
			test_re \
			test_set \
			test_slice \
			test_struct \
			test_threading \
			test_time \
			test_traceback \
			test_unicode \
		' \
	&& make install \
	&& rm -rf /usr/src/python \
	\
	&& find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
			-o \( -type f -a -name 'wininst-*.exe' \) \
		\) -exec rm -rf '{}' + \
	\
	&& ldconfig \
	\
	&& python3 --version

# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& ln -s idle3 idle \
	&& ln -s pydoc3 pydoc \
	&& ln -s python3 python \
	&& ln -s python3-config python-config

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 20.2.4
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/fa7dc83944936bf09a0e4cb5d5ec852c0d256599/get-pip.py
ENV PYTHON_GET_PIP_SHA256 6e0bb0a2c2533361d7f297ed547237caf1b7507f197835974c0dd7eba998c53c

RUN set -ex; \
	\
	wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
	echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum --check --strict -; \
	\
	python get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION" \
	; \
	pip --version; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +; \
	rm -f get-pip.py

#------------------------------------------
# INSTALL R
# Interpreted from bioconductor/bioconductor_docker:3.12
# https://github.com/Bioconductor/bioconductor_docker/blob/master/Dockerfile
#------------------------------------------

# Update apt-get
RUN apt-get update \
	&& apt-get install -y --no-install-recommends apt-utils \
	&& apt-get install -y --no-install-recommends \
	## Basic deps
	gdb \
	libxml2-dev \
	python3-pip \
	libz-dev \
	liblzma-dev \
	libbz2-dev \
	libpng-dev \
	## sys deps from bioc_full
	pkg-config \
	fortran77-compiler \
	byacc \
	automake \
	curl \
	## This section installs libraries
	libpcre2-dev \
	libnetcdf-dev \
	libhdf5-serial-dev \
	libfftw3-dev \
	libopenbabel-dev \
	libopenmpi-dev \
	libxt-dev \
	libudunits2-dev \
	libgeos-dev \
	libproj-dev \
	libcairo2-dev \
	libtiff5-dev \
	libreadline-dev \
	libgsl0-dev \
	libgslcblas0 \
	libgtk2.0-dev \
	libgl1-mesa-dev \
	libglu1-mesa-dev \
	libgmp3-dev \
	libhdf5-dev \
	libncurses-dev \
	libbz2-dev \
	libxpm-dev \
	liblapack-dev \
	libv8-dev \
	libgtkmm-2.4-dev \
	libmpfr-dev \
	libmodule-build-perl \
	libapparmor-dev \
	libprotoc-dev \
	librdf0-dev \
	libmagick++-dev \
	libsasl2-dev \
	libpoppler-cpp-dev \
	libprotobuf-dev \
	libpq-dev \
	libperl-dev \
	## software - perl extentions and modules
	libarchive-extract-perl \
	libfile-copy-recursive-perl \
	libcgi-pm-perl \
	libdbi-perl \
	libdbd-mysql-perl \
	libxml-simple-perl \
	# libmysqlclient-dev \
	default-libmysqlclient-dev \
	libgdal-dev \
	## new libs
	libglpk-dev \
	## Databases and other software
	sqlite \
	openmpi-bin \
	mpi-default-bin \
	openmpi-common \
	openmpi-doc \
	tcl8.6-dev \
	tk-dev \
	default-jdk \
	imagemagick \
	tabix \
	ggobi \
	graphviz \
	protobuf-compiler \
	jags \
	## Additional resources
	xfonts-100dpi \
	xfonts-75dpi \
	biber \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

## FIXME
## These two libraries don't install in the above section--WHY?
RUN apt-get update \
	&& apt-get -y --no-install-recommends install \
	libmariadb-dev-compat \
	libjpeg-dev \
	# libjpeg-turbo8-dev \
	# libjpeg8-dev \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# # Install libsbml and xvfb
RUN cd /tmp \
	## libsbml
	&& curl -O https://s3.amazonaws.com/linux-provisioning/libSBML-5.10.2-core-src.tar.gz \
	&& tar zxf libSBML-5.10.2-core-src.tar.gz \
	&& cd libsbml-5.10.2 \
	&& ./configure --enable-layout \
	&& make \
	&& make install \
	## Clean libsbml, and tar.gz files
	&& rm -rf /tmp/libsbml-5.10.2 \
	&& rm -rf /tmp/libSBML-5.10.2-core-src.tar.gz \
	## apt-get clean and remove cache
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

RUN echo "R_LIBS=/usr/local/lib/R/host-site-library:\${R_LIBS}" > /usr/local/lib/R/etc/Renviron.site

# install bioconductor dependencies
RUN Rscript -e 'remotes::install_cran(c("BiocManager", "Seurat", "rmarkdown", "reticulate", "pheatmap", "hdf5r"))' && \
  Rscript -e 'BiocManager::install(version="3.12", update=TRUE, ask=FALSE)' && \
  Rscript -e 'BiocManager::install(c("SingleCellExperiment", "GenomicFeatures", "rtracklayer", "Rsamtools", "scater"))'

# install miniconda and anndata
RUN Rscript -e 'remotes::install_github("rcannood/anndata"); reticulate::install_miniconda(); anndata::install_anndata()'

