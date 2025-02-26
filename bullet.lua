local Utils = require "utils"

local Bullet = Object:extend()

local bullet_image = love.graphics.newImage("sprites/bullet.png")

function Bullet:new(x, y, speed)
    self.image = bullet_image
    self.x = x or player.x
    self.y = y or player.y
    self.speed = speed or 500
    self.direction = self:getMouseAngle()
    self.offset_width = self.image:getWidth() / 2
    self.offset_height = self.image:getHeight() / 2
    self.is_dead = false
end

function Bullet:update(dt)
    self:handleMovement(dt)
    self:isOutOfScreen()
end

function Bullet:draw()
    love.graphics.draw(self.image, self.x, self.y, self.direction,
    0.5, 0.5, self.offset_width, self.offset_height)
end

function Bullet:handleMovement(dt)
    local change_in_x = math.cos(self.direction) * self.speed
    local change_in_y = math.sin(self.direction) * self.speed
    self.x = self.x + change_in_x * dt
    self.y = self.y + change_in_y * dt
end

function Bullet:getMouseAngle()
    return Utils.getAngle(self.x, self.y, love.mouse.getX(), love.mouse.getY())
end

function Bullet:isOutOfScreen()
    if Utils.outOfScreen(self.x, self.y) then
        self.is_dead = true
    end
end

return Bullet