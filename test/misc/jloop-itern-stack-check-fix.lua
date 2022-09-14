-- reproducer from Mike Pall for the fix in commit dad04f1754 in the official
-- v2.1 branch.

-- Trace exit (stack check) to JLOOP originating in ITERN.
do
    local function f(t)
        do
            local _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_
            local _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_
            local _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_
        end
        local n = 0
        for k in pairs(t) do
            n = n + 1
        end
        return n
    end

    local x = 0
    for i=1,20 do
        local t = {}
        for i=1,20 do t[i] = true end
        collectgarbage()
        x = x + f(t)
    end
    assert(x == 400)
end
