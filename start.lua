start = {
  images = {
		bg = love.graphics.newImage('img/start/bg.png'),
		logo = love.graphics.newImage('img/start/logo.png'),
		subtitle = love.graphics.newImage('img/start/subtitle.png'),
		option = love.graphics.newImage('img/start/option.png')
	}
}

local options = {'Classic Mode', 'Drunk Label', 'Time Attack', 'High Scores', 'Display Options', 'Quit To Desktop'}
local activeOption = 1

local pressingDown = false
local pressingUp = false

start.load = function()
  for type, img in pairs(start.images) do start.images[type]:setFilter('nearest', 'nearest')  end
end

local function updateMenuDirections()
	if controls.down and not pressingDown then
		pressingDown = true
		activeOption = activeOption + 1
		if activeOption > #options then activeOption = 1 end
	elseif not controls.down and pressingDown then pressingDown = false end
	if controls.up and not pressingUp then
		pressingUp = true
		activeOption = activeOption - 1
		if activeOption < 1 then activeOption = #options end
	elseif not controls.up and pressingUp then pressingUp = false end
end

local function updateMenuSelect()
	if activeOption == 1 and controls.shoot and not started then
		startGame()
		started = true
	elseif activeOption == 6 and controls.shoot then
		love.event.quit()
	end
end

start.update = function()
	updateMenuDirections()
	updateMenuSelect()
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

start.draw = function()
	love.graphics.draw(start.images.bg, 0, 0)
	love.graphics.draw(start.images.logo, math.floor(gameWidth / 2 - start.images.logo:getWidth() / 2), gameHeight / 3 - start.images.logo:getHeight() / 2)
	-- love.graphics.draw(start.images.subtitle, math.floor(winWidth / 2 - start.images.subtitle:getWidth() / 2), grid * 11)
	drawOptions()
	drawCredits()
end
