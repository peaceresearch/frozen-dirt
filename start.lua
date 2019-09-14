start = {
  images = {
		bg = love.graphics.newImage('img/start/bg.png'),
		logo = love.graphics.newImage('img/start/logo.png'),
		subtitle = love.graphics.newImage('img/start/subtitle.png'),
		option = love.graphics.newImage('img/start/option.png')
	}
}

local options = {'Start', 'High Scores', 'Display Modes', 'Quit To Desktop'}
local activeOption = 1

local displayOptions = {'240x320', '480x640', '720x960', 'Fullscreen Yoko', 'Fullscreen Tate', 'Return to Title'}
local activeDisplayOption = 1

local pressingDown = false
local pressingUp = false
local pressingSelect = false

local showingHighScores = false
local showingDisplayOptions = false

start.load = function()
  for type, img in pairs(start.images) do start.images[type]:setFilter('nearest', 'nearest')  end
	sound.playBgm('title')
end

local function updateMenuDirections()
	if controls.down and not pressingDown then
		pressingDown = true
		sound.playSfx('changeselect')
		if showingDisplayOptions then
			activeDisplayOption = activeDisplayOption + 1
			if activeDisplayOption > #displayOptions then activeDisplayOption = 1 end
		else
			activeOption = activeOption + 1
			if activeOption > #options then activeOption = 1 end
		end
	elseif not controls.down and pressingDown then pressingDown = false end
	if controls.up and not pressingUp then
		pressingUp = true
		sound.playSfx('changeselect')
		if showingDisplayOptions then
			activeDisplayOption = activeDisplayOption - 1
			if activeDisplayOption < 1 then activeDisplayOption = #displayOptions end
		else
			activeOption = activeOption - 1
			if activeOption < 1 then activeOption = #options end
		end
	elseif not controls.up and pressingUp then pressingUp = false end
	if controls.shoot and not pressingSelect then pressingSelect = true
	elseif not controls.shoot and pressingSelect then pressingSelect = false end
end

local function updateMenuSelect()
	if controls.shoot then
		sound.playSfx('startgame')
		if activeOption == 1 and not pressingSelect and not started then
			startGame()
			started = true
		elseif activeOption == 2 and not pressingSelect then showingHighScores = true
		elseif activeOption == 3 and not pressingSelect then showingDisplayOptions = true
		elseif activeOption == 4 and not pressingSelect then love.event.quit() end
	end
end

local function updateHighScores()
	if controls.shoot and not pressingSelect then
		showingHighScores = false
	end
end

local function updateDisplayOptions()
	-- local windowResolution = false
	if controls.shoot and not pressingSelect then
		print('o')
		if activeDisplayOption == 1 or activeDisplayOption == 2 or activeDisplayOption == 3 then
			gameScale = activeDisplayOption
			isFullscreen = false
			isTate = false
		end
		love.window.setMode(winWidth * gameScale, winHeight * gameScale, {vsync = false})

	-- 	if windowResolution then  end
	-- 	if activeDisplayOption == 4 or activeDisplayOption == 5 then
	-- 		gameScale = 1
	-- 		if activeDisplayOption == 5 then
	-- 			isTate = true
	-- 			gameScale = love.graphics.getHeight() / gameWidth
	-- 		else
	-- 			isTate = false
	-- 			gameScale = love.graphics.getHeight() / gameHeight
	-- 			print(love.graphics.getHeight())
	-- 		end
	-- 		love.window.setFullscreen(true, 'desktop')
	-- 		isFullscreen = true
	-- 	elseif activeDisplayOption == 6 then
	-- 		showingDisplayOptions = false
	-- 		activeDisplayOption = 1
	-- 		if isFullscreen then love.window.setFullscreen(true, 'desktop') end
	-- 	end
		-- print(gameScale)
	end
end

start.update = function()
	if showingHighScores then updateHighScores()
	elseif showingDisplayOptions then updateDisplayOptions()
	else updateMenuSelect() end
	updateMenuDirections()
end

local function drawOptions()
	local y = gameHeight / 2 - 8
	for i = 1, #options do
		local x = winWidth / 2 - #options[i] * 8 / 2
	  drawLabel(options[i], x, y)
		if i == activeOption then drawLabel(options[i], x, y, 'blueLight')
		else drawLabel(options[i], x, y) end
		y = y + 12
	end
end

local function drawCredits()
	local x = 8
	local y = gameHeight - 6 - 8
	local offset = 10
	drawLabel('t.b: programming and art', x, y - offset * 2)
	drawLabel('a.m: sfx and bgm', x, y - offset)
	drawLabel('characters by zun', x, y)
	drawLabel('v1.0', 0, y, false, {type = 'right', width = winWidth - x})
end

local function drawHighScores()
	local y = grid * 4
	local highScoreStr = 'Local High Scores'
	drawLabel(highScoreStr, gameWidth / 2 - #highScoreStr * 8 / 2, y)
	y = y + grid * 2.25
	for i = 1, 5 do
		local scoreNum = 0
		if scoreTable[i] then scoreNum = scoreTable[i] end
		local scoreStr = tostring(i) .. '. ' .. processScore(scoreNum)
		drawLabel(scoreStr, gameWidth / 2 - #scoreStr * 8 / 2, y)
		y = y + grid
	end
	y = y + grid * 2.5
	local returnStr = 'Return to Title'
	drawLabel(returnStr, gameWidth / 2 - #returnStr * 8 / 2, y, 'blueLight')
end

local function drawDisplayOptions()
	local y = grid * 4
	local titleStr = 'Display Modes'
	drawLabel(titleStr, gameWidth / 2 - #titleStr * 8 / 2, y)
	y = y + grid * 2.25
	for i = 1, #displayOptions do
		local x = winWidth / 2 - #displayOptions[i] * 8 / 2
	  drawLabel(displayOptions[i], x, y)
		if i == activeDisplayOption then drawLabel(displayOptions[i], x, y, 'blueLight')
		else drawLabel(displayOptions[i], x, y) end
		y = y + 12
	end
end

start.draw = function()
	love.graphics.draw(start.images.bg, 0, 0)
	-- love.graphics.draw(start.images.subtitle, math.floor(winWidth / 2 - start.images.subtitle:getWidth() / 2), grid * 11)
	if showingHighScores then drawHighScores()
	elseif showingDisplayOptions then drawDisplayOptions()
	else
		love.graphics.draw(start.images.logo, math.floor(gameWidth / 2 - start.images.logo:getWidth() / 2), gameHeight / 3 - start.images.logo:getHeight() / 2)
		drawOptions()
		drawCredits()
	end
end
