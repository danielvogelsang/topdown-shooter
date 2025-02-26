local Timer = Object:extend()

function Timer:new(time, callback, time_reduction, time_minimum)
    self.time = time
    self.callback = callback
    self.elapsed = 0
    self.time_reduction = time_reduction or 0
    self.time_minimum = time_minimum or 0
end

function Timer:update(dt)
    self.elapsed = self.elapsed + dt
    if self.elapsed >= self.time then
        self.callback()
        self.elapsed = 0
        if self.time > self.time_minimum then
            self.time = self.time - self.time_reduction
        end
    end
end

return Timer