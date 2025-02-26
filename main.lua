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
    crosshair = love.graphics.newImage("sprites/crosshair.png")
    life = love.graphics.newImage("sprites/life.png")
    lost_life = love.graphics.newImage("sprites/lost_life.png")
    blood = love.graphics.newImage("sprites/blood.png")
    game_font = love.graphics.newFont(30)

    player = Player()

    bloodpool = {}
    enemies = {}
    bullets = {}
    enemy_timer = Timer(2, spawnEnemy, 0.1, 0.5)
end

function love.update(dt)
    -- resets if in mainmenu
    if game_state == 1 then
        enemies = {}
        bullets = {}
        bloodpool = {}
        player:resetPosition()
        player:resetTimers()
        return
    end

    -- player updates
    player:update(dt)
    if player:canShoot() then
        table.insert(bullets, Bullet())
    end

    -- enemy spawn timer
    enemy_timer:update(dt)

    -- enemy updates
    for _, e in ipairs(enemies) do
        e:update(dt)
        -- collision with player
        if e.player_hit then
            player:getHit(enemies)
            spawnBloodpool(player.x, player.y)
         end
         -- bullet collision with enemy
         for _, b in ipairs(bullets) do
             if e:getBulletDistance(b.x, b.y) < 20 then
                spawnBloodpool(e.x, e.y)
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
    
    -- bullet updates
    for _, b in ipairs(bullets) do
            b:update(dt)
    end
    for i = #bullets, 1, -1 do
        if bullets[i].is_dead then
            table.remove(bullets, i)
         end
    end
end

function love.draw()
    -------- ALWAYS DRAWN --------
    -- backround
    love.graphics.draw(backround, 0, 0)
    -- blood
    for _, v in ipairs(bloodpool) do
        love.graphics.draw(blood, v.x, v.y, v.rotation, v.scale, v.scale)
    end
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
    for i = 1, player.max_lives do
        -- full hearts
        if i <= player.lives then
            love.graphics.draw(life, 5 + (i - 1) * 30, 50, nil, 2, 2)
        -- lost hearts
        else
            love.graphics.draw(lost_life, 5 + (i - 1) * 30, 50, nil, 2, 2)
        end
    end
    
    -------- ONLY DRAWN IN MAINMENU --------
    if game_state == 1 then 
        love.mouse.setVisible(true)
        love.graphics.setFont(game_font)
        love.graphics.printf("Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center")
    -------- ONLY DRAWN IN GAMELOOP --------
    elseif game_state == 2 then
        -- crosshair
        love.graphics.draw(crosshair, love.mouse.getX(), 
        love.mouse.getY(), nil, 0.5, 0.5, crosshair:getWidth() / 2,
        crosshair:getHeight() / 2)
        love.mouse.setVisible(false)
    end

    -- DEBUGGING
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

function spawnBloodpool(entity_x, entity_y)
    table.insert(bloodpool, {
        x = entity_x, 
        y = entity_y, 
        scale = math.random(15, 20) / 10, 
        rotation = math.rad(math.random(0, 360))
        })
end