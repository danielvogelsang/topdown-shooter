local Entity = require "entity"
local Utils = require "utils"
local Timer = require "timer"

local Enemy = Entity:extend()
local timer = Timer(2)

local enemy_image = love.graphics.newImage("sprites/zombie.png")

function Enemy:new(x, y, speed)
    if not x or not y then
        x, y = self:getRandomPosition()
    end
    speed = speed or 100
    Enemy.super.new(self, enemy_image, x, y, speed)
    --self.player_hit = false
    self.stun_time = nil
    self.knockback_force = -500
end

function Enemy:update(dt)
    if self:handleStun(dt) then return end
    self:handleMovement(dt, self.speed)
end

function Enemy:draw()
    love.graphics.draw(self.image, self.x, self.y, self:getPlayerAngle(),
    nil, nil, self.offset_width, self.offset_height)
end

function Enemy:handleMovement(dt, speed)
    local change_in_x = math.cos(self:getPlayerAngle()) * speed
    local change_in_y = math.sin(self:getPlayerAngle()) * speed
    self.x = self.x + change_in_x * dt
    self.y = self.y + change_in_y * dt

    self:avoidOtherEnemies()
end

function Enemy:avoidOtherEnemies()
    local minDistance = 30
    for _, other in ipairs(enemies) do
        if other ~= self then
            local distX = self.x - other.x
            local distY = self.y - other.y
            local distance = math.sqrt(distX^2 + distY^2)
            -- push away if too close
            if distance < minDistance then
                local pushForce = (minDistance - distance) * 0.5
                self.x = self.x + (distX / distance) * pushForce
                self.y = self.y + (distY / distance) * pushForce
            end
        end
    end
end

function Enemy:getPlayerAngle()
    return Utils.getAngle(self.x, self.y, player.x, player.y)
end

function Enemy:getBulletDistance(bullet_x, bullet_y)
    return Utils.distanceBetween(self.x, self.y, bullet_x, bullet_y)
end

function Enemy:getRandomPosition()
    local x, y
    local side = math.random(1, 4)
    -- left
    if side == 1 then
        x = -30
        y = math.random(0, love.graphics.getHeight())
    -- right
    elseif side == 2 then
        x = love.graphics.getWidth() + 30
        y = math.random(0, love.graphics.getHeight())
    -- top
    elseif side == 3 then
        x = math.random(0, love.graphics.getWidth())
        y = -30
    -- bottom
    elseif side == 4 then
        x = math.random(0, love.graphics.getWidth())
        y = love.graphics.getHeight() + 30
    end

    return x, y
end

function Enemy:handleStun(dt)
    if self.stun_time and self.stun_time > 0 then
        self.stun_time = self.stun_time - dt 
        self:handleMovement(dt, self.knockback_force)
        return true
    end
end

return Enemy