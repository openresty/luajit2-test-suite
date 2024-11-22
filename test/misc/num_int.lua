local bit         = require("bit")
local find_str    = string.find
local tonumber    = tonumber
local ipairs      = ipairs
local pairs       = pairs
local ffi         = require "ffi"
local ffi_cdef    = ffi.cdef
local ffi_copy    = ffi.copy
local ffi_new     = ffi.new
local C           = ffi.C
local sort_tab    = table.sort
local string      = string
local setmetatable=setmetatable
local type        = type
local error       = error
local str_sub     = string.sub
local str_byte    = string.byte

local AF_INET     = 2
local AF_INET6    = 10
if ffi.os == "OSX" then
    AF_INET6 = 30
elseif ffi.os == "BSD" then
    AF_INET6 = 28
elseif ffi.os == "Windows" then
    AF_INET6 = 23
end


local _M = {_VERSION = 0.3}


ffi_cdef[[
    int inet_pton(int af, const char * restrict src, void * restrict dst);
    uint32_t ntohl(uint32_t netlong);
]]


local parse_ipv4
do
    local inet = ffi_new("unsigned int [1]")

    function parse_ipv4(ip)
        if not ip then
            return false
        end

        if C.inet_pton(AF_INET, ip, inet) ~= 1 then
            return false
        end

        return C.ntohl(inet[0])
    end
end
_M.parse_ipv4 = parse_ipv4

local mt = {__index = _M}


local function split_ip(ip_addr_org)
    local idx = find_str(ip_addr_org, "/", 1, true)
    if not idx then
        return ip_addr_org
    end

    local ip_addr = str_sub(ip_addr_org, 1, idx - 1)
    local ip_addr_mask = str_sub(ip_addr_org, idx + 1)
    return ip_addr, tonumber(ip_addr_mask)
end
_M.split_ip = split_ip


local idxs = {}

local function cmp(x, y)
    return x > y
end


local function new(ips, with_value)
    if not ips or type(ips) ~= "table" then
        error("missing valid ip argument", 2)
    end

    local parsed_ipv4s = {}
    local parsed_ipv4s_mask = {}
    local ipv4_match_all_value

    local iter = with_value and pairs or ipairs
    for a, b in iter(ips) do
        local ip_addr_org, value
        if with_value then
            ip_addr_org = a
            value = b

        else
            ip_addr_org = b
            value = true
        end

        local ip_addr, ip_addr_mask = split_ip(ip_addr_org)

        local inet_ipv4 = parse_ipv4(ip_addr)
        if inet_ipv4 then
            ip_addr_mask = ip_addr_mask or 32
            if ip_addr_mask == 32 then
                parsed_ipv4s[inet_ipv4] = value

            elseif ip_addr_mask == 0 then
                ipv4_match_all_value = value

            else
                local valid_inet_addr = bit.rshift(inet_ipv4, 32 - ip_addr_mask)

                parsed_ipv4s_mask[ip_addr_mask] = parsed_ipv4s_mask[ip_addr_mask] or {}
                parsed_ipv4s_mask[ip_addr_mask][valid_inet_addr] = value
            end

            goto continue
        end

        if not inet_ipv4 and not inets_ipv6 then
            return nil, "invalid ip address: " .. ip_addr
        end

        ::continue::
    end

    local ipv4_mask_arr = {}
    local i = 1
    for k, _ in pairs(parsed_ipv4s_mask) do
        ipv4_mask_arr[i] = k
        i = i + 1
    end

    sort_tab(ipv4_mask_arr, cmp)

    return setmetatable({
        ipv4 = parsed_ipv4s,
        ipv4_mask = parsed_ipv4s_mask,
        ipv4_mask_arr = ipv4_mask_arr,
        ipv4_match_all_value = ipv4_match_all_value,
    }, mt)
end

function _M.new(ips)
    return new(ips, false)
end

local function match_ipv4(self, ip)
    local ipv4s = self.ipv4
    local value = ipv4s[ip]
    if value ~= nil then
        return value
    end

    local ipv4_mask = self.ipv4_mask
    if self.ipv4_match_all_value ~= nil then
        return self.ipv4_match_all_value -- match any ip
    end

    for _, mask in ipairs(self.ipv4_mask_arr) do
        local valid_inet_addr = bit.rshift(ip, 32 - mask)

        value = ipv4_mask[mask][valid_inet_addr]
        if value ~= nil then
            return value
        end
    end

    return false
end

function _M.match(self, ip)
    local inet_ipv4 = parse_ipv4(ip)
    if inet_ipv4 then
        return match_ipv4(self, inet_ipv4)
    end
end

local ip = _M.new({
    "192.168.0.0/16",
})

assert(ip:match("127.0.0.3") == false)
