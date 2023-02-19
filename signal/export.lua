-- classes
local new, registerClass, registerClassHandler, registerClassFunction, exportClass, importClass = loadstring(game:HttpGet("https://raw.githubusercontent.com/vozoid/classes/main/classHandler.lua"))()

-- signals

local wrap, yield, resume, running = coroutine.wrap, coroutine.yield, coroutine.resume, coroutine.running
local find, remove = table.find, table.remove
local random = math.random

registerClass("Signal", {active = false, count = 0, connections = {}, ids = {}})

registerClassFunction("Signal", "connect", function(self, handler, id)
    id = id or random(100000000, 999999999)
    self.connections[#self.connections + 1] = wrap(function(...)
        while true do
            handler(...)
            yield()
        end
    end)

    self.ids[#self.connections + 1] = id
    return id
end)

registerClassFunction("Signal", "disconnect", function(self, id)
    local idx = find(self.ids, id)
    remove(self.ids, idx)
    remove(self.connections, idx)
end)

registerClassFunction("Signal", "fire", function(self, ...)
    for _, handler in next, self.connections do
        handler(...)
    end
end)

registerClassFunction("Signal", "wait", function(self, ...)
    local thread = running()
    local id = math.random(100000000, 999999999)

    self.connect(id, function()
        resume(thread)
        self.disconnect(id)
    end)

    yield()
end)

registerClassFunction("Signal", "destroy", function(self)
    self.connections = {}
end)

return exportClass("Signal")
