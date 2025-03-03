local Entity = require "entity"
local Utils = require "utils"
local Event = require "eventsystem"
local Timer = require "timer"

local Player = Entity:extend()

local player_image = love.graphics.newImage("sprites/player.png")

function Player:new(x, y, speed)
    x = x or love.graphics.getWidth() / 2
    y = y or love.graphics.getHeight() / 2
    speed = speed or 200
    Player.super.new(self, player_image, x, y, speed)
    self.max_lives = 3
    self.lives = self.max_lives 
    -- weapon cooldown
    self.can_shoot = false
    self.fire_rate = 1
    self.wp_cd_timer = Timer(self.fire_rate, function() self.can_shoot = true end)
    -- invulnerability
    self.invuln_time = 1
    self.invuln_timer = 0
    self.invulnerable = false
    self.exp = 0
end

function Player:update(dt)
    self:handleMovement(dt)
    self:updateTimers(dt)
    self:dead()
    self:shoot()
end

function Player:draw()
    love.graphics.draw(self.image, self.x, self.y, self:getMouseAngle(),
    nil, nil, self.offset_width, self.offset_height)
end

function Player:handleMovement(dt)
    if love.keyboard.isDown("d")  then
        --if self.x + self.offset_width < love.graphics.getWidth() then
            self.x = self.x + self.speed * dt
        --end
    end
    if love.keyboard.isDown("a") then
        --if self.x - self.offset_width > 0  then
            self.x = self.x - self.speed * dt
        --end
    end
    if love.keyboard.isDown("w") then
        --if self.y - self.offset_width > 0 then
            self.y = self.y - self.speed * dt
        --end
    end
    if love.keyboard.isDown("s") then
        --if self.y + self.offset_width < love.graphics.getHeight() then
            self.y = self.y + self.speed * dt
        --end
    end
end

function Player:getMouseAngle()
    local mouseX, mouseY = love.mouse.getPosition()
    local worldMouseX, worldMouseY = camera:screenToWorld(mouseX, mouseY)
    return Utils.getAngle(self.x, self.y, worldMouseX, worldMouseY)
end

function Player:getHit(enemy_table)
    if self.invulnerable then return end
    self.invuln_timer = self.invuln_time
    self.invulnerable = true
    self:knockbackEnemies(200, enemy_table)
    self.lives = self.lives - 1
end

function Player:knockbackEnemies(radius, enemy_table)
    for _, enemy in ipairs(enemy_table) do
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
    self.exp = 0
end

function Player:shoot()
    if love.mouse.isDown(1) and self.can_shoot then
        self.can_shoot = false
        Event:emit("ShootBullet")
        self.wp_cd_timer:reset()
    end
end


function Player:updateTimers(dt)
    -- Weapon cooldown
    self.wp_cd_timer:update(dt)

    -- Invulnerabilty after getting hit
    if self.invuln_timer and self.invuln_timer > 0 then
        self.invuln_timer = self.invuln_timer - dt 
    else
        self.invulnerable = false
    end
end

function Player:resetTimers()
    self.invuln_timer = 0
    self.invulnerable = false
end

function Player:dead()
    if self.lives <= 0 then
        Event:emit("PlayerDied")
        self.lives = 3
    end
end

function Player:checkEnemyCollision(enemy_x, enemy_y)
    if Utils.distanceBetween(enemy_x, enemy_y, self.x, self.y) < 30 then
        return true
    end
end

return Player