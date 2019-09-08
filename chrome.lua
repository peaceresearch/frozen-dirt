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
		score = ' ' .. score
	end
	return score
end

function loadChrome()
	chrome.images.life:setFilter('nearest', 'nearest')
	chrome.images.bomb:setFilter('nearest', 'nearest')
  for type, img in pairs(chrome.images.portraits) do
    chrome.images.portraits[type]:setFilter('nearest', 'nearest')
  end
end

local function updateFps()
  if gameClock % 30 == 0 then
    local currentTime = os.time()
    local fps = 60 - (currentTime - chrome.lastTime)
    chrome.fps = '00 '
		-- if fps and love.timer.getFPS() > 0 then chrome.fps = tostring(fps) .. ' ' .. tostring(love.timer.getFPS()) .. ' ' end
    if fps and love.timer.getFPS() > 0 then chrome.fps = tostring(fps) .. ' ' end
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

	local x = 4
	local y = 4

	local function playerOne()
		drawLabel('1P', x, y, 'blueLight')
		x = x + 8 * 3
		drawLabel(processScore(currentScore), x, y)
	end

	local function high()
		local scoreNum = highScore
		if currentScore >= highScore then scoreNum = currentScore end
		local scoreStr = 'HI ' .. processScore(scoreNum)
		x = gameWidth - 4 - #scoreStr * 8
		drawLabel('HI', x, y, 'blueLight')
		x = x + 8 * 3
		drawLabel(processScore(scoreNum), x, y)
	end

	playerOne()
	high()

end

local function drawLives()
	local x = 4
	local y = grid - 1
	if bossHealth > 0 then y = y + 10 end
  for i = 1, player.lives do
		love.graphics.setColor(colors.black)
    love.graphics.draw(chrome.images.life, x + 1, y)
		love.graphics.setColor(colors.offWhite)
    love.graphics.draw(chrome.images.life, x, y - 1)
    x = x + grid + 1
  end
	love.graphics.setColor(colors.white)
end

local function drawBombs()
	local x = gameWidth - 4 - grid
	local y = grid - 1
	if bossHealth > 0 then y = y + 10 end
  for i = 1, player.bombs do
		love.graphics.setColor(colors.black)
    love.graphics.draw(chrome.images.bomb, x + 1, y)
		love.graphics.setColor(colors.offWhite)
    love.graphics.draw(chrome.images.bomb, x, y - 1)
    x = x - grid - 1
  end
	love.graphics.setColor(colors.white)
end

local function drawDebug()
  drawLabel(chrome.fps .. 'FPS', 0, winHeight - 8 - 2, false, {type = 'right', width = gameWidth - 2})
end

local function drawBoss()
	local x = 4
	local y = grid - 2
	local function bar()
	  local width = gameWidth - 8
	  local healthWidth = math.floor(bossHealth / bossHealthInit * width) - 1
	  if healthWidth > 0 then
	    local height = 7
			love.graphics.setColor(colors.black)
	    love.graphics.rectangle('fill', x + 1, y + 1, healthWidth, height)
	    love.graphics.setColor(colors.blueLight)
	    love.graphics.rectangle('fill', x, y, healthWidth, height)
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
		local y = gameHeight / 2 - 4
		drawLabel(str, x, y)
		love.graphics.setFont(font)
	end

	local function clearedStage()
		local x = gameX + gameWidth / 2
		local y = gameHeight / 4
		local offset = 12
		local stageClear = 'Stage ' .. currentStage .. ' Cleared'
		drawLabel(stageClear, x - #stageClear * 8 / 2, y, 'blueLight')
		y = math.floor(gameHeight / 5 * 2) - 8
		local noMiss = 'No Miss  5000'
		drawLabel(noMiss, x - #noMiss * 8 / 2, y)
		y = y + offset
		local noBomb = 'No Bomb  2500'
		drawLabel(noBomb, x - #noBomb * 8 / 2, y)
		y = y + grid + 2
		local total = '  Total  9000'
		drawLabel(total, x - #total * 8 / 2, y)
		local next = 'Wait for next stage'
		drawLabel(next, x - #next * 8 / 2, gameHeight / 5 * 3)
	end

	-- current()
	if goingToBossClock > 0 then goingToBoss() end
	if clearedStageClock > 0 then clearedStage() end
	-- clearedStage()

end

function drawChrome()
  -- drawBorder()
	-- drawPortraits()
  drawScore()
  drawDebug()
	drawStages()
  drawLives()
  drawBombs()
  if bossHealth > 0 then drawBoss() end
end
