images = { 
    tilesheets = {}
  }
player = { } 
mobiles = { } 
tilemapping = {}
shaders = {}

-- Main UI Icons

local imgMoveEnergy = love.graphics.newImage("images/boot_24x24.png")
local imgHPIcon = love.graphics.newImage("images/heart_24x24.png")

skinui = require 'lib.SkinUI'

function newMob(m)
  table.insert(mobiles, m)
end

local Player = require 'Player'
Mobiles = require 'Mobile'
mapdata = {}
Area = require "Area"
Item = require "Item"
Inventory = require "Inventory"
local item_defs = require "GameItems"
local World = require 'World'

local worldControl = nil

local screenShotter = require 'Screenshotter.capture'

shaders.sineDistort = [[
  const float PI = 3.1415926535;
  extern float time;
  extern float radius;
  extern float fadeout_cutoff;

  vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
  {
    vec2 p = texture_coords;

    p.y += sin(p.x * PI * radius) * time;
    
    vec4 c = Texel(texture, p);
    if (time > fadeout_cutoff)
    {
      c.a = 1 - (time - fadeout_cutoff) * 10;
    }
    return c;
  }
]]

function ItemFactory(name, image, props)
  
  if not props then props = {} end
  local itm = Item:new(image, name)
  
  for key, value in props do
    itm:set(key, value)
  end

  return itm
  
end

function drawTile(id, row, col)
  if row > mapdata.layers[1].height or col > mapdata.layers[1].width or not id then return end
  
  local dx = 0
  if col > 4 and row == 3 then
    dx = 80
  elseif col > 2 and row < 3 then
    dx = 80
  end
    
  love.graphics.draw(images.tilesheets[id].image, images.tilesheets[id][row][col], dx, 0)
  
end

function findTileId(name)
  local c = 1
  for k in pairs(images.tilesheets) do
    if k == name then
      return c
    end
    c = c + 1
  end
  return false
end

function loadTile(id, file)
  images.tilesheets[id] = {
      {}
      ,{}
      ,{}
    }
    
  table.insert(tilemapping, id)
  images.tilesheets[id].image = love.graphics.newImage("images/" .. file)
  images.tilesheets[id][3][1] = love.graphics.newQuad(0, 0, 80, 120, images.tilesheets[id].image:getDimensions())
  images.tilesheets[id][3][2] = love.graphics.newQuad(160, 0, 80, 120, images.tilesheets[id].image:getDimensions())
  images.tilesheets[id][3][3] = love.graphics.newQuad(320, 0, 80, 120, images.tilesheets[id].image:getDimensions())
  images.tilesheets[id][3][4] = love.graphics.newQuad(480, 0, 80, 120, images.tilesheets[id].image:getDimensions())
  images.tilesheets[id][3][5] = love.graphics.newQuad(80, 0, 80, 120, images.tilesheets[id].image:getDimensions())
  images.tilesheets[id][3][6] = love.graphics.newQuad(560, 0, 80, 120, images.tilesheets[id].image:getDimensions())
  images.tilesheets[id][3][7] = love.graphics.newQuad(240, 0, 80, 120, images.tilesheets[id].image:getDimensions())
  images.tilesheets[id][3][8] = love.graphics.newQuad(400, 0, 80, 120, images.tilesheets[id].image:getDimensions())
  
  images.tilesheets[id][2][1] = love.graphics.newQuad(0, 120, 80, 120, images.tilesheets[id].image:getDimensions())
  images.tilesheets[id][2][2] = love.graphics.newQuad(160, 120, 80, 120, images.tilesheets[id].image:getDimensions())
  images.tilesheets[id][2][3] = love.graphics.newQuad(80, 120, 80, 120, images.tilesheets[id].image:getDimensions())
  images.tilesheets[id][2][4] = love.graphics.newQuad(240, 120, 80, 120, images.tilesheets[id].image:getDimensions())

  images.tilesheets[id][1][1] = love.graphics.newQuad(320, 120, 80, 120, images.tilesheets[id].image:getDimensions())
  images.tilesheets[id][1][2] = love.graphics.newQuad(480, 120, 80, 120, images.tilesheets[id].image:getDimensions())
  images.tilesheets[id][1][3] = love.graphics.newQuad(400, 120, 80, 120, images.tilesheets[id].image:getDimensions())
  images.tilesheets[id][1][4] = love.graphics.newQuad(560, 120, 80, 120, images.tilesheets[id].image:getDimensions())

