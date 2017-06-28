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