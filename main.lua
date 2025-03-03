Object = require "classic"
local Globals = require "globals"
local Player = require "player"
local Enemy = require "enemy"
local Bullet = require "bullet"
local Timer = require "timer"
local GameManager = require "gamemanager"
local Event = require "eventsystem"
local Exp = require "exp"

math.randomseed(os.time())

function love.load()
    player = Player()
    enemy_timer = Timer(2, spawnEnemy, 0.1, 2)
    -- Event listeners
    Event:on("ShootBullet", function()
            table.insert(Globals.TABLES.BULLETS, Bullet())
            end)
    Event:on("PlayerDied", function()
            GameManager:setState(GameManager.GAME_STATE.MENU)
            end
            )
end

function love.update(dt)
    -- Resets if in mainmenu
    if GameManager:inMenu() then
        Globals:resetTables()
        player:resetPosition()
        player:resetTimers()
        return
    end

    -- Player updates
    player:update(dt)

    -- Enemy spawn timer
    enemy_timer:update(dt)

    -- Enemy updates
    local enemies = Globals:getTable("ENEMIES")
    for _, e in ipairs(enemies) do
        e:update(dt, enemies)
        -- Collision with player
        if player:checkEnemyCollision(e.x, e.y) then
            player:getHit(Globals.TABLES.ENEMIES)
            -- Currently does nothing as invulnerable gets instantly set to true again
            if not player.invulnerable then
                spawnBloodpool(player.x, player.y)
            end
        end
        -- Bullet collision with enemy
        for _, b in ipairs(Globals.TABLES.BULLETS) do
            if e:getBulletDistance(b.x, b.y) < 20 then
                spawnBloodpool(e.x, e.y)
                e.is_dead = true
                b.is_dead = true
            end
         end
    end
    for i = #enemies, 1, -1 do
        if enemies[i].is_dead then
            spawnExp(enemies[i])
            table.remove(enemies, i)
        end
    end

    -- Bullet updates
    local bullets = Globals:getTable("BULLETS")
    for _, b in ipairs(bullets) do
            b:update(dt)
    end
    for i = #bullets, 1, -1 do
        if bullets[i].is_dead then
            table.remove(bullets, i)
         end
    end
    -- Exp updates
    local exp = Globals:getTable("EXP")
    for i = #exp, 1, -1 do
        exp[i]:update(dt, player)
        if exp[i]:canCollect(player) then
            table.remove(exp, i)
        end
    end
end

function love.draw()
    -------- ALWAYS DRAWN --------
    -- Background
    love.graphics.draw(Globals.SPRITES.BACKGROUND, 0, 0)
    -- Blood
    for _, v in ipairs(Globals.TABLES.BLOODPOOL) do
        love.graphics.draw(Globals.SPRITES.BLOOD, v.x, v.y, v.rotation, v.scale, v.scale, v.ox, v.oy)
    end
    -- Exp
    for _, v in ipairs(Globals.TABLES.EXP) do
        v:draw()
    end
    -- Enemies
    for _, e in ipairs(Globals.TABLES.ENEMIES) do
         e:draw()
    end
    -- Bullets
    for _, b in ipairs(Globals.TABLES.BULLETS) do
        b:draw()
    end
    -- Player
    player:draw()
    -- Exp "bar"
    love.graphics.print("Experience: " .. player.exp, 10, 10)
    -- Lives
    for i = 1, player.max_lives do
        -- Full hearts
        if i <= player.lives then
            love.graphics.draw(Globals.SPRITES.LIFE, 5 + (i - 1) * 30, 50, nil, 2, 2)
        -- Lost hearts
        else
            love.graphics.draw(Globals.SPRITES.LOST_LIFE, 5 + (i - 1) * 30, 50, nil, 2, 2)
        end
    end

    -------- ONLY DRAWN IN MAINMENU --------
    if GameManager:inMenu() then
        love.mouse.setVisible(true)
        love.graphics.setFont(Globals.FONTS.FONTSIZE)
        love.graphics.printf("Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center")
    -------- ONLY DRAWN IN GAMELOOP --------
    elseif GameManager:inGame() then
        -- Crosshair
        love.graphics.draw(Globals.SPRITES.CROSSHAIR, love.mouse.getX(), 
        love.mouse.getY(), nil, 0.5, 0.5, Globals.SPRITES.CROSSHAIR:getWidth() / 2,
        Globals.SPRITES.CROSSHAIR:getHeight() / 2)
        love.mouse.setVisible(false)
    end

    -- DEBUGGING
     love.graphics.print("State " .. GameManager.current_state, 10, 100)
     love.graphics.print("Timer: " .. enemy_timer.time, 10, 150)
     love.graphics.print(#Globals.TABLES.BLOODPOOL, 10, 200)
     love.graphics.print(#Globals.TABLES.BULLETS, 10, 250)

end

function love.mousepressed(x, y, button)
    -- Change from mainmenu to game
    if button == 1 and GameManager:inMenu() then
        GameManager:setState(GameManager.GAME_STATE.GAME)
        player.experience = 0
        enemy_timer.time = 2
    end
end

function spawnEnemy()
    table.insert(Globals.TABLES.ENEMIES, Enemy())
end

function spawnBloodpool(entity_x, entity_y)
    table.insert(Globals.TABLES.BLOODPOOL, {
        x = entity_x,
        y = entity_y,
        scale = math.random(15, 20) / 10,
        rotation = math.rad(math.random(0, 360)),
        ox = Globals.SPRITES.BLOOD:getWidth() / 2,
        oy = Globals.SPRITES.BLOOD:getHeight() / 2
        })
end

function spawnExp(enemy)
    table.insert(Globals.TABLES.EXP, Exp(enemy, enemy.exp_value))
end