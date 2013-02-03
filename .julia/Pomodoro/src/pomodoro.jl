function pomodoro_stats(range::Range1{Int64})
  stats = chomp(readall(`/Users/purzelrakete/Dropbox/dot/bin/po-stats`))
  freqs = map(x -> int(x), split(stats, "\n"))
  plot(freqs[range])
end

function pomodoro_stats()
  pomodoro_stats(1:356)
end

