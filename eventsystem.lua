local Event = {}

Event.listeners = {}

function Event:on(event_name, callback)
    if not self.listeners[event_name] then
        self.listeners[event_name] = {}
    end
    table.insert(self.listeners[event_name], callback)
end

function Event:emit(event_name)
    if self.listeners[event_name] then
        for _, callback in ipairs(self.listeners[event_name]) do
            callback()
        end
    end
end

return Event