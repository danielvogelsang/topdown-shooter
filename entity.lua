local Entity = Object:extend()

function Entity:new(image, x, y, speed)
    self.image = image
    self.x = x
    self.y = y
    self.speed = speed
    self.offset_width = self.image:getWidth() / 2
    self.offset_height = self.image:getHeight() / 2
end

return Entity