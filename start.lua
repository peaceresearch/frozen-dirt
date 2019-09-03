start = {
  images = {
		bg = love.graphics.newImage('img/start/bg.png'),
		logo = love.graphics.newImage('img/start/logo.png'),
		subtitle = love.graphics.newImage('img/start/subtitle.png'),
		option = love.graphics.newImage('img/start/option.png')
	}
}

local options = {'Start Game', 'High Scores', 'Display Option', 'Exit'}
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
	elseif activeOption == 4 and controls.shoot then
		love.event.quit()
	end
end

start.update = function()
	updateMenuDirections()
	updateMenuSelect()
end

local function drawOptions()
	love.graphics.setFont(fontBig)
	local y = grid * 16
	for i = 1, #options do
		local x = winWidth / 2 - #options[i] * 8 / 2
	  drawLabel(options[i], x, y)
		if i == activeOption then
			local activeX = x - 18
			love.graphics.setColor(colors.black)
			love.graphics.draw(start.images.option, activeX, y + 4)
			love.graphics.setColor(colors.red)
			love.graphics.draw(start.images.option, activeX - 1, y + 3)
			love.graphics.setColor(colors.white)
		end
		y = y + grid + 8
	end
	love.graphics.setFont(font)
end


local function drawCredits()
	local x = grid
	local y = winHeight - 8 - 12
	local offset = 14
	drawLabel('t.b: programming, design, art', x, y - offset * 2)
	drawLabel('a.m: sound design, bgm', x, y - offset)
	drawLabel('characters by zun', x, y)
	drawLabel('rev 09.03.19', 0, y, false, {type = 'right', width = winWidth - x})
end

start.draw = function()
	love.graphics.draw(start.images.bg, 0, 0)
	love.graphics.draw(start.images.logo, math.floor(winWidth / 2 - start.images.logo:getWidth() / 2), grid * 4)
	love.graphics.draw(start.images.subtitle, math.floor(winWidth / 2 - start.images.subtitle:getWidth() / 2), grid * 11)
	drawOptions()
	drawCredits()
end
