local Globals = {}

-- Game States
Globals.GAME_STATE = {
    MENU = 1,
    GAME = 2
}

-- Sprites
Globals.SPRITES = {
    BACKGROUND = love.graphics.newImage("sprites/background.png"),
    CROSSHAIR = love.graphics.newImage("sprites/crosshair.png"),
    LIFE = love.graphics.newImage("sprites/life.png"),
    LOST_LIFE = love.graphics.newImage("sprites/lost_life.png"),
    BLOOD = love.graphics.newImage("sprites/blood.png"),
    EXPERIENCE = love.graphics.newImage("sprites/experience.png")
}

-- Fonts
Globals.FONTS = {
    FONTSIZE = love.graphics.newFont(30)
}

-- Object tables
Globals.TABLES = {
    EXP = {},
    BLOODPOOL = {},
    ENEMIES = {},
    BULLETS = {}
}

function Globals.setState(new_state)
    Globals.current_state = new_state
end

function Globals:getTable(name)
    return self.TABLES[name]
end

function Globals:resetTables()
    for _, table in pairs(self.TABLES) do
        for i = #table, 1, -1 do
            table[i] = nil
        end
    end
end

return Globals