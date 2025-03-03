local Timer = Object:extend()

function Timer:new(time, callback, time_reduction, time_minimum, obj)
    self.time = time
    self.callback = callback
    self.obj = obj
    self.elapsed = 0
    self.active = true
    self.time_reduction = time_reduction or 0
    self.time_minimum = time_minimum or 0
end

function Timer:update(dt)
    if self.active then
        self.elapsed = self.elapsed + dt
        if self.elapsed >= self.time then
            if self.obj then
                self.callback(self.obj)
            else
                self.callback()
            end

            self.elapsed = 0
            if self.time > self.time_minimum then
                self.time = self.time - self.time_reduction
            end
        end
    end
end

function Timer:reset()
    self.elapsed = 0
    self.active = true
end

function Timer:stop()
    self.active = false
end

function Timer:start()
    self.active = true
end

return Timer