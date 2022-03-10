-- from Mike Pall

do
  local xnext = next
  local t = {1}
  local function f() end
  for i=1,100 do
    f(xnext(t))
  end
end
