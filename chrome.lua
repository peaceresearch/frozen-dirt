chrome = {
	images = {
		border = love.graphics.newImage('img/chrome/border.png'),
		bomb = love.graphics.newImage('img/chrome/bomb.png'),
		life = love.graphics.newImage('img/chrome/life.png')
	},
	lastTime = 0,
	fps = 0
}

local function updateFps()
	if gameClock % 30 == 0 then
		local currentTime = os.time()
		local fps = 60 - (currentTime - chrome.lastTime)
		chrome.fps = '00(00)'
		if fps and love.timer.getFPS() > 0 then chrome.fps = fps .. '(' .. love.timer.getFPS() .. ')' end
		chrome.lastTime = currentTime
	end
	-- chrome.fps = love.timer.getFPS()
end

function drawLabel(input, x, y, labelColor)
	input = string.upper(input)
	local color = colors.white
	if labelColor then color = colors[labelColor] end
	love.graphics.print({colors.black, input}, x + 1, y + 1)
	love.graphics.print({color, input}, x, y)
end

local function drawBorder()
	love.graphics.draw(chrome.images.border, 0, 0)
end

local function drawScore()
	local x = gameX - grid * 1.5
	local y = grid
	local scoreStr ='Hi Score'
	local scoreNum = '000000000'
	drawLabel(scoreStr, x - #scoreStr * 8, y)
	drawLabel(scoreNum, x - #scoreNum * 8, y + grid)
	x = gameX + gameWidth + grid * 1.5
	drawLabel('Score', x, y)
	drawLabel('000000000', x, y + grid)
end

local function drawLives()
	local y = grid * 3.75
	local livesStr = 'Lives'
	drawLabel(livesStr, gameX - grid * 1.5 - #livesStr * 8, y)
	for i = 1, player.lives do
		local x = gameX - grid - grid * 1.5 - 18 * (i - 1)
		love.graphics.draw(chrome.images.life, x, y + grid + 4)
	end
end

local function drawBombs()
	local x = gameX + gameWidth + grid * 1.5
	local y = grid * 3.75
	drawLabel('Bombs', x, y)
	for i = 1, player.bombs do
		local x = x + 18 * (i - 1)
		love.graphics.draw(chrome.images.bomb, x, y + grid + 4)
	end
end

local function drawBottom()
	love.graphics.setFont(font)
	local y = winHeight - grid - grid / 2
	local function drawDebug()
		drawLabel('pshot:' .. #player.bullets, gameX + gameWidth + grid * 1.5, y - 12 * 3 - 8)
		drawLabel('eshot:' .. #stage.bullets, gameX + gameWidth + grid * 1.5, y - 12 * 2 - 8)
		drawLabel('enemy:' .. #stage.enemies, gameX + gameWidth + grid * 1.5, y - 12 - 8)
	end
	drawLabel(chrome.fps .. 'FPS', gameX + gameWidth + grid * 1.5, y)
	drawDebug()
	love.graphics.setFont(fontBig)
end

local function drawBoss()
	local width = gameWidth - 8
	local healthWidth = math.floor(bossHealth / bossHealthInit * width) - 2
	if healthWidth > 0 then
		local height = 10
		local x = gameX + 4
		local y = gameY + 4
		love.graphics.setColor(colors.black)
		love.graphics.setStencilTest('greater', 0)
		love.graphics.rectangle('fill', x, y, width, height)
		love.graphics.setStencilTest()
		love.graphics.rectangle('fill', x, y, width, 1)
		love.graphics.rectangle('fill', x, y + height - 1, width, 1)
		love.graphics.rectangle('fill', x, y, 1, height)
		love.graphics.rectangle('fill', x + width - 1, y, 1, height)
		love.graphics.setColor(colors.red)
		love.graphics.rectangle('fill', x + 1, y + 1, healthWidth, height - 2)
		love.graphics.setColor(colors.redLight)
		love.graphics.setStencilTest('greater', 0)
		love.graphics.rectangle('fill', x + 1, y + 1, healthWidth, height - 2)
		love.graphics.setStencilTest()
		love.graphics.setColor(colors.black)
		love.graphics.rectangle('fill', x + healthWidth + 1, y + 1, 1, height - 2)
		love.graphics.setColor(colors.white)
	end
end

function chrome.update()
	updateFps()
end

function chrome.draw()
	drawBorder()
	drawScore()
	drawLives()
	drawBombs()
	drawBottom()
	if bossHealth > 0 then drawBoss() end
end
