chrome = {
  images = {
		border = love.graphics.newImage('img/chrome/border.png'),
    bomb = love.graphics.newImage('img/chrome/bomb.png'),
    life = love.graphics.newImage('img/chrome/life.png'),
		portraits = {
			cirno = love.graphics.newImage('img/portraits/cirno.png'),
			irate = love.graphics.newImage('img/portraits/irate.png')
		},
		paused = love.graphics.newImage('img/chrome/paused.png')
  },
  lastTime = 0,
  fps = 0,
	pauseClock = 0,
	pauseVisible = true
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


local function updatePaused()
	if paused then
		local interval = 120
		if chrome.pauseClock % interval < interval / 2 then chrome.pauseVisible = true
		else chrome.pauseVisible = false end
		chrome.pauseClock = chrome.pauseClock + 1
	elseif chrome.pauseClock > 0 then chrome.pauseClock = 0 end
end

function updateChrome()
  updateFps()
	updateStages()
	updatePaused()
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
	local x = 4 + grid - 2
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

local function drawPower()
	local width = 12
	local maxHeight = grid * 1.75
	local height = math.ceil(player.power / 3 * maxHeight)
	if height > maxHeight then height = maxHeight end
	local x = 4
	local y = grid - 2
	if bossHealth > 0 then y = y + 10 end
	love.graphics.setColor(colors.black)
	love.graphics.rectangle('fill', x + 1, y + 1, width, maxHeight)
	love.graphics.setColor(colors.purple)
	love.graphics.rectangle('fill', x, y, width, maxHeight)
	y = y + (maxHeight - height)
	love.graphics.setColor(colors.blueLight)
	love.graphics.rectangle('fill', x, y, width, height)
	-- if height >= 1 then
	-- 	love.graphics.setColor(colors.blueLight)
	-- 	love.graphics.rectangle('fill', x, y, width, 1)
	-- end
	if height == maxHeight then
		local offset = 8
		x = x + 2
		y = y + 2
		drawLabel('m', x, y)
		drawLabel('a', x, y + offset)
	  drawLabel('x', x, y + offset * 2)
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
	-- local powerStr = tostring(math.floor(player.power * 100) / 100)
	-- if #powerStr == 1 then powerStr = powerStr .. '.00'
	-- elseif #powerStr == 3 then powerStr = powerStr .. '0' end
	-- powerStr = 'Pow ' .. powerStr
	-- drawLabel(powerStr, 2, winHeight - 8 - 2)
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
	local portScale = .5
	love.graphics.draw(chrome.images.portraits.cirno, gameWidth / 2, gameHeight / 3, 0, portScale, portScale)
  -- love.graphics.draw(chrome.images.portraits.irate, gameX + grid * 22.5, gameY + grid * 5, 0, irateScale, irateScale)
end

local function drawStages()
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
	if goingToBossClock > 0 then goingToBoss() end
	if clearedStageClock > 0 then clearedStage() end
	-- clearedStage()
end

local function drawPaused()
  love.graphics.draw(chrome.images.paused, 0, 0)
	if chrome.pauseVisible then
		local str = 'Paused'
	  drawLabel(str, gameWidth / 2 - #str * 8 / 2, gameHeight / 2 - 4)
	end
end

local function drawPregame()
	local str = 'Going into stage ' .. currentStage
	drawLabel(str, gameWidth / 2 - #str * 8 / 2, gameHeight / 2 - 4, 'blueLight')
end

function drawChrome()
	-- drawPortraits()
	if paused then drawPaused() end
  drawScore()
  drawDebug()
	drawStages()
  drawLives()
	drawPower()
  drawBombs()
  if bossHealth > 0 then drawBoss() end
	if pregameClock > 0 then drawPregame() end
end
