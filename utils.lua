local Utils = {}

function Utils.getAngle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

function Utils.distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function Utils.outOfScreen(x, y)
    return x < 0 or y < 0 or x > love.graphics.getWidth() or y > love.graphics.getHeight()
end

return Utils