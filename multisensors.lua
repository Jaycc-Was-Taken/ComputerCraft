-- By @Coolacid
-- Detect players and display their name on a monitor or a Glass Hud
-- Multiple Sensors using modems and network cable - Sensors by default detect in a 5x5x5 area
-- Place a modem on the Advanced Computer, then apply network cable to your locations
-- Place a new Sensor on top of the cable, and attach a modem
-- Click on the modem to activate it on the network

-- To get started:

-- label set SomeKindOfNameHere
-- pastebin get WdiT6sR5 bootstrap
-- bootstrap
-- github get coolacid/ComputerCraft/master/multisensors.lua startup
-- startup

-- Use Glasses instead of a monitor
use_glasses = false

-- Show current server time on glasses
glasses_time = true

local radars = {}

for _, name in pairs(peripheral.getNames()) do
  if peripheral.getType(name) == "openperipheral_sensor" then
    print ("Found: " .. name)
    table.insert(radars, peripheral.wrap(name))
  end
end

if use_glasses then
  -- Setup to find and use the glasses bridge
  lines = {}
  glass = peripheral.find("openperipheral_bridge")
  glass.clear()
  if glasses_time then
    glasstime = glass.addText(5,2,"Time: ", 0xFF0000)
  end
else
  monitor = peripheral.find("monitor")
end

-- Ripped from http://stackoverflow.com/a/1283608
function tableMerge(t1, t2)
    for k,v in pairs(t2) do
    	if type(v) == "table" then
    		if type(t1[k] or false) == "table" then
    			tableMerge(t1[k] or {}, t2[k] or {})
    		else
    			t1[k] = v
    		end
    	else
    		t1[k] = v
    	end
    end
    return t1
end

function timeDis()
  time = textutils.formatTime(os.time(), false)
  glasstime.setText("Time: " .. time)
end

function ClearLines()
  for k,v in pairs(lines) do
    lines[k].setText("")
  end
end

function deDupe(items)
  flags = {}
  res = {}
  for _,item in pairs(items) do
   if not flags[item.name] then
      table.insert(res, item)
      flags[item.name] = true
   end
  end
  return res
end

function getTargets()
  players = {}
  for _, radar in pairs (radars) do
    for _, player in pairs (radar.getPlayers()) do
--      This currently reports relitive to the radar not the world. 
--      playerlocation = radar.getPlayerByName(player.name).position
--      player['location'] = math.floor(playerlocation.x) .. "," .. math.floor(playerlocation.y) .. "," .. math.floor(playerlocation.z)
      table.insert(players,player)
    end
  end
  return deDupe(players)
end

function Glasses_Targets(newplayers)
  if glasses_time then
    i=10
  else 
    i=1
  end
  for k,v in pairs(newplayers) do
    if lines[i] == nil then
      lines[i] = glass.addText(5,i,"Player Detected: " .. v.name, 0xFF0000)
    else
      lines[i].setText("Player Detected: " .. v.name)
    end
    i=i+10
  end
end

function Monitor_Target(newplayers)
  monitor.clear()
  i=1
  for k,v in pairs(newplayers) do
    monitor.setCursorPos(1,i)
    monitor.write("Player Detected: " .. v.name) --  .. " - " .. v.location)
    i=i+1
  end
end

function start()
  while true do
    targets = getTargets()
    if use_glasses then
      if glasses_time then
        timeDis()
      end
      ClearLines()
      Glasses_Targets(targets)
      glass.sync()
    else
      Monitor_Target(targets)
    end
    sleep(0.1)
  end
end

start()
