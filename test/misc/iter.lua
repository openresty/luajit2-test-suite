
do
  local n = 0
  for k,v in pairs(_G) do
    assert(_G[k] == v)
    n = n + 1
  end
  assert(n >= 40)
end

do
  local t = { 4,5,6,7,8,9,10 }
  local n = 0
  for i,v in ipairs(t) do
    assert(v == i+3)
    n = n + 1
  end
  assert(n == 7)
end

do
  local function count(t)
    local n = 0
    for i,v in pairs(t) do
      n = n + 1
    end
    return n;
  end
  assert(count({ 4,5,6,nil,8,nil,10}) == 5)
  assert(count({ [0] = 3, 4,5,6,nil,8,nil,10}) == 6)
  assert(count({ foo=1, bar=2, baz=3 }) == 3)
  assert(count({ foo=1, bar=2, baz=3, boo=4 }) == 4)
  assert(count({ 4,5,6,nil,8,nil,10, foo=1, bar=2, baz=3 }) == 8)
  local t = { foo=1, bar=2, baz=3, boo=4 }
  t.bar = nil; t.boo = nil
  assert(count(t) == 2)
end

do
  local t = {}
  for i=1,100 do t[i]=i end
  local n = 0
  for i,v in ipairs(t) do
    assert(i == v)
    n = n + 1
  end
  assert(n == 100)
end

do
  local ok, err = pcall(next, _G, 1)
  assert(not ok)
  local ok, err = pcall(function() next(_G, 1) end)
  assert(not ok)
end

do
  local xnext, pcall = next, pcall
  local t, q = {}, {}
  for i=1,100 do t[i] = { foo = "bar" } end
  t[90] = { baz = "bar" }
  for i=1,100 do
    q[i] = pcall(xnext, t[i], "foo")
  end
  assert(q[89] == true)
  assert(q[90] == false)
  assert(q[91] == true)
end

do
  local t = {}
  local o = {{}, {}}
  for i=1,100 do
    local c = i..""
    t[i] = c
    o[1][c] = i
    o[2][c] = i
  end
  o[1]["90"] = nil

  for _, c in ipairs(t) do
    for i = 1, 2 do
      o[i][c] = o[i][c] or 1
    end
  end
end

do -- Deoptimize ITERN during array traversal
  local t = { foo = 9, bar = 10, 4, 5, 6 }
  local r = {}
  local function dummy() end
  local function f(next)
    for k,v in next,t,nil do r[#r+1] = k; if v == 5 then f(dummy) end end
  end
  f(next)
  assert(#r == 5)
end

do -- Deoptimize ITERN during hash traversal
  local t = {}
  for i=1,50 do t[tostring(i)] = i end
  local r = {}
  local function dummy() end
  local function f(next)
    for k,v in next,t,nil do r[#r+1] = k; if v == 25 then f(dummy) end end
  end
  f(next)
  assert(#r == 50)
end

do -- Deoptimize ITERN during hash traversal, even when JIT-compiled to JLOOP
  local t = {}
  for i=1,200 do t[tostring(i)] = i end
  local r = {}
  local function dummy() end
  local function f(next)
    for k,v in next,t,nil do r[#r+1] = k; if v == 100 then f(dummy) end end
  end
  f(next)
  assert(#r == 200)
end

do
  local xnext, select = next, select
  local te, th, ta, ta0 = {}, { foo = 42 }, { "a" }, { [0] = "a", "b" }
  for i=1,100 do
    assert(xnext(te) == nil)
    assert(select('#', xnext(te)) == 1)

    local k1, v1 = xnext(th)
    assert(k1 == "foo" and v1 == 42)
    assert(xnext(th, k1) == nil)

    local k2, v2 = xnext(ta)
    assert(k2 == 1 and v2 == "a")
    assert(xnext(ta, k2) == nil)

    local k3, v3 = xnext(ta0)
    assert((k3 == 0 and v3 == "a") or (k3 == 1 and v3 == "b"))
    local k4, v4 = xnext(ta0, k3)
    assert((k3 == 1 and k4 == 0 and v4 == "a") or (k3 == 0 and k4 == 1 and v4 == "b"))
    assert(xnext(ta0, k4) == nil)
  end
end

do
  local type, tonumber, tostring = type, tonumber, tostring

  local t = {}
  for i=1,30 do t[i] = 30-i end
  for i=1,100 do
    t["A"..i] = i+1.5
    t["B"..i] = "V"..i
  end

  local x1 = 0
  for i=1,10 do for k in pairs(t) do x1 = x1 + 1 end end
  assert(x1 == 10*230)

  for i=1,10 do
    for k,v in pairs(t) do
      if type(k) == "number" then
	assert(v == 30-k)
      else
	local ki = tonumber(k:sub(2))
	if k:byte() == 0x41 then
	  assert(v == ki+1.5)
	else
	  assert(v == "V"..ki)
	end
      end
    end
  end

  local xnext = next
  local x2 = 0
  for i=1,10 do for k in xnext,t,nil do x2 = x2 + 1 end end
  assert(x2 == 10*230)
end

do -- Check for DSE prevention
  local xnext = next
  local t = {}
  for i=1,100 do t[i] = i end
  for i=1,100 do
    t[90] = 90
    local k, v = xnext(t, 89)
    assert(k == 90 and v == 90)
    t[90] = 999
  end
  assert(t[90] == 999)
end

