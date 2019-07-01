chrome = {}

local borderSize = grid

local function drawBorder()
	love.graphics.setColor(colors.purple)
	love.graphics.rectangle('fill', 0, 0, winWidth, grid)
	love.graphics.rectangle('fill', 0, winHeight - grid, winWidth, grid)
	love.graphics.rectangle('fill', 0, grid, grid * 2, gameHeight)
	love.graphics.rectangle('fill', grid * 2 + gameWidth, grid, winWidth - gameWidth - grid * 2, gameHeight)
	love.graphics.setColor(colors.purple)
	love.graphics.rectangle('line', gameX, gameY, gameWidth, gameHeight)
	love.graphics.setColor(colors.white)
end

function chrome.update()
end

function chrome.draw()
	-- drawBorder()
end