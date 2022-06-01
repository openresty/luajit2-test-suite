local t = {}
local ta = t
local s = 0
for i = 1, 1000 do
  ta[i] = i
  s = s + #t
end
assert(s==500500)
