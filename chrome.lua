chrome = {
  images = {
		border = love.graphics.newImage('img/chrome/border.png'),
    logo = love.graphics.newImage('img/chrome/logo.png'),
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
    if fps and love.timer.getFPS() > 0 then chrome.fps = tostring(fps) .. '(' .. tostring(love.timer.getFPS()) .. ')' end
    chrome.lastTime = currentTime
  end
end

local function drawLabel(input, x, y, labelColor, alignObject)
  input = string.upper(input)
  local color = colors.white
	local align = 'left'
	local limit = 256
  if labelColor then color = colors[labelColor] end
	if alignObject then
		align = alignObject.type
		limit = alignObject.width
	end
	love.graphics.setColor(colors.black)
  love.graphics.printf(input, x + 1, y + 1, limit, align)
	love.graphics.setColor(color)
  love.graphics.printf(input, x, y, limit, align)
	love.graphics.setColor(colors.white)
  -- love.graphics.print({colors.black, input}, x + 1, y + 1, 0, 1, 1, oX, 0)
	-- love.graphics.print({color, input}, x, y, 0, 1, 1, oX, 0)
end

local function drawBorder()
  love.graphics.draw(chrome.images.border, 0, 0)
  -- love.graphics.draw(chrome.images.logo, winWidth - 98 - grid, winHeight - 22 - grid * 2)
end

local function drawScore()
  local x = gameX - grid * 1.25
  local y = grid
  local scoreStr = 'Hi Score'
  local scoreNum = '000000000'
  drawLabel(scoreStr, x - #scoreStr * 8, y)
  drawLabel(scoreNum, x - #scoreNum * 8, y + grid)
  x = gameX + gameWidth + grid * 1.25
  drawLabel('Score', x, y)
  drawLabel('000000000', x, y + grid)
end

local function drawLives()
  local y = grid * 3.75
  local livesStr = 'Lives'
  drawLabel(livesStr, gameX - grid * 1.25 - #livesStr * 8, y)
  for i = 1, player.lives do
    local x = gameX - grid - grid * 1.25 - 18 * (i - 1)
    love.graphics.draw(chrome.images.life, x, y + grid + 4)
  end
end

local function drawBombs()
  local x = gameX + gameWidth + grid * 1.25
  local y = grid * 3.75
  drawLabel('Bombs', x, y)
  for i = 1, player.bombs do
    x = x + 18
    love.graphics.draw(chrome.images.bomb, x - 18, y + grid + 4)
  end
end

local function drawDebug()
  love.graphics.setFont(font)
	local x = grid
  local y = winHeight - 4
  local drawDebug
  drawDebug = function()
    drawLabel("pshot:" .. tostring(#player.bullets), x, y - 12 * 4 - 8)
    drawLabel("eshot:" .. tostring(#stage.bullets), x, y - 12 * 3 - 8)
    drawLabel("enemy:" .. tostring(#stage.enemies), x, y - 12 * 2 - 8)
    drawLabel("explo:" .. tostring(#explosions.explosions), x, y - 12 * 1 - 8)
  end
  drawLabel(chrome.fps .. 'FPS', gameX + gameWidth, winHeight - grid - grid + 6, 'blueDarkest', {type = 'right', width = gameX - grid})
  -- drawDebug()
  love.graphics.setFont(fontBig)
end

local function drawBoss()
	local x = gameX + 4
	local y = gameY + 4
	local function bar()
	  local width = gameWidth - 8
	  local healthWidth = math.floor(bossHealth / bossHealthInit * width) - 2
	  if healthWidth > 0 then
	    local height = 10
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
	    love.graphics.rectangle('fill', x + 1, y + 1, healthWidth, 1)
	    -- love.graphics.setStencilTest('greater', 0)
	    -- love.graphics.setColor(colors.yellow)
	    -- love.graphics.rectangle('fill', x + 1, y + 1, healthWidth, height - 2)
	    -- love.graphics.setStencilTest()
	    love.graphics.setColor(colors.black)
	    love.graphics.rectangle('fill', x + healthWidth + 1, y + 1, 1, height - 2)
	    love.graphics.setColor(colors.white)
	  end
	end
	bar()
  love.graphics.setFont(megaten)
	y = y + 10
  drawLabel('Sector Bootes', x, y)
	drawLabel('Jack Frost', gameX, y, false, {type = 'right', width = gameWidth - 4})
  drawLabel('Agilao', gameX, y + 12, false, {type = 'right', width = gameWidth - 4})
  love.graphics.setFont(fontBig)
end

chrome.update = function()
  updateFps()
end

chrome.draw = function()
  drawBorder()
  -- drawScore()
  -- drawLives()
  -- drawBombs()
  drawDebug()
  if bossHealth > 0 then drawBoss() end
end
