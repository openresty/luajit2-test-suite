if jit and jit.opt then jit.opt.start("hotloop=2", "hotexit=1", "maxsnap=9") end

local m = 1

local function foo(n)
    m = m + n
    if n >= 2 then
        m = m * n
    end
end

foo(1); foo(1); foo(1); foo(1); foo(1); foo(1);

local tb = {
    foo = 1,
    bar = 2,
}

local function bar()
    for i = 2, 3 do
        foo(i);
    end

    tb.foo = 10

    print(tb.foo)
end

bar()

print(m)