end

function getTileProps(t)
  if not t or not mapdata.tilesets[1].tiles[t] then return {} end
  return mapdata.tilesets[1].tiles[t].properties

end

function getTile(x, y, l)
  if not l then l = 1 end
  if x == nil or y == nil or x < 0 or y < 0 then return -1 end
  if x > mapdata.layers[l].width or y > mapdata.layers[l].height then return -1 end
  
  return mapdata.layers[l].data[(y * mapdata.layers[l].width) + x + 1]

end

function getMobCell(x, y)
  l = 2
  if x == nil or y == nil or x < 0 or y < 0 then return -1 end
  if x > mapdata.layers[l].width or y > mapdata.layers[l].height then return -1 end
  
  local ret = mapdata.layers[l].data[(y * mapdata.layers[l].width) + x + 1]
  if ret then
    return ret
  else
    return 0
  end

end
function setMobCell(x, y, v)
  l = 2
  if x == nil or y == nil or x < 0 or y < 0 then return -1 end
  if x > mapdata.layers[l].width or y > mapdata.layers[l].height then return nil end

  mapdata.layers[l].data[(y * mapdata.layers[l].width) + x + 1] = v

end

function drawView()
  
  love.graphics.draw(images.background, 0, 0)
  
  local px = player:get("x")
  local py = player:get("y")

  -- Tile Processing
  if player:get("direction") == "down" then
    farLeft = getTile(px + 1, py + 2)
    farMiddle = getTile(px, py + 2)
    farRight = getTile(px - 1, py + 2)
    
    farNextLeft = getTile(px + 2, py + 2)
    farNextRight = getTile(px - 2, py + 2)

    midLeft = getTile(px + 1, py + 1)
    midMiddle = getTile(px, py + 1)
    midRight = getTile(px - 1, py + 1)
    midFarLeft = getTile(px + 2, py + 1)
    midFarRight = getTile(px - 2, py + 1)

    nearLeft = getTile(px + 1, py)
    nearMiddle = getTile(px, py)
    nearRight = getTile(px - 1, py)
  elseif player:get("direction") == "up" then
    farLeft = getTile(px - 1, py - 2)
    farMiddle = getTile(px, py - 2)
    farRight = getTile(px + 1, py - 2)
    
    farNextLeft = getTile(px - 2, py - 2)
    farNextRight = getTile(px + 2, py - 2)

    midLeft = getTile(px - 1, py - 1)
    midMiddle = getTile(px, py - 1)
    midRight = getTile(px + 1, py - 1)
    midFarLeft = getTile(px - 2, py - 1)
    midFarRight = getTile(px + 2, py - 1)

    nearLeft = getTile(px - 1, py)
    nearMiddle = getTile(px, py)
    nearRight = getTile(px + 1, py)
    
  elseif player:get("direction") == "right" then
    farLeft = getTile(px + 2, py - 1)
    farMiddle = getTile(px + 2, py)
    farRight = getTile(px + 2, py + 1)
    
    farNextLeft = getTile(px + 2, py - 2)
    farNextRight = getTile(px + 2, py + 2)
    
    midLeft = getTile(px + 1, py - 1)
    midMiddle = getTile(px + 1, py)
    midRight = getTile(px + 1, py + 1)
    midFarLeft = getTile(px + 1, py - 2)
    midFarRight = getTile(px + 1, py + 2)

    nearLeft = getTile(px, py - 1)
    nearMiddle = getTile(px, py)
    nearRight = getTile(px, py + 1)
    
  elseif player:get("direction") == "left" then
    farLeft = getTile(px - 2, py + 1)
    farMiddle = getTile(px - 2, py)
    farRight = getTile(px - 2, py - 1)
    
    farNextLeft = getTile(px - 2, py + 2)
    farNextRight = getTile(px - 2, py - 2)
    
    midLeft = getTile(px - 1, py + 1)
    midMiddle = getTile(px - 1, py)
    midRight = getTile(px - 1, py - 1)
    midFarLeft = getTile(px - 1, py + 2)
    midFarRight = getTile(px - 1, py - 2)

    nearLeft = getTile(px, py + 1)
    nearMiddle = getTile(px, py)
    nearRight = getTile(px, py - 1)

  end

  -- Mob Processing
  if player:get("direction") == "down" then
    mob_farLeft = getMobCell(px + 1, py + 2)
    mob_farMiddle = getMobCell(px, py + 2)
    mob_farRight = getMobCell(px - 1, py + 2)
    
    mob_farNextLeft = getMobCell(px + 2, py + 2)
    mob_farNextRight = getMobCell(px - 2, py + 2)

    mob_midLeft = getMobCell(px + 1, py + 1)
    mob_midMiddle = getMobCell(px, py + 1)
    mob_midRight = getMobCell(px - 1, py + 1)
    mob_midFarLeft = getMobCell(px + 2, py + 1)
    mob_midFarRight = getMobCell(px - 2, py + 1)

    mob_nearLeft = getMobCell(px + 1, py)
    mob_nearMiddle = getMobCell(px, py)
    mob_nearRight = getMobCell(px - 1, py)
  elseif player:get("direction") == "up" then
    mob_farLeft = getMobCell(px - 1, py - 2)
    mob_farMiddle = getMobCell(px, py - 2)
    mob_farRight = getMobCell(px + 1, py - 2)
    
    mob_farNextLeft = getMobCell(px - 2, py - 2)
    mob_farNextRight = getMobCell(px + 2, py - 2)

    mob_midLeft = getMobCell(px - 1, py - 1)
    mob_midMiddle = getMobCell(px, py - 1)
    mob_midRight = getMobCell(px + 1, py - 1)
    mob_midFarLeft = getMobCell(px - 2, py - 1)
    mob_midFarRight = getMobCell(px + 2, py - 1)

    mob_nearLeft = getMobCell(px - 1, py)
    mob_nearMiddle = getMobCell(px, py)
    mob_nearRight = getMobCell(px + 1, py)
    
  elseif player:get("direction") == "right" then
    mob_farLeft = getMobCell(px + 2, py - 1)
    mob_farMiddle = getMobCell(px + 2, py)
    mob_farRight = getMobCell(px + 2, py + 1)
    
    mob_farNextLeft = getMobCell(px + 2, py - 2)
    mob_farNextRight = getMobCell(px + 2, py + 2)
    
    mob_midLeft = getMobCell(px + 1, py - 1)
    mob_midMiddle = getMobCell(px + 1, py)
    mob_midRight = getMobCell(px + 1, py + 1)
    mob_midFarLeft = getMobCell(px + 1, py - 2)
    mob_midFarRight = getMobCell(px + 1, py + 2)

    mob_nearLeft = getMobCell(px, py - 1)
    mob_nearMiddle = getMobCell(px, py)
    mob_nearRight = getMobCell(px, py + 1)
    
  elseif player:get("direction") == "left" then
    mob_farLeft = getMobCell(px - 2, py + 1)
    mob_farMiddle = getMobCell(px - 2, py)
    mob_farRight = getMobCell(px - 2, py - 1)
    
    mob_farNextLeft = getMobCell(px - 2, py + 2)
    mob_farNextRight = getMobCell(px - 2, py - 2)
    
    mob_midLeft = getMobCell(px - 1, py + 1)
    mob_midMiddle = getMobCell(px - 1, py)
    mob_midRight = getMobCell(px - 1, py - 1)
    mob_midFarLeft = getMobCell(px - 1, py + 2)
    mob_midFarRight = getMobCell(px - 1, py - 2)

    mob_nearLeft = getMobCell(px, py + 1)
    mob_nearMiddle = getMobCell(px, py)
    mob_nearRight = getMobCell(px, py - 1)

  end

  drawTile(tilemapping[farNextLeft], 3, 1)
  
  drawTile(tilemapping[farLeft], 3, 2)
  drawTile(tilemapping[farMiddle], 3, 3)
    
  drawTile(tilemapping[farNextRight], 3, 5)

  drawTile(tilemapping[farRight], 3, 7)
  drawTile(tilemapping[farMiddle], 3, 8)

  if mob_farNextLeft and type(mob_farNextLeft) == "table" then mob_farNextLeft:draw(3, 1) end
  if mob_farLeft and type(mob_farLeft) == "table" then mob_farLeft:draw(3, 2) end
  if mob_farMiddle and type(mob_farMiddle) == "table" then mob_farMiddle:draw(3, 3) end
  if mob_farNextRight and type(mob_farNextRight) == "table" then mob_farNextRight:draw(3, 5) end
  if mob_farRight and type(mob_farRight) == "table" then mob_farRight:draw(3, 7) end
  if mob_farMiddle and type(mob_farMiddle) == "table" then mob_farMiddle:draw(3, 8) end
  
  drawTile(tilemapping[midFarLeft], 3, 4)
  drawTile(tilemapping[midFarRight], 3, 6)
  drawTile(tilemapping[midLeft], 2, 1)
  drawTile(tilemapping[midMiddle], 2, 2)
  drawTile(tilemapping[midRight], 2, 3)
  drawTile(tilemapping[midMiddle], 2, 4)
  
  if mob_midFarLeft and type(mob_midFarLeft) == "table" then mob_midFarLeft:draw(3, 4) end
  if mob_midFarRight and type(mob_midFarRight) == "table" then mob_midFarRight:draw(3, 6) end
  if mob_midLeft and type(mob_midLeft) == "table" then mob_midLeft:draw(2, 1) end
  if mob_midMiddle and type(mob_midMiddle) == "table" then mob_midMiddle:draw(2, 2) end
  if mob_midRight and type(mob_midRight) == "table" then mob_midRight:draw(2, 3) end
  if mob_midMiddle and type(mob_midMiddle) == "table" then mob_midMiddle:draw(2, 4) end
  
  drawTile(tilemapping[nearLeft], 1, 1)
  drawTile(tilemapping[nearMiddle], 1, 2)
  drawTile(tilemapping[nearRight], 1, 3)
  drawTile(tilemapping[nearMiddle], 1, 4)

  if mob_nearLeft and type(mob_nearLeft) == "table" then mob_nearLeft:draw(1, 1) end
  if mob_nearMiddle and type(mob_nearMiddle) == "table" then mob_nearMiddle:draw(1, 2) end
  if mob_nearRight and type(mob_nearRight) == "table" then mob_nearRight:draw(1, 3) end
  if mob_nearMiddle and type(mob_nearMiddle) == "table" then mob_nearMiddle:draw(1, 4) end
  
