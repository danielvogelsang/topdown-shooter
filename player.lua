local Entity = require "entity"
local Utils = require "utils"

local Player = Entity:extend()

local player_image = love.graphics.newImage("sprites/player.png")

function Player:new(x, y, speed)
    x = x or love.graphics.getWidth() / 2
    y = y or love.graphics.getHeight() / 2
    speed = speed or 200
    Player.super.new(self, player_image, x, y, speed)
    self.max_lives = 3
    self.lives = self.max_lives 
    self.weapon_cd = 1
    self.weapon_timer = self.weapon_cd
    self.invuln_time = 1
    self.invuln_timer = 0
    self.invulnerable = false
    self.transparence = 1
end

function Player:update(dt)
    self:handleMovement(dt)
    self:updateTimers(dt)
    self:dead()
end

function Player:draw()
    local color = {1, 1, 1, self.transparence}
    if game_state == 2 then
        if self.lives == 2 then
            color = {0.6, 0, 0, self.transparence}
        elseif self.lives < 2 then
            color = {1, 0, 0, self.transparence}
        end
    end
    
    love.graphics.setColor(color)
    love.graphics.draw(self.image, self.x, self.y, self:getMouseAngle(),
    nil, nil, self.offset_width, self.offset_height)
    love.graphics.setColor(1, 1, 1)
end

function Player:handleMovement(dt)
    if love.keyboard.isDown("d")  then
        if self.x + self.offset_width < love.graphics.getWidth() then
            self.x = self.x + self.speed * dt
        end
    end
    if love.keyboard.isDown("a") then
        if self.x - self.offset_width > 0  then
            self.x = self.x - self.speed * dt
        end
    end
    if love.keyboard.isDown("w") then
        if self.y - self.offset_width > 0 then
            self.y = self.y - self.speed * dt
        end
    end
    if love.keyboard.isDown("s") then
        if self.y + self.offset_width < love.graphics.getHeight() then
            self.y = self.y + self.speed * dt
        end
    end
end

function Player:getMouseAngle()
    return Utils.getAngle(self.x, self.y, love.mouse.getX(), love.mouse.getY())
end

function Player:getHit()
    if self.invulnerable then return end
    self.invuln_timer = self.invuln_time
    self.invulnerable = true
    self:knockbackEnemies(200)
    self.lives = self.lives - 1
end

function Player:knockbackEnemies(radius)
    for _, enemy in ipairs(enemies) do
        local dx = enemy.x - self.x
        local dy = enemy.y - self.y
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance < radius and distance > 0 then 
            enemy.stun_time = enemy.stun_duration
        end
    end
end

function Player:resetPosition()
    self.x = love.graphics.getWidth() / 2
    self.y = love.graphics.getHeight() / 2
end

function Player:canShoot()
    if love.mouse.isDown(1) and game_state == 2 then
        if self.weapon_timer < 0 then
            self.weapon_timer = self.weapon_cd
            return true
        end
    else 
        return false
    end
end

function Player:updateTimers(dt)
    -- weapon cooldown
    if self.weapon_timer and self.weapon_timer > 0 then
        self.weapon_timer = self.weapon_timer - dt
    end

    -- invulnerabilty after getting hit
    if self.invuln_timer and self.invuln_timer > 0 then
        self.transparence = 0.5
        self.invuln_timer = self.invuln_timer - dt 
    else
        self.invulnerable = false
        self.transparence = 1
    end
end

function Player:resetTimers()
    self.invuln_timer = 0
    self.invulnerable = false
    self.transparence = 1
end

function Player:dead()
    if self.lives <= 0 then
        game_state = 1
        self.lives = 3
    end
end

function Player:checkEnemyCollision(enemy_x, enemy_y)
    if Utils.distanceBetween(enemy_x, enemy_y, player.x, player.y) < 30 then
        return true
    end
end

return Player