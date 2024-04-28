-- from Mike Pall

if jit and jit.opt then jit.opt.start("maxside=0") end
local t={1}; for i=1,100 do for k,v in pairs(t) do end end
