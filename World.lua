--[[

  World class
 
]]--

local World = {}
World.__index = World

function World:new(filename)
  
  local itm = {
      
      props = {
          filename = filename
          ,areas = {}
          ,currentArea = 1
        }
    
    }
  setmetatable(itm, World)
  itm:load(filename)
  return itm
  
end

function World:load(filename)
  local startArea = Area:new(64, 64)
  startArea:load(filename)
  table.insert(self.props.areas, startArea)
  self:set("currentArea", #self.props.areas)
  return startArea
end

function World:currentArea()
  return self:get("areas")[self:get("currentArea")]
end


function World:areaExits(exit_dir)
  
  local arealist = {}

  function findarea(area, x, y)
    arealist[area] = {id = area, x=x, y=y}

    local ar = worldControl:get("areas")[area]
    if ar:get("exits").east and not arealist[ar:get("exits").east] then
      findarea(ar:get("exits").east, x + 32, y)
    end
    if ar:get("exits").west and not arealist[ar:get("exits").west] then
      findarea(ar:get("exits").west, x - 32, y)
    end
    if ar:get("exits").south and not arealist[ar:get("exits").south] then
      findarea(ar:get("exits").south, x, y + 32)
    end
    if ar:get("exits").north and not arealist[ar:get("exits").north] then
      findarea(ar:get("exits").north, x, y - 32)
    end
    local tname = ar:get("terrain")
    if tname == "home" then return end      
  end
  
  local cx = 1
  local cy = 1
  findarea(worldControl:get("currentArea"), cx, cy)
  
  for i=1, #arealist do
    if newx == arealist[i].x and newy == arealist[i].y then
      
    end
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

function World:addArea(area)
  table.insert(self.props.areas, area)
  return #self.props.areas
end

function World:setArea(index, area)
  self.props.areas[index] = area
  return #self.props.areas
end


function World:set(prop, val)

  self.props[prop] = val
  
  return true
  
end

function World:get(prop)
    
  if self.props[prop] == nil then
    return false
  end
  
  return self.props[prop]
  
end

return World