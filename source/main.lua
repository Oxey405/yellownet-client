SYS_MENU = playdate.getSystemMenu()
SHOW_CRANK = false

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/animation"
import "CoreLibs/math"
import "CoreLibs/nineslice"

import "yellownet.lua"

-- YOU CAN REPLACE THE MAIN FILE AND JUST USE YELLOWNET.LUA LIBRARY
-- This example connects to the 

local gfx <const> = playdate.graphics
local noteSynth = playdate.sound.synth.new(playdate.sound.kWaveSine)

local messages = ""
local weather = {
  status = "Unknown",
  temp = "?? C"
}

yellownet.onConnected = function ()
  yellownet.sendRequest('weather', 'empty', function (packet)
    print(packet.BODY)
    weather = json.decode(packet.BODY--[[@as string]])

  end)
  noteSynth:playNote(523.25, 0.5, 0.1)

end
---@param packet Packet
yellownet.onPacketRecieved = function (packet)
  -- we can do something here lol
end
function playdate.update()
  gfx.clear()
  gfx.drawTextAligned("*The Weather Channel*", 200, 20, kTextAlignment.center)
  gfx.drawTextAligned("_Connect your Playdate to your computer_\nThen go on yellownet.oxey405.com", 200, 50, kTextAlignment.center)
  gfx.drawTextAligned("Weather        : " .. weather.status .. "\nTemperature : " .. weather.temp, 100, 100, kTextAlignment.left)

end

function playdate.serialMessageReceived(message)

  noteSynth:playNote(261.63, 0.5, 0.1)
  yellownet.handlePacket(message)

end
