local Utils = require "utils"
local Entity = require "entity"

local Exp = Entity:extend()

local exp_image = love.graphics.newImage("sprites/experience.png")

function Exp:new(enemy, amount)
    self.amount = amount or 1
    self.speed = 200
    self.scale = 1.2
    self.rotation = math.rad(math.random(0, 360))
    self.pickup_range = 10
    self.magnet_range = 200
    Exp.super.new(self, exp_image, enemy.x, enemy.y, self.speed)
end

function Exp:update(dt, player)
    if self:inMagnetRange(player) then
        local angle = Utils.getAngle(self.x, self.y, player.x, player.y)
        self.x = self.x + math.cos(angle) * self.speed * dt
        self.y = self.y + math.sin(angle) * self.speed * dt
    end

    if self:canCollect(player) then
        player.exp = player.exp + self.amount
    end
end

function Exp:draw()
    love.graphics.draw(self.image, self.x, self.y, self.rotation,
    self.scale, self.scale, self.offset_width, self.offset_height)
end

function Exp:inMagnetRange(player)
    return Utils.distanceBetween(player.x, player.y, self.x, self.y)
    < self.magnet_range
end

function Exp:canCollect(player)
    if Utils.distanceBetween(player.x, player.y, self.x, self.y)
    < self.pickup_range then
        return true
    end
end

return Exp