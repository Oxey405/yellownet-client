---@alias Packet {ID: string, TYPE: 'SYS' | 'GTW' | 'REQ' | 'ASW' | 'MSG', RESOURCE: string, BODY: string | table}
yellownet = {
    gateway = false,
    server = false,
    ID = 0,
    lastPacket = {ID="", TYPE="", RESOURCE="", BODY=""},
    ---@param packet Packet
    onPacketRecieved = function (packet)
        print("No onPacketRecieved")
    end,
    onConnected = function ()
        print("No onConnected")
    end,
    ---@type fun(packet: Packet)[]
    onGoingRequests = {}
}
function yellownet.decodePacket(rawPacketString)
    -- Thanks arthur
    local elements = {ID="", TYPE="", RESOURCE="", BODY=""}
    local e = "ID";
    local escape = false
    for i = 1, #rawPacketString do
        local c = rawPacketString:sub(i,i)
        if escape then
          escape = false
          elements[e] = elements[e] .. c
          goto continue 
        end
        if c == "\\" then escape = true goto continue end
        if e=="ID" and c == "." then e = "TYPE" goto continue end
        if e=="TYPE" and c == ";" then e = "RESOURCE" goto continue end
        if e=="RESOURCE" and c == "|" then e = "BODY" goto continue end
        elements[e] = elements[e] .. c
        ::continue::
    end
    return elements
end

function yellownet.handlePacket(rawPacketString)
    yellownet.ID = yellownet.ID + 1
    local packet = yellownet.decodePacket(rawPacketString)
    if packet.TYPE == "SYS" then
        if packet.RESOURCE == "gateway_init" then
            yellownet.gateway = true
            print('0.GTW;set_address|localhost:2278')
        end
        if packet.RESOURCE == "server_init" then
            yellownet.server = true
            yellownet.onConnected()
        end
    else
        if packet.TYPE == "ASW" then
            -- Callback
            local id = packet.ID .. ""
            print(id)
            local cb = yellownet.onGoingRequests[id]
            printTable(yellownet.onGoingRequests)
            if cb ~= nil then
                cb(packet)
                yellownet.onGoingRequests[id] = nil -- And let the garbage collector do its magic
            end
        end
        yellownet.onPacketRecieved(packet)
    end
end
---Sends a packet to the current server (shouldn't be used directly for REQ packets)
---@param method 'SYS' | 'GTW' | 'REQ' | 'ASW' | 'MSG'
---@param resource string
---@param body string
function yellownet.sendPacket(method, resource, body)
    print(yellownet.ID .. "." .. method .. ";" .. resource .. "|" .. body)
end

---Sends a request
---@param resource string
---@param body string
---@param callback fun(packet: Packet)
function yellownet.sendRequest(resource, body, callback)
    yellownet.ID = yellownet.ID + 1
    print(yellownet.ID .. "." .. "REQ" .. ";" .. resource .. "|" .. body)
    print(yellownet.ID)
    yellownet.onGoingRequests[yellownet.ID .. ""] = callback;
end