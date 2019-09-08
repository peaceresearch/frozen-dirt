math.tau = math.pi * 2
hc = require('lib/hc')
-- winWidth = 640
-- winHeight = 480
winWidth = 240
winHeight = 320
gameScale = 3
grid = 16
-- gameWidth = grid * 24
-- gameHeight = grid * 28
gameWidth = winWidth
gameHeight = winHeight
-- gameX = winWidth / 2 - gameWidth / 2
-- gameY = grid
gameX = 0
gameY = 0
colors = {

	-- 32 colors
	purpleDark = '222034',
	purple = '45283c',
  purpleLight = '76428a',
  pink = 'd77bba',
	red = 'ac3232',
  redLight = 'd95763',
  blueMid = '639bff',
	blueDark = '306082',
	blueDarkest = '3f3f74',
  blue = '5b6ee1',
	blueLightest = '5fcde4',
  orange = 'd27d2c',
	grayDark = '595652',
  gray = '696a6a',
	grayLight = '847e87',
	grayLightest = '9badb7',
  yellow = 'dad45e',
	greenDarkest = '323c39',



	-- here be uhhh new colors
	black = '140c1c',
	purple = '442434',
	blueDark = '30346d',
	blue = '597dce',
	blueLight = '6dc2ca',
	offWhite = 'deeed6',
	white = 'ffffff'

}
gameClock = 0
highScore = 0
currentScore = 0
currentGraze = 0
paused = false
gameOver = false
started = true
aniTime = 25
dt = 0
frameLimit = 1 / 60
goingToBossClock = 0
goingToBossLimit = 60 * 3.5
clearedStageClock = 0
clearedStageLimit = 60 * 5
font = love.graphics.newFont('fonts/Ibara.ttf', 7)
masks = {
  half = love.graphics.newImage('img/masks/half.png'),
  quarter = love.graphics.newImage('img/masks/quarter.png')
}
maskShader = love.graphics.newShader([[	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	if (Texel(texture, texture_coords).rgb == vec3(0.0)) {
		discard;
	}
	return vec4(1.0);
	}
	]])
currentStencil = false
setStencilMask = function()
  love.graphics.setShader(maskShader)
  love.graphics.draw(currentStencil, 0, 0)
  return love.graphics.setShader()
end

bossHealthInit = 0
bossHealth = 0
bossName = ''
bossSpell = ''
currentStage = 1

require('start')
require('controls')
require('background')
require('drops')
require('player')
require('enemies')
require('stage')
require('graze')
require('explosions')
require('collision')
require('chrome')

local setupColors = function()
  for color, v in pairs(colors) do
    local _, _, r, g, b, a = colors[color]:find('(%x%x)(%x%x)(%x%x)')
    colors[color] = {tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, 1}
  end
	colors.transparent = {1, 1, 1, .5}
	colors.transparentBlack = {0, 0, 0, .67}
end

getAngle = function(b, a)
  return math.atan2(a.y - b.y, a.x - b.x)
end

drawLabel = function(input, x, y, labelColor, alignObject)
  input = string.upper(input)
  local color = colors.offWhite
	local align = 'left'
	local limit = 512
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

startGame = function()
	background.load()
	drops.load()
	player.load()
	stage.load()
	graze.load()
	explosions.load()
	loadChrome()
end

love.load = function()
  love.window.setTitle('凍結塵芥')
  container = love.graphics.newCanvas(winWidth, winHeight)
  container:setFilter('nearest', 'nearest')
  love.window.setMode(winWidth * gameScale, winHeight * gameScale, {vsync = false})
  love.graphics.setLineStyle('rough')
  love.graphics.setLineWidth(1)
  font:setFilter('nearest', 'nearest')
  love.graphics.setFont(font)
  setupColors()
	if started then startGame()
	else start.load() end
end

love.update = function(d)
  dt = d
  controls.update()
	if started then
	  background.update()
		drops.update()
	  player.update()
	  stage.update()
		graze.update()
	  explosions.update()
	  collision.update()
		updateChrome()
	else start.update() end
end

love.draw = function()
  container:renderTo(love.graphics.clear)
  love.graphics.setCanvas({
    container,
    stencil = true
  })
  currentStencil = masks.half
  love.graphics.stencil(setStencilMask, 'replace', 1)
	if started then
	  background.draw()
		drops.draw()
	  player.draw()
	  stage.draw()
		player.drawBullets()
		graze.draw()
	  explosions.draw()
	  drawChrome()
	else start.draw() end
  love.graphics.setCanvas()
  local windowX = 0
  love.graphics.draw(container, windowX, 0, 0, gameScale, gameScale)
  gameClock = gameClock + 1
  if dt < frameLimit then
    return love.timer.sleep(frameLimit - dt)
  end
end
