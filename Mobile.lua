--[[

  Mobile class
 
]]--

local Mobile = {}
Mobile.__index = Mobile

function Mobile:new(name, filename, x, y, mapdata)
  
  x = math.floor(x)
  y = math.floor(y)
  
  local itm = {
      
      props = {
          name = name
          ,direction = "up"
          ,x = x
          ,y = y
          ,mapdata = mapdata
          ,hpmax = 10
          ,hp = 10
          ,def = 2
          ,atk = 2
        }
    
    }
  setmetatable(itm, Mobile)
  --itm.props.tilesheets[name] = { }
  itm:loadSheet(name, filename)
  setMobCell(x, y, itm)
  return itm
  
end

function Mobile:die()
  local loot = {}
  
  return loot
end

function Mobile:attack(target)
  
end

function Mobile:defend(atk)
  local d = math.floor(math.random() * self:get("def")) + 1 - 1
  atk = atk - d * self:get("def")
  self:set("hp", self:get("hp") - atk)
end

function Mobile:loadSheet(id, file)
  images.tilesheets[id] = {
      {}
      ,{}
      ,{}
    }

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

function Mobile:set(prop, val)

  self.props[prop] = val
  
  return true
  
end

function Mobile:get(prop)
    
  if self.props[prop] == nil then
    return false
  end
  
  return self.props[prop]
  
end

function Mobile:move(drow, dcol)
  local oldx = self:get("x")
  local oldy = self:get("y")
  self:set("x", self:get("x") + dcol)
  self:set("y", self:get("y") + drow)
  local tid = getTile(self:get("x"), self:get("y"))
  if getTileProps(tid).solid
    or getMobCell(self:get("x"), self:get("y")) ~= 0
    or (self:get("x") == player:get("x") and self:get("y") == player:get("y"))
    or tid == findTileId("medieval_door")
  then
    
    self:set("x", oldx)
    self:set("y", oldy)
    return
  end
  setMobCell(oldx, oldy, 0)
  setMobCell(self:get("x"), self:get("y"), self)
end

function Mobile:draw(row, col)
  local px = self:get("x")
  local py = self:get("y")
  local id = self:get("name")
  local dx = 0
  if col > 4 and row == 3 then
    dx = 80
  elseif col > 2 and row < 3 then
    dx = 80
  end
    
  love.graphics.draw(images.tilesheets[id].image, images.tilesheets[id][row][col], dx, 0)
  
end

function Mobile:update(dt)
  local mobUpdate = math.random(1, 1000)
  local mx = 0
  local my = 0
  local dir = math.random(1, 4)

  if dir == 1 then
    mx = 1
  elseif dir == 2 then
    mx = -1
  elseif dir == 3 then
    my = 1
  elseif dir == 4 then
    my = -1
  end

  if mobUpdate > 990 then

    self:move(mx, my)
  end
end

return Mobile