local clone = require"table.clone"
local nkeys = require"table.nkeys"
local c, n
local t = {idx = 0}

-- jit.off()

for i = 1, 100000 do
    t.idx = nil
    n = nkeys(t)
    c = clone(t)
    t.idx = i
end

-- print(n, c.idx)
assert(n==0)
assert(c.idx==nil)
