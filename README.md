# randpy: R and Python in one container

This container provides installations for both R and Python. Check out the randpy builds at [https://hub.docker.com/r/dataintuitive/randpy](https://hub.docker.com/r/dataintuitive/randpy).

The randpy Dockerfile is a result of combining the following Dockerfiles:
* [https://github.com/docker-library/buildpack-deps/blob/master/debian/buster/curl/Dockerfile](https://github.com/docker-library/buildpack-deps/blob/master/debian/buster/curl/Dockerfile)
* [https://github.com/docker-library/buildpack-deps/blob/master/debian/buster/scm/Dockerfile](https://github.com/docker-library/buildpack-deps/blob/master/debian/buster/scm/Dockerfile)
* [https://github.com/docker-library/buildpack-deps/blob/master/debian/buster/Dockerfile](https://github.com/docker-library/buildpack-deps/blob/master/debian/buster/Dockerfile)
* [https://github.com/rocker-org/rocker-versioned/blob/master/r-ver/3.6.3.Dockerfile](https://github.com/rocker-org/rocker-versioned/blob/master/r-ver/3.6.3.Dockerfile)
* [https://github.com/rocker-org/rocker-versioned/blob/master/tidyverse/3.6.3.Dockerfile](https://github.com/rocker-org/rocker-versioned/blob/master/tidyverse/3.6.3.Dockerfile)
* [https://github.com/rocker-org/rocker-versioned/blob/master/verse/3.6.3.Dockerfile](https://github.com/rocker-org/rocker-versioned/blob/master/verse/3.6.3.Dockerfile)
* [https://github.com/docker-library/python/blob/master/3.8/buster/Dockerfile](https://github.com/docker-library/python/blob/master/3.8/buster/Dockerfile)
