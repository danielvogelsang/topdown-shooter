Object = require "classic"
local Player = require "player"
local Enemy = require "enemy"
local Bullet = require "bullet"
local Timer = require "timer"

math.randomseed(os.time())

function love.load()
    -- 1 = mainmenu, 2 = gameloop
    game_state = 1
    score = 0

    backround = love.graphics.newImage("sprites/background.png")
    game_font = love.graphics.newFont(30)

    player = Player()

    enemies = {}
    bullets = {}
    enemy_timer = Timer(2, spawnEnemy, 0.1, 0.5)
end

function love.update(dt)
    player:update(dt)
    if game_state == 2 then
        -- enemy spawn timer
        enemy_timer:update(dt)

        for _, e in ipairs(enemies) do
            e:update(dt)
            -- collision with player
            if e.player_hit then
                player:getHit(enemies)
            end
            for _, b in ipairs(bullets) do
                if e:getBulletDistance(b.x, b.y) < 20 then
                    e.is_dead = true
                    b.is_dead = true
                    score = score + 1
                end
            end
        end
        for i = #enemies, 1, -1 do
            if enemies[i].is_dead then
                table.remove(enemies, i)
            end
        end

        for _, b in ipairs(bullets) do
            b:update(dt)
        end
        for i = #bullets, 1, -1 do
            if bullets[i].is_dead then
                table.remove(bullets, i)
            end
        end
    end
    
    if player:canShoot() then
        table.insert(bullets, Bullet())
    end

    -- clear all tables after game over
    if game_state == 1 then
        enemies = {}
        bullets = {}
    end
end

function love.draw()
    -- backround
    love.graphics.draw(backround, 0, 0)
    -- enemies
    for _, e in ipairs(enemies) do
         e:draw()
    end
    -- bullets
    for _, b in ipairs(bullets) do
        b:draw()
    end
    -- player
    player:draw()
    -- score
    love.graphics.print("Score: " .. score, 10, 10)
    -- lives
    love.graphics.print("Lives: " .. player.lives, 10, 50)

    if game_state == 1 then
        love.graphics.setFont(game_font)
        love.graphics.printf("Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center")
    end

    -- DEBUGGING
    -- enemy spawn timer
    -- love.graphics.print(enemy_timer.time, 10, 100)
end

function love.mousepressed(x, y, button)
    -- change from mainmenu to game
    if button == 1 and game_state == 1 then
        game_state = 2
        score = 0
        enemy_timer.time = 2
    end
end

function spawnEnemy()
    table.insert(enemies, Enemy())
end