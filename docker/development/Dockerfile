FROM r-base:3.6.1

RUN apt-get update && apt-get install -y \
  libcurl4-openssl-dev \
  libssl-dev \
  libxml2-dev

RUN R -e "install.packages(c('devtools', 'roxygen2', 'testthat', 'knitr'))"
