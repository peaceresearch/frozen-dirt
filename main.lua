math.tau = math.pi * 2
hc = require('lib/hc')
winWidth = 640
winHeight = 480
gameScale = 2
grid = 16
gameWidth = grid * 24
gameHeight = grid * 28
gameX = winWidth / 2 - gameWidth / 2
gameY = grid
colors = {
  purpleLight = '76428a',
  pink = 'd77bba',
  redLight = 'd95763',
  blueMid = '639bff',
	blueDark = '306082',
	blueDarkest = '3f3f74',
  blue = '5b6ee1',
  orange = 'd27d2c',
	grayLightest = '9badb7',
  grayDark = '4e4a4e',
  yellow = 'dad45e',

	-- here be new colors
  black = '140c1c',
  purple = '442434',
  grayLight = '8595a1',
	blue = '30346d',
	blueLight = '597dce',
  blueLightest = '6dc2ca',
  green = '346524',
  greenLight = '6daa2c',
  gray = '4e4a4e',
  peach = 'd2aa99',
  red = 'd04648',
  brown = '854c30',
  offWhite = 'deeed6',
	white = 'ffffff'

}
gameClock = 0
highScore = 0
currentScore = 0
currentGraze = 0
paused = false
gameOver = false
started = false
aniTime = 15
dt = 0
frameLimit = 1 / 60
goingToBossClock = 0
goingToBossLimit = 60 * 2.5
fontBig = love.graphics.newFont('fonts/goldbox-big.ttf', 13)
font = love.graphics.newFont('fonts/goldbox.ttf', 8)
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
currentStage = 4

require('start')
require('controls')
require('background')
require('player')
require('enemies')
require('stage')
require('explosions')
require('collision')
require('chrome')

local setupColors = function()
  for color, v in pairs(colors) do
    local _, _, r, g, b, a = colors[color]:find('(%x%x)(%x%x)(%x%x)')
    colors[color] = {tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, 1}
  end
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
	player.load()
	stage.load()
	chrome.load()
	explosions.load()
end

love.load = function()
  love.window.setTitle('凍結塵芥')
  container = love.graphics.newCanvas(winWidth, winHeight)
  container:setFilter('nearest', 'nearest')
  love.window.setMode(winWidth * gameScale, winHeight * gameScale)
  love.graphics.setLineStyle('rough')
  love.graphics.setLineWidth(1)
  font:setFilter('nearest', 'nearest')
  fontBig:setFilter('nearest', 'nearest')
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
	  player.update()
	  stage.update()
	  explosions.update()
	  collision.update()
		chrome.update()
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
	  player.draw()
	  stage.draw()
		player.drawBullets()
	  explosions.draw()
	  chrome.draw()
	else start.draw() end
  love.graphics.setCanvas()
  local windowX = 0
  love.graphics.draw(container, windowX, 0, 0, gameScale, gameScale)
  gameClock = gameClock + 1
  if dt < frameLimit then
    return love.timer.sleep(frameLimit - dt)
  end
end
