local t = {1,2,3,4,5}
local tab = {a=t,b=t,c=t,d=t,e=t}

local function f(...)
	for j=1,100 do end
end

for i=1, 100000 do
	f() -- force return to interpreter
	local c = 0
	for k,v in pairs(tab) do   -- this will eventually be blacklisted and patched to ITERC/JMP
		for _ in pairs(v) do end
		c = c+1
	end
	assert(c == 5)  -- eventually c=1
end
