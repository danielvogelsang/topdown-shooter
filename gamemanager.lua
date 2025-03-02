local GameManager = {}

-- Game States
GameManager.GAME_STATE = {
    MENU = 1,
    GAME = 2
}

-- Default State
GameManager.current_state = GameManager.GAME_STATE.MENU

function GameManager:setState(new_state)
    self.current_state = new_state
end

function GameManager:getState()
    return self.current_state
end

function GameManager:inMenu()
    return self:getState() == self.GAME_STATE.MENU
end

function GameManager:inGame()
    return self:getState() == self.GAME_STATE.GAME
end

return GameManager