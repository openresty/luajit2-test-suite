-- from Mike Pall

require "jit.opt".start("maxside=0")
local t={1}; for i=1,100 do for k,v in pairs(t) do end end
