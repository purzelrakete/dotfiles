#!/usr/bin/awk -f

!/grep |psg/ {
  printf("%5d %5d ", $2, $3); print $8 $9 $10
}

# user defined functions

function from(n) {
  for(i = n; i < NF; i++) { printf($i) }
  printf "\n"
}

