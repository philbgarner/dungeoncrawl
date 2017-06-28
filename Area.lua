--[[

  Area class
 
]]--

local Area = {}
Area.__index = Area

function Area:blankmap(w, h)

  local map = { }
  package.loaded["dungeon"] = nil
  map = require 'dungeon'
  map.layers[1].data = {}
  map.layers[2].data = {}
  
  for i=1, w * h do
    table.insert(map.layers[1].data, 1)
  end
  for i=1, w * h do
    table.insert(map.layers[2].data, 0)
  end
  
  return map

end

function Area:new(w, h, name, seed)
  
  if not seed then seed = os.time() end
  if not name then name = "" end
  local itm = {
      
      props = {
          name = name
          ,width = w
          ,height = h
          ,terrain = "grassland"
          ,seed = seed
          ,exits = {
              east = nil
              ,south = nil
              ,west = nil
              ,north = nil
            }
          ,mapdata = { }
        }
    
    }
  setmetatable(itm, Area)
  itm.props.mapdata = itm:blankmap(w, h)
  return itm
  
end

function Area:load(filename)
  package.loaded[filename] = nil
  local md = require(filename)
  self:set("mapdata", md)
end

function Area:generate()
  print("generate")
  local base_candidates = {
        
    }
    
  self.props.mapdata.properties.generated = true
    
  if self:get("terrain") == "grassland" then
    base_candidates = {
        {id = 1, name = "grass", chance = 0.9 }
        ,{id = 2, name = "tree_evergreen" }
      }
  end
  
  for i=1, self.props.width * self.props.height do
    if math.random() < base_candidates[1].chance then
      table.insert(self.props.mapdata.layers[1].data, 1)
    else
      table.insert(self.props.mapdata.layers[1].data, 2)
    end
  end
  
end

function Area:set(prop, val)

  self.props[prop] = val
  
  return true
  
end

function Area:get(prop)
    
  if self.props[prop] == nil then
    return false
  end
  
  return self.props[prop]
  
end

return Area