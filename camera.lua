local Object = require "classic"

local Camera = Object:extend()

function Camera:new(x, y, zoom)
    self.x = x or 0
    self.y = y or 0
    self.zoom = zoom or 1
    self.rotation = 0
    self.smooth_factor = 0.1  -- For smooth camera movement
end

function Camera:set()
    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    love.graphics.scale(self.zoom)
    love.graphics.rotate(self.rotation)
    love.graphics.translate(-self.x, -self.y)
end

function Camera:unset()
    love.graphics.pop()
end

function Camera:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function Camera:moveTo(x, y)
    self.x = x
    self.y = y
end

function Camera:smoothMoveTo(x, y, dt)
    self.x = self.x + (x - self.x) * self.smooth_factor * (dt * 60)
    self.y = self.y + (y - self.y) * self.smooth_factor * (dt * 60)
end

function Camera:rotate(dr)
    self.rotation = self.rotation + dr
end

function Camera:rotateTo(rotation)
    self.rotation = rotation
end

function Camera:zoom(factor)
    self.zoom = self.zoom * factor
end

function Camera:zoomTo(zoom)
    self.zoom = zoom
end

function Camera:worldToScreen(x, y)
    -- Convert world coordinates to screen coordinates
    local screenX, screenY
    
    -- Apply the camera's transformations in reverse
    x, y = x - self.x, y - self.y
    
    -- Apply rotation
    local cos, sin = math.cos(-self.rotation), math.sin(-self.rotation)
    x, y = x * cos - y * sin, x * sin + y * cos
    
    -- Apply zoom and center offset
    screenX = x * self.zoom + love.graphics.getWidth()/2
    screenY = y * self.zoom + love.graphics.getHeight()/2
    
    return screenX, screenY
end

function Camera:screenToWorld(x, y)
    -- Convert screen coordinates to world coordinates
    local worldX, worldY
    
    -- Undo center offset and zoom
    x = (x - love.graphics.getWidth()/2) / self.zoom
    y = (y - love.graphics.getHeight()/2) / self.zoom
    
    -- Undo rotation
    local cos, sin = math.cos(self.rotation), math.sin(self.rotation)
    worldX = x * cos - y * sin
    worldY = x * sin + y * cos
    
    -- Undo translation
    worldX, worldY = worldX + self.x, worldY + self.y
    
    return worldX, worldY
end

function Camera:__tostring()
    return "Camera(x=" .. self.x .. ", y=" .. self.y .. ", zoom=" .. self.zoom .. ")"
end

return Camera