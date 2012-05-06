#!/bin/ruby

rows = File.open('list.txt', 'r') do |f|
  f.readlines
end

counter = 0

rows.each do |row|
  filename = "say -v victoria -o %03d.m4a --data-format=alac #{row}" % counter
  system filename
  counter += 1
end
