R -e "library('remotes'); install_local()"
/usr/bin/time -v Rscript tests/performance/big_deterministic.R
