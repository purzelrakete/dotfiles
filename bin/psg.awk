#!/usr/bin/awk -f

!/grep |psg/ {
  results += 1
  printf("%5d %5d ", $2, $3)
  print $8 $9 $10
}

END {
  if(results == 0) {
    exit(1)
  }
}

# user defined functions

function from(n) {
  for(i = n; i < NF; i++) { printf($i) }
  printf "\n"
}

