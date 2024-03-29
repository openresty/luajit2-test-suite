
local function f()
  f()
end

local err, s = xpcall(f, debug.traceback)
assert(err == false)

local first = string.match(s, "[^\n]+")
local line = debug.getinfo(f, "S").linedefined+1

print("[[" .. first .. "]]")
-- stackov.lua:2: stack overflow
assert(string.match(first, ":"..line..": stack overflow$") or
       string.match(first, "error in error handling") or
       first == "stack overflow" or
       first == "stackov.lua:2: stack overflow")

local n = 1
for _ in string.gmatch(s, "\n") do n = n + 1 end
assert(n == 1+1+11+1+10 or n == 1)

local function g(i)
  g(i)
end

local err, s = xpcall(g, debug.traceback, 1)
assert(err == false)

--[[
-- too slow
local function vtail(...)
  return vtail(1, ...)
end

local err, s = xpcall(vtail, debug.traceback, 1)
assert(err == false)
--]]

local function vcall(...)
  vcall(1, ...)
end

local err, s = xpcall(vcall, debug.traceback, 1)
assert(err == false)

