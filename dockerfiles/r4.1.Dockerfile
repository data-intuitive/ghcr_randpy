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
# https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/r-ver_4.1.3.Dockerfile
ENV R_VERSION=4.1.3
ENV TERM=xterm
ENV R_HOME=/usr/local/lib/R
ENV TZ=Etc/UTC

COPY scripts/install_R_source.sh /rocker_scripts/install_R_source.sh

RUN /rocker_scripts/install_R_source.sh

ENV CRAN=https://packagemanager.rstudio.com/cran/__linux__/focal/2022-04-21
ENV LANG=en_US.UTF-8

COPY scripts /rocker_scripts

RUN /rocker_scripts/setup_R.sh

## PART 3: install pandoc & rstudio
# https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/rstudio_4.1.3.Dockerfile
ENV S6_VERSION=v2.1.0.2
ENV RSTUDIO_VERSION=2022.02.1+461
ENV DEFAULT_USER=rstudio
ENV PANDOC_VERSION=default
ENV PATH=/usr/lib/rstudio-server/bin:$PATH

RUN /rocker_scripts/install_rstudio.sh
RUN /rocker_scripts/install_pandoc.sh

EXPOSE 8787

## PART 4: install tidyverse
# https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/tidyverse_4.1.3.Dockerfile
RUN /rocker_scripts/install_tidyverse.sh

## PART 5: install verse
# https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/verse_4.1.3.Dockerfile
ENV CTAN_REPO=https://www.texlive.info/tlnet-archive/2022/04/21/tlnet
ENV PATH=$PATH:/usr/local/texlive/bin/x86_64-linux
ENV QUARTO_VERSION=latest

RUN /rocker_scripts/install_verse.sh
RUN /rocker_scripts/install_quarto.sh

