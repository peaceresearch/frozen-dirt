math.tau = math.pi * 2
hc = require('lib/hc')
bitser = require('lib/bitser')
winWidth = 240
winHeight = 320
gameScale = 3
grid = 16
gameWidth = winWidth
gameHeight = winHeight
gameX = 0
gameY = 0
colors = {
	-- db16 by dawnbringer
	black = '140c1c',
	purple = '442434',
	blueDark = '30346d',
	blue = '597dce',
	blueLight = '6dc2ca',
	red = 'd04648',
	offWhite = 'deeed6',
	grayLight = '8595a1',
	white = 'ffffff'
}
gameClock = 0
highScore = 0
scoreTable = false
currentScore = 0
currentGraze = 0
paused = false
gameOver = false
started = false
aniTime = 25
dt = 0
frameLimit = 1 / 60
goingToBossClock = 0
goingToBossLimit = 60 * 3
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
paused = false
isFullscreen = false
isTate = false
nextBoss = false

require('sound')
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

local function setupColors()
  for color, v in pairs(colors) do
    local _, _, r, g, b, a = colors[color]:find('(%x%x)(%x%x)(%x%x)')
    colors[color] = {tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, 1}
  end
end

function getAngle(b, a)
  return math.atan2(a.y - b.y, a.x - b.x)
end

function drawLabel(input, x, y, labelColor, alignObject)
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
end

function startGame()
	background.load()
	drops.load()
	player.load()
	stage.load()
	graze.load()
	explosions.load()
	loadChrome()
	sound.playBgm('level2')
end

function startStencil(mask)
	currentStencil = masks[mask]
	love.graphics.stencil(setStencilMask, 'replace', 1)
	love.graphics.setStencilTest('greater', 0)
end

function endStencil()
  love.graphics.setStencilTest()
end

function recordScore()
	table.insert(scoreTable, currentScore)
	local scoreStr = bitser.dumps(scoreTable)
	love.filesystem.write('score.lua', scoreStr)
end

local function loadScores()
	local scoreData = love.filesystem.read('score.lua')
	if scoreData then
		scoreTable = bitser.loads(scoreData)
		table.sort(scoreTable, function(a, b)
		 return a > b
		end)
	else scoreTable = {} end
end

function love.load()
  love.window.setTitle('凍結塵芥')
  container = love.graphics.newCanvas(winWidth, winHeight)
  container:setFilter('nearest', 'nearest')
  love.window.setMode(winWidth * gameScale, winHeight * gameScale, {vsync = false})
  love.graphics.setLineStyle('rough')
  love.graphics.setLineWidth(1)
  font:setFilter('nearest', 'nearest')
  love.graphics.setFont(font)
	loadScores()
  setupColors()
  loadControls()
	sound.load()
	if started then startGame()
	else start.load() end
end

function love.update(d)
  dt = d
  updateControls()
	if started then
		if not paused then
		  background.update()
			drops.update()
		  if not gameOver then player.update() end
		  stage.update()
			graze.update()
		  explosions.update()
		  if not gameOver then collision.update() end
		end
		updateChrome()
	else start.update() end
end

function love.draw()
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
		drawEnemies()
	  if not gameOver then player.draw() end
	  stage.draw()
		player.drawBullets()
		graze.draw()
	  explosions.draw()
	  drawChrome()
	else start.draw() end
  love.graphics.setCanvas()
  local windowX = 0
	local windowY = 0
	local rotation = 0
	local fullscreenWidth, fullscreenHeight = love.window.getDesktopDimensions()
	if isFullscreen then
		windowX = fullscreenWidth / 2 - gameWidth / 2 * gameScale
	end
	if isTate then
		rotation = -math.pi / 2
		windowX = fullscreenWidth / 2 - gameHeight / 2 * gameScale
		windowY = fullscreenHeight
		-- windowX = -gameHeight * 2
	end
  love.graphics.draw(container, windowX, windowY, rotation, gameScale, gameScale)
  if not paused then gameClock = gameClock + 1 end
  if dt < frameLimit then
    return love.timer.sleep(frameLimit - dt)
  end
end
