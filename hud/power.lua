local component = require("component")

-- (addr, {data})
local glasses_addr = nil
local power_buffer_addr = nil

-- Setup component addresses
for address, componentType in component.list() do
    if componentType == "glasses" then glasses_addr = address end
    if componentType == "gt_machine" then power_buffer_addr = address end
end

local maxEU = nil
local currentEU = nil
local previousEU = {}
local lastEU = nil
local averageChange = 0

if glasses_addr == nil then
    error("Needs glasses terminal connected.")
end

if power_buffer_addr == nil then
    error("Needs glasses terminal connected.")
end

local glasses = component.proxy(glasses_addr)
local buffer = component.proxy(power_buffer_addr)

function update() 
    maxEU = buffer.getEUCapacity()
    currentEU = buffer.getEUStored()

    if #previousEU >= 10 then
        averageChange = (previousEU[10] - previousEU[1]) / 10
    end

    -- Last 10s of eu
    if lastEU ~= nil then
        table.insert(previousEU, currentEU - lastEU)
        if #previousEU > 10 then
            table.remove(previousEU, 1)
        end
    end

    lastEU = currentEU
end

while true do
    update()
    print(currentEU, averageChange)
    os.sleep(1)
end
