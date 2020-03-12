#!/usr/bin/env lua

-- DATE -- os.date
-- KEY LEDS -- /sys/class/leds
-- LOAD AVERAGE (CPU) -- /proc/loadavg
-- MEMORY -- /proc/meminfo
-- SWAP -- /proc/meminfo
-- TEMPERATURS -- /sys/class/hwmon
-- BATTERIES -- /sys/class/power_supply
-- NETWORK?

local LOCK_FILE = "/tmp/dwmstatus-lua.lock"

local ph = nil
local k = ""
local data = {
  date = "",
  keys = "",
  loadavg = "",
  mem = "",
  swap = "",
  temps = "",
  batts = "",
}

function slurp(file)
  local f = io.open(file)
  local a = f:read("*a")
  f:close()
  return a
end

function getValues(file, amount)
  local a = amount or 1
  local o = {}
  local fh = io.open(file)
  for i=1, a do
    o[#o+1] = fh:read("*n")
  end
  fh:close()
  if a == 1 then
    return o[1]
  end
  return o
end

function keyLedOn(k, file, name, letter)
  if file:match(".*"..name.."$") then
    if getValues(file.."/brightness") > 0 then
      k = k .. letter
    end
  end
  return k
end

math.randomseed(os.time())
math.random()
math.random()
math.random()

local semaphore = math.random(0, 65535)

ph = io.open(LOCK_FILE, "w")
ph:write(semaphore)
ph:close()

while getValues(LOCK_FILE) == semaphore do
  data.date = os.date("%Y-%m-%d %H:%M:%S %a")

  ph = io.popen("find '/sys/class/leds' -type l")
  k = ""
  for file in ph:lines() do
    k = keyLedOn(k, file, "capslock", "C")
    k = keyLedOn(k, file, "compose", "O")
    k = keyLedOn(k, file, "numlock", "N")
    k = keyLedOn(k, file, "kana", "K")
    k = keyLedOn(k, file, "scrolllock", "S")
  end
  data.keys = "K: ["..k.."]"
  ph:close()

  local la = getValues("/proc/loadavg", 3)
  k = ""
  for i=1, 3 do
    if i>1 then
      k = k.." "
    end
    k = k..la[i]
  end
  data.loadavg = "L: "..k

  local mt, ma, st, sf;
  fh = io.open("/proc/meminfo")
  for line in fh:lines() do
    mt = tonumber(line:match("^MemTotal:%s+([0-9]+)")) or mt
    ma = tonumber(line:match("^MemAvailable:%s+([0-9]+)")) or ma
    st = tonumber(line:match("^SwapTotal:%s+([0-9]+)")) or st
    sf = tonumber(line:match("^SwapFree:%s+([0-9]+)")) or sf
  end
  fh:close()
  data.mem = string.format("M: %d%%", math.floor((1-ma/mt)*100))
  data.swap = st > 0 and string.format("S: %d%%", math.floor((1-sf/st)*100)) or ""

  ph = io.popen("find '/sys/class/hwmon' -type l")
  k = ""
  for dir in ph:lines() do
    local n = slurp(dir.."/name"):sub(1, 1)
    local p1 = io.popen("find '"..dir.."/' -type f")
    local t = {}
    for file in p1:lines() do
      if file:match(".*temp[0-9]+_input$") then
        t[#t+1] = string.format("%.1f", tonumber(slurp(file))/1000)
      end
    end
    if #t > 0 then
      k = k.." "..n.."("
      for i=1, #t do
        if i > 1 then
          k = k.." "
        end
        k = k..t[i].."°C"
      end
      k = k..")"
    end
  end
  if #k > 0 then
    data.temps = "T:"..k
  end

  ph = io.popen("find '/sys/class/power_supply' -type l")
  k = ""
  for dir in ph:lines() do
    if dir:match(".*BAT[0-9]+$") then
      local efd = slurp(dir.."/energy_full_design");
      local ef = slurp(dir.."/energy_full");
      local en = slurp(dir.."/energy_now");
      local s = slurp(dir.."/status");
      local bs = '?'
      if s == 'Discharging' then
        bs = '-'
      elseif s == 'Charging' then
        bs = '+'
      elseif s == 'Full' then
        bs = ''
      end
      k = k.." "..string.format("%.1f%%(%d)", en/efd*100, en/ef*100)..bs
    end
  end
  if #k > 0 then
    data.batts = "B:"..k
  end

  local status = data.mem.." | "..data.loadavg.." | "..data.keys.." | "..data.date
  if #data.swap > 0 then
    status = data.swap.." | "..status
  end
  if #data.batts > 0 then
    status = data.batts.." | "..status
  end
  if #data.temps > 0 then
    status = data.temps.." | "..status
  end

  local cmd = "xsetroot -name '"..status.."'"

  --print(cmd)
  io.popen(cmd)

  os.execute("sleep 1s")
end
