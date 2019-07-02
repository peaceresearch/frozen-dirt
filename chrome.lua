chrome = {
	images = {
		border = love.graphics.newImage('img/chrome/border.png')
	}
}

function drawLabel(input, x, y, labelColor)
	input = string.upper(input)
	local color = colors.light
	if labelColor then color = colors[labelColor] end
	love.graphics.print({colors.purple, input}, x + 1, y + 1)
	love.graphics.print({color, input}, x, y)
end

local function drawBorder()
	love.graphics.draw(chrome.images.border, 0, 0)
end

local function drawScore()
	local x = gameX - grid * 1.5
	local y = grid * 1.5
	local scoreStr ='Hi Score'
	local scoreNum = '0000000000'
	drawLabel(scoreStr, x - #scoreStr * 8, y)
	drawLabel(scoreNum, x - #scoreNum * 8, y + grid)
	x = gameX + gameWidth + grid * 1.5
	drawLabel('Score', x, y)
	drawLabel('0000000000', x, y + grid)
end

local function drawLives()
	local x = gameX - grid * 1.5
	local y = grid * 4.25
	local livesStr = 'Lives x' .. player.lives
	drawLabel(livesStr, x - #livesStr * 8, y)
end

local function drawBombs()
	local x = gameX + gameWidth + grid * 1.5
	local y = grid * 4.25
	local livesStr = 'Bombs x' .. player.bombs
	drawLabel(livesStr, x, y)
end

local function drawBottom()
end

function chrome.update()
end

function chrome.draw()
	drawBorder()
	drawScore()
	drawLives()
	drawBombs()
	-- drawBottom()
end