end

function distance ( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
end

function drawMiniMap()
  
  local scale = 4
  
  love.graphics.push()
  love.graphics.scale(scale, scale)
  local cx = 600 / scale
  local cy = 50 / scale
  local r = 10
  local px = player:get("x")
  local py = player:get("y")
  for i= r * -1, r do
    for j = r * -1, r do
      local tid = getTile(px + j, py + i)
      local sh_d = distance(px + j, py + i, px, py)
      local sh_f = 1 - (sh_d / r)
      if getTileProps(tid).solid then
        love.graphics.setColor(255 * sh_f, 255 * sh_f, 255 * sh_f, 255)
      else
        love.graphics.setColor(125 * sh_f, 125 * sh_f, 125 * sh_f, 255)
      end
      if i == 0 and j == 0 then love.graphics.setColor(200, 200, 0) end
      if getMobCell(px + j, py + i) and type(getMobCell(px + j, py + i)) == "table" then love.graphics.setColor(0, 255, 0, 125) end
      love.graphics.rectangle("fill", cx + j, cy + i, 1, 1)
      love.graphics.setColor(255, 255, 255, 255)     
    end
  end
  love.graphics.pop()
  
  love.graphics.draw(imgMoveEnergy, 485, 45)
  love.graphics.draw(imgHPIcon, 485, 80)
  
  love.graphics.setColor(200, 200, 0, 255)     
  local f = player:get("endurance") / player:get("endurance_max")
  love.graphics.arc( "fill", 525, 58, 10, 0, (math.pi * 2) * f )
  love.graphics.setColor(0, 25, 155, 255)     
  love.graphics.arc( "fill", 525, 58, 9, 0, (math.pi * 2) * (f - 0.02) )
  love.graphics.setColor(255, 255, 255, 255)     

end

function love.mousemoved(x, y, dx, dy, istouch)
  
  skinui:mousemoved(x, y, dx, dy, istouch)
  
end

function love.textinput(t)
  
  skinui:textinput(t)
  
end

function love.mousereleased(x, y, button, istouch)
  
  skinui:mousereleased(x, y, button, istouch)
  
end

function love.mousepressed(x, y, dx, dy, istouch)
  
  skinui:mousepressed(x, y, dx, dy, istouch)
  
end

function uiWorldmap()
  skinui:remove("winWorldmap")
  local winv = skinui.Window:new("winWorldmap", 15, 15, skinui.theme.default)
  winv:size(500, 390)
  skinui:add(winv)
  
  local btnClose = skinui.ButtonTiny:new("btnClose", 465, 5, skinui.theme.default)
  btnClose:set("text", "X")
  function btnClose:onclick()
    skinui:remove("winWorldmap")
  end
  
  function winv:ondraw()
    
    local colrs = {
        
        grassland =   {25, 200, 100, 255}
        ,home =       {175, 75, 0, 255}
        ,forest =     {25, 175, 25, 255}
        ,desert =     {255, 225, 25, 255}
        ,none =       {0, 0, 0, 0}
      }
    local arealist = {}

    function drawarea(area, x, y)
      arealist[area] = {id = area, x=x, y=y}

      local ar = worldControl:get("areas")[area]
      if ar:get("exits").east and not arealist[ar:get("exits").east] then
        drawarea(ar:get("exits").east, x + 32, y)
      end
      if ar:get("exits").west and not arealist[ar:get("exits").west] then
        drawarea(ar:get("exits").west, x - 32, y)
      end
      if ar:get("exits").south and not arealist[ar:get("exits").south] then
        drawarea(ar:get("exits").south, x, y + 32)
      end
      if ar:get("exits").north and not arealist[ar:get("exits").north] then
        drawarea(ar:get("exits").north, x, y - 32)
      end
      local tname = ar:get("terrain")
      if tname == "home" then return end      
    end
    
    local cx = math.floor(self:get("left") + self:get("width") / 2) - 16
    local cy = math.floor(self:get("top") + self:get("height") / 2) - 16
    drawarea(worldControl:get("currentArea"), cx, cy)
    
    for i=1, #arealist do
      local ar = worldControl:get("areas")[i]
      local tname = ar:get("terrain")
      love.graphics.setColor(colrs[tname])
      love.graphics.rectangle("fill", arealist[i].x, arealist[i].y, 32, 32)
    end
    love.graphics.setColor({255, 255, 0, 255})
    if love.timer.getTime() % 1 > 0.5 then
      love.graphics.rectangle("line", arealist[worldControl:get("currentArea")].x, arealist[worldControl:get("currentArea")].y, 32, 32)
    end

    
    local dy = 20
    for key, value in pairs(colrs) do
      if key ~= "none" then
        love.graphics.setColor(colrs[key])
        love.graphics.rectangle("fill",  self:get("left") + 15,  self:get("top") + dy + 5, 35, 15)
        love.graphics.print(key, self:get("left") + 55, self:get("top") + dy + 5)
        dy = dy + 20
      end
    end
    love.graphics.setColor({255, 255, 255, 255})
  end
    
  skinui:addChild("winWorldmap", btnClose)

end

function uiViewInventory()
  
  skinui:remove("winInv")
  local winv = skinui.Window:new("winInv", 75, 15, skinui.theme.default)
  winv:size(225, 275)
  winv:set("imgSlot", love.graphics.newImage("images/item_outline.png"))
  skinui:add(winv)
  
  local btnClose = skinui.ButtonTiny:new("btnClose", winv:get("width") - 30, 5, skinui.theme.default)
  btnClose:set("text", "X")
  function btnClose:onclick()
    skinui:remove("winInv")
  end
  function btnClose:update(dt)
    self:set("left", winv:get("width") - 30)
  end
  
  function winv:ondraw()
    btnClose:update(0)
    if not player:get("inventory") then return end
    local inv = player:get("inventory")
    local dx = 0
    local dy = 0
    local wx = self:get("left") + 25
    local wy = self:get("top") + 54
    for si=1, inv:max_slots() do
      local el = inv:get(si)
      love.graphics.setColor(255, 255, 255, 75)
      love.graphics.draw(self:get("imgSlot"), dx + wx, dy + wy)
      love.graphics.setColor(255, 255, 255, 255)
      dx = dx + 34
      if dx > self:get("width") - 64 then
        dx = 0
        dy = dy + 34
        if dy > self:get("height") - 128 then
          break
        end
      end
    end
  end
  
  function winv:onresize()
    
    if not player:get("inventory") then return end
    local inv = player:get("inventory")
    local dx = 0
    local dy = 0
    local wx = 24
    local wy = 54
    for si=1, inv:max_slots() do
      local el = inv:get(si)
      if el then
        local imgItem = skinui.Image:new("imgItem" .. si, dx + wx, dy + wy, skinui.theme.default)
        function imgItem:onclick()
          message("Equipped " .. el.name .. ".")
          skinui:removeChild("winInv", imgItem:get("id"))
          player:set("weapon", el)
          inv:remove(si)
          if skinui:find("winEq") then uiViewEquip() end
        end
        imgItem:set("image", el:get("image"))
        skinui:addChild("winInv", imgItem)
      end
      dx = dx + 34
      if dx > self:get("width") - 64 then
        dx = 0
        dy = dy + 34
        if dy > self:get("height") - 128 then
          break
        end
      end
    end
  end

  winv:resize()
  
  local btnDrop = skinui.ButtonSmall:new("btnDrop", 10, 10, skinui.theme.default)
  btnDrop:set("text", "Drop")
  local btnEquip = skinui.ButtonSmall:new("btnEquip", 75, 10, skinui.theme.default)
  btnEquip:set("text", "Equip")
  
  skinui:addChild("winInv", btnEquip)
  skinui:addChild("winInv", btnDrop)
  skinui:addChild("winInv", btnClose)
end

function uiViewEquip()
  skinui:remove("winEq")
  local winEq = skinui.Window:new("winEq", 480, 115, skinui.theme.default)
  winEq:size(225, 275)
  winEq:set("fixed", true)
  skinui:add(winEq)
  
  local imgOutline = skinui.Image:new("imgOutline", 75, 25, skinui.theme.default)
  imgOutline:set("image", "images/equip_outline.png")
 
  local imgItemSlot1 = skinui.Image:new("imgItemSlot1", 65, 25, skinui.theme.default)
  imgItemSlot1:set("image", "images/item_outline.png")
  
  local imgWeapon = skinui.Image:new("imgWeapon", 40, 120, skinui.theme.default)
  imgWeapon:set("image", "images/item_outline.png")
  
  local imgItemSlot3 = skinui.Image:new("imgItemSlot3", 150, 115, skinui.theme.default)
  imgItemSlot3:set("image", "images/item_outline.png")
  
  local imgItemSlot4 = skinui.Image:new("imgItemSlot4", 45, 210, skinui.theme.default)
  imgItemSlot4:set("image", "images/item_outline.png")
  
  local imgItemSlot5 = skinui.Image:new("imgItemSlot5", 95, 75, skinui.theme.default)
  imgItemSlot5:set("image", "images/item_outline.png")

  local btnClose = skinui.ButtonTiny:new("btnClose", 195, 5, skinui.theme.default)
  btnClose:set("text", "X")
  function btnClose:onclick()
    skinui:remove("winEq")
  end
  
  if player:get("weapon") then
    imgWeapon:set("image", player:get("weapon"):get("image"))
  end
  
  function imgWeapon:onclick()
    local inv = player:get("inventory")
    
    inv:add(player:get("weapon"))
    player:set("weapon", nil)
    
    if skinui:find("winInv") then
      skinui:get("winInv"):onresize()
    end
    uiViewEquip()
  end
    
  skinui:addChild("winEq", imgItemSlot1)
  skinui:addChild("winEq", imgWeapon)
  skinui:addChild("winEq", imgItemSlot3)
  skinui:addChild("winEq", imgItemSlot4)
  skinui:addChild("winEq", imgItemSlot5)
  
  skinui:addChild("winEq", imgOutline)
  
  skinui:addChild("winEq", btnEquip)
  skinui:addChild("winEq", btnDrop)
  skinui:addChild("winEq", btnClose)
end

function changeArea(index)
  local md = worldControl:get("areas")[index]
  message("Entering area '" .. md:get("terrain") .. "'.")
  if md then
    mapdata = md:get("mapdata")
    worldControl:set("currentArea", index)
    md:generateMobs()
    return true;
  end
  return false;
end

function message(msg)
  local panel = skinui:get("winPanel")
  if not panel then return end
  local id = panel:find("lstStatus")
  local lstStatus = panel:get("windows")[id]
  if not lstStatus then return end
  lstStatus:add(msg)  
  --lstStatus:scroll(lstStatus:count() - 10)
end

function love.load()
  love.graphics.setFont(love.graphics.newFont("alagard.ttf", 14))
  
  skinui:load()
  
  worldControl = World:new("dungeon")
  
  local cpanel = skinui.Window:new("winPanel", 480, 115, skinui.theme.default)
  cpanel:size(250, 295)
  skinui:add(cpanel)
  
  local status = skinui.Listbox:new("lstStatus", 5, 0, 250, 290, skinui.theme.default)
  skinui:addChild("winPanel", status)
    
  changeArea(1)
  
  local hotbar = skinui.Window:new("winHotbar", 0, 360, skinui.theme.default)
  hotbar:size(480, 50)
  skinui:add(hotbar)
  
  local btnHotbar1 = skinui.ButtonSmall:new("btnHotbar1", 10, 10, skinui.theme.default)
  btnHotbar1:set("text", "Inv.")
  function btnHotbar1:onclick()
    uiViewInventory()
  end
  skinui:addChild("winHotbar", btnHotbar1)
  
  local btnHotbar2 = skinui.ButtonSmall:new("btnHotbar2", 80, 10, skinui.theme.default)
  function btnHotbar2:onclick()
    uiViewEquip()
  end
  btnHotbar2:set("text", "Equip.")
  skinui:addChild("winHotbar", btnHotbar2)
  
  local btnHotbar3 = skinui.ButtonSmall:new("btnHotbar3", 150, 10, skinui.theme.default)
  function btnHotbar3:onclick()
    uiWorldmap()
  end
  btnHotbar3:set("text", "Map")
  skinui:addChild("winHotbar", btnHotbar3)
    
  -- Set Background
  images.background = love.graphics.newImage("images/nightsky.png")
  
  -- Load Tilesheets
  loadTile("grass", "grass.png")
  loadTile("dungeon_floor", "dungeon_floor.png")
  loadTile("medieval_house", "medieval_house.png")
  loadTile("chest_exterior", "chest_exterior.png")
  loadTile("medieval_door", "medieval_door.png")
  loadTile("tree_evergreen", "tree_evergreen.png")
  loadTile("water", "water.png")
  loadTile("grave_cross", "grave_cross.png")
  loadTile("rocky_grass", "rocky_grass.png")
  loadTile("grass_flowers", "grass_flowers.png")
  loadTile("desert", "desert.png")

  -- Create Player
  player = Player:new("Player1")
  player:get("inventory"):add(Item:new("images/items/swordWood.png", "Wooden Sword"))
  player:set("x", 32)
  player:set("y", 32)

end

function love.update(dt)

  skinui:update(dt)
  screenShotter.update(dt)
  
  player:update(dt)
  for i=1, #mobiles do
    
    mobiles[i]:update(dt)
    
  end
end

function love.draw()
  
  love.graphics.push()
  love.graphics.scale(3, 3)
  
  drawView()
  
  love.graphics.pop()
  
  drawMiniMap()
  skinui:draw()
  
end

function movePlayer(dir, amt)
  
  if player:get("endurance") <= 0 then return end
  
  local moveCost = 0.1
  
  local oldx = player:get("x")
  local oldy = player:get("y")
  
  if dir == "down" then
    
    if player:get("direction") == "up" then
      player:set("y", player:get("y") + amt)
    elseif player:get("direction") == "down" then
      player:set("y", player:get("y") - amt)
    elseif player:get("direction") == "right" then
      player:set("x", player:get("x") - amt)
    elseif player:get("direction") == "left" then
      player:set("x", player:get("x") + amt)
    end
  elseif dir == "up" then
    if player:get("direction") == "up" then
      player:set("y", player:get("y") - amt)
    elseif player:get("direction") == "down" then
      player:set("y", player:get("y") + amt)
    elseif player:get("direction") == "right" then
      player:set("x", player:get("x") + amt)
    elseif player:get("direction") == "left" then
      player:set("x", player:get("x") - amt)
    end
  elseif dir == "right" then
    if player:get("direction") == "up" then
      player:set("direction", "right")
    elseif player:get("direction") == "right" then
      player:set("direction", "down")
    elseif player:get("direction") == "down" then
      player:set("direction", "left")
    elseif player:get("direction") == "left" then
      player:set("direction", "up")
    end
  elseif dir == "left" then
    if player:get("direction") == "down" then
      player:set("direction", "right")
    elseif player:get("direction") == "right" then
      player:set("direction", "up")
    elseif player:get("direction") == "up" then
      player:set("direction", "left")
    elseif player:get("direction") == "left" then
      player:set("direction", "down")
    end
  end
  
  local tid = getTile(player:get("x"), player:get("y"))
  if getTileProps(tid).solid or getMobCell(player:get("x"), player:get("y")) ~= 0 then
    if type(getMobCell(player:get("x"), player:get("y"))) == "table" then
      message ("Bumped into a " .. getMobCell(player:get("x"), player:get("y")):get("name") .. ".")
    end
    player:set("x", oldx)
    player:set("y", oldy)
  end
  
  
  print(player:get("endurance"), player:get("endurance_max"))
  if player:get("endurance") < player:get("endurance_rechargeRate") then return end
  player:set("endurance", player:get("endurance") - moveCost)
 
end

function changeEast()
  local ar = worldControl:currentArea()
  if ar:get("exits").east then
    changeArea(ar:get("exits").east)
  else
    local na = Area:new(64, 64)
    local terrainName = ar:get("mapdata").properties.terrain_type
    na:generate(terrainName, "east")
    local naexit = na:get("exits")
    naexit.west = worldControl:get("currentArea")
    na:set("exits", naexit)
    local exits = ar:get("exits")
    exits.east = worldControl:addArea(na)
    ar:set("exits", exits)
    worldControl:setArea(worldControl:get("currentArea"), ar)
    changeArea(exits.east)
  end
  player:set("x", 2)
  
end

function changeWest()
  
  local ar = worldControl:currentArea()
  if ar:get("exits").west then
    changeArea(ar:get("exits").west)
  else
    local na = Area:new(64, 64)
    local terrainName = ar:get("mapdata").properties.terrain_type
    na:generate(terrainName, "west")
    local naexit = na:get("exits")
    naexit.east = worldControl:get("currentArea")
    na:set("exits", naexit)
    local exits = ar:get("exits")
    exits.west = worldControl:addArea(na)
    ar:set("exits", exits)
    changeArea(exits.west)
  end
  player:set("x", worldControl:currentArea():get("mapdata").width - 1)

end

function changeNorth()
  
  local ar = worldControl:currentArea()
  if ar:get("exits").north then
    changeArea(ar:get("exits").north)
  else
    local na = Area:new(64, 64)
    local terrainName = ar:get("mapdata").properties.terrain_type
    na:generate(terrainName, "north")
    local naexit = na:get("exits")
    naexit.south = worldControl:get("currentArea")
    na:set("exits", naexit)
    local exits = ar:get("exits")
    exits.north = worldControl:addArea(na)
    ar:set("exits", exits)
    changeArea(exits.north)
  end
  player:set("y", worldControl:currentArea():get("mapdata").height - 1)

end

function changeSouth()
  
  local ar = worldControl:currentArea()
  if ar:get("exits").south then
    changeArea(ar:get("exits").south)
  else
    local na = Area:new(64, 64)
    local terrainName = ar:get("mapdata").properties.terrain_type
    na:generate(terrainName, "south")
    local naexit = na:get("exits")
    naexit.north = worldControl:get("currentArea")
    na:set("exits", naexit)
    local exits = ar:get("exits")
    exits.south = worldControl:addArea(na)
    ar:set("exits", exits)
    changeArea(exits.south)
  end
  player:set("y", 2)

end

function love.keypressed(key, scancode)
  skinui:keypressed(key, scancode)
  
  local px = player:get("x")
  local py = player:get("y")
  if key == "left" or key == "up" or key == "down" or key == "right" then
    movePlayer(key, 1)
  end

  if key == "up" or key == "down" then
    if px == mapdata.layers[1].width then
      changeEast()
    elseif px == 1 then
      changeWest()
    elseif py == 1 then
      changeNorth()
    elseif py == mapdata.layers[1].height then
      changeSouth()
    end
  end

  if key == "f8" then
    screenShotter.startRecording("anim")
  elseif key == "f9" then
    screenShotter.stopRecording()
  end
  
end