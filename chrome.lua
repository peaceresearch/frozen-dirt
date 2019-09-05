chrome = {
  images = {
		border = love.graphics.newImage('img/chrome/border.png'),
    logo = love.graphics.newImage('img/chrome/logo.png'),
    bomb = love.graphics.newImage('img/chrome/bomb.png'),
    life = love.graphics.newImage('img/chrome/life.png'),
		portraits = {
			cirno = love.graphics.newImage('img/portraits/cirno.png'),
			irate = love.graphics.newImage('img/portraits/irate.png')
		}
  },
  lastTime = 0,
  fps = 0
}

local fontOffset = grid + 4

function processScore(input)
	local score = tostring(input);
	for i = 1, 8 - #score do
		score = '0' .. score
	end
	return score
end

function loadChrome()
  for type, img in pairs(chrome.images.portraits) do
    chrome.images.portraits[type]:setFilter('nearest', 'nearest')
  end
end

local function updateFps()
  if gameClock % 30 == 0 then
    local currentTime = os.time()
    local fps = 60 - (currentTime - chrome.lastTime)
    chrome.fps = '00 00 '
    if fps and love.timer.getFPS() > 0 then chrome.fps = tostring(fps) .. ' ' .. tostring(love.timer.getFPS()) .. ' ' end
    chrome.lastTime = currentTime
  end
end

local function updateStages()
	if goingToBossClock > 0 then goingToBossClock = goingToBossClock - 1 end
	if clearedStageClock > 0 then clearedStageClock = clearedStageClock - 1 end
end

function updateChrome()
  updateFps()
	updateStages()
end

local function drawBorder()
  love.graphics.draw(chrome.images.border, 0, 0)
  -- love.graphics.draw(chrome.images.logo, 10, grid)
end

local function drawScore()
	love.graphics.setFont(fontBig)
  local x = gameX - grid
  local y = grid
  local scoreStr = 'Hi Score'
  local scoreNum = processScore(0)
  drawLabel(scoreStr, x - #scoreStr * 8, y)
  drawLabel(scoreNum, x - #scoreNum * 8, y + fontOffset)
  x = gameX + gameWidth + grid
  drawLabel('Score', x, y)
  drawLabel(processScore(currentScore), x, y + fontOffset)
  love.graphics.setFont(font)
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
  -- love.graphics.setFont(font)
	-- local x = grid
  -- local y = winHeight - 4
  -- local drawDebug
  -- drawDebug = function()
  --   drawLabel("pshot:" .. tostring(#player.bullets), x, y - 12 * 4 - 8, 'blueDark')
  --   drawLabel("eshot:" .. tostring(#stage.bullets), x, y - 12 * 3 - 8, 'blueDark')
  --   drawLabel("enemy:" .. tostring(#stage.enemies), x, y - 12 * 2 - 8, 'blueDark')
  --   drawLabel("explo:" .. tostring(#explosions.explosions), x, y - 12 * 1 - 8, 'blueDark')
  -- end
  -- drawDebug()
  -- love.graphics.setFont(fontBig)
  drawLabel(chrome.fps .. 'FPS', gameX + gameWidth, winHeight - grid * 2, false, {type = 'right', width = gameX - 12})
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
	    -- love.graphics.rectangle('fill', x, y, width, height)
	    love.graphics.setStencilTest()
	    love.graphics.rectangle('fill', x, y, width, 1)
	    love.graphics.rectangle('fill', x, y + height - 1, width, 1)
	    love.graphics.rectangle('fill', x, y, 1, height)
	    love.graphics.rectangle('fill', x + width - 1, y, 1, height)
	    love.graphics.setColor(colors.blueLight)
	    love.graphics.rectangle('fill', x + 1, y + 1, healthWidth, height - 2)
	    love.graphics.setColor(colors.blueLightest)
	    love.graphics.rectangle('fill', x + 1, y + 1, healthWidth, 1)
	    love.graphics.setColor(colors.black)
	    love.graphics.rectangle('fill', x + healthWidth + 1, y + 1, 1, height - 2)
	    love.graphics.setColor(colors.white)
	  end
	end
	bar()
	y = y + 12
end

local function drawPortraits()
	local irateScale = .75
	love.graphics.draw(chrome.images.portraits.cirno, gameX + grid * 14, gameY + grid * 8)
  love.graphics.draw(chrome.images.portraits.irate, gameX + grid * 22.5, gameY + grid * 5, 0, irateScale, irateScale)
end

local function drawStages()

	local function current()
		love.graphics.setFont(fontBig)
		local stageStr = tostring(currentStage) .. '/9'
		local x = gameX + 4
		local y = winHeight - grid * 2 - 3
		local limit = grid * 2.5
		if player.x < #stageStr * 8 + 4 + limit and player.y > gameHeight - 4 - 8 - limit then
			currentStencil = masks.quarter
			love.graphics.stencil(setStencilMask, 'replace', 1)
			love.graphics.setStencilTest('greater', 0)
		end
		drawLabel(stageStr, x, y)
		love.graphics.setFont(font)
		love.graphics.setStencilTest()
	end

	local function goingToBoss()
		local str = 'A Baka Approaches'
		local x = gameX + gameWidth / 2 - #str * 8 / 2
		local y = gameHeight / 2 - 8
		drawLabel(str, x, y)
		love.graphics.setFont(font)
	end

	local function clearedStage()
		local x = gameX + gameWidth / 2
		local y = gameY + grid * 8
		local stageClear = 'Stage 3 Cleared'
		drawLabel(stageClear, x - #stageClear * 8 / 2, y)
		y = y + grid * 3
		local noMiss = 'No Miss  5000'
		drawLabel(noMiss, x - #noMiss * 8 / 2, y)
		y = y + fontOffset
		local noBomb = 'No Bomb  2500'
		drawLabel(noBomb, x - #noBomb * 8 / 2, y)
		y = y + grid * 2
		local total = '  Total  9000'
		drawLabel(total, x - #total * 8 / 2, y)
		y = y + grid * 3
		local next = 'Wait for next stage'
		drawLabel(next, x - #next * 8 / 2, y)
	end

	-- current()
	if goingToBossClock > 0 then goingToBoss() end
	if clearedStageClock > 0 then clearedStage() end
	-- clearedStage()

end

function drawChrome()
  drawBorder()
	-- drawPortraits()
  drawScore()
  -- drawDebug()
	drawStages()
  -- drawLives()
  -- drawBombs()
  if bossHealth > 0 then drawBoss() end
end
