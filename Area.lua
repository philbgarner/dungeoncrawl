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
          ,terrain = ""
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
  self:set("terrain", md.properties.terrain_type)
end

function Area:generateMobs()
  
  local number = math.random(1, 4)
  for i=1, number do
    local mx = math.random(16, 58)
    local my = math.random(16, 58)
  
    if self:get("terrain") == "forest" then
      newMob(Mobiles:new("Bunny", "bunny.png", mx, my, md))
    elseif self:get("terrain") == "grassland" then
      newMob(Mobiles:new("Bunny", "bunny.png", mx, my, md))
    elseif self:get("terrain") == "desert" then
      newMob(Mobiles:new("Bunny", "bunny.png", mx, my, md))
    end
  end

  
end

function Area:generate(type_from, dir_to)
  print("generate")
  local base_candidates = {
        
    }
  local tileid_map = {
      grass = 1
      ,tree = 6
      ,rocky_grass = 9
      ,grass_flowers = 10
      ,sand = 11
    }
    
  --[[
  
  Terrain Types are influenced by what type of area(s) they are surrounded by
  (if that area has been generated yet).
  
  Type "home" is the start area, the only area not procedurally generated.  In this
  way we can control what kinds of terrain get generated connected to the home area
  (for example: No forest areas allowed adjascent to home area).
  
  If the terrain type has a probability mapped for the position of the area
  being generated relative to the area the player is coming from, then the generator
  will use that value.  If the value is nil for that key in the table the 
  generator will essentially roll a die and pick at random, however only if the probabilities
  in the potential terraint_types list for the area the player came from do not add up to 100% (1.0).
  If the predefined candidates do add up to that amount, the generator will not consider any other types
  for selection.
  
  ]]--
  local terrain_types = {
      home = {
        forest = {
          north = 0.2
          ,south = 0.2
          ,east = 0.2
          ,west =  0.2
        }
        ,grassland = {
          north = 0.7
          ,south = 0.7
          ,east = 0.7
          ,west =  0.7
        }
        ,desert = {
          north = 0.1
          ,south = 0.1
          ,east = 0.1
          ,west =  0.1
        }
      }
      ,grassland = {
        forest = {
          north = 0.4
          ,south = 0.4
          ,east = 0.4
          ,west =  0.4
        }
        ,grassland = {
          north = 0.5
          ,south = 0.5
          ,east = 0.5
          ,west =  0.5
        }
        ,desert = {
          north = 0.1
          ,south = 0.1
          ,east = 0.1
          ,west =  0.1
        }
      }
      ,forest = {
        forest = {
          north = 0.8
          ,south = 0.8
          ,east = 0.8
          ,west =  0.8
        }
        ,grassland = {
          north = 0.2
          ,south = 0.2
          ,east = 0.2
          ,west =  0.2
        }
      }
      ,desert = {
        desert = {
          north = 0.7
          ,south = 0.7
          ,east = 0.7
          ,west =  0.7
        }
        ,grassland = {
          north = 0.3
          ,south = 0.3
          ,east = 0.3
          ,west =  0.3
        }
      }
    }
    
  local md = self:get("mapdata")
    
  self.props.mapdata.properties.generated = true

  local name = ""
  local prob = 0
  
  for key, values in pairs(terrain_types[type_from]) do
    name = key
    prob = prob + values[dir_to]
    
    if math.random() <= prob then
      break
    end
    
    if prob >= 1 then break end
  end
  
  self:set("terrain", name)
  if name == "grassland" then
    table.insert(base_candidates, {id = tileid_map["grass"], name = name})
    table.insert(base_candidates, {id = tileid_map["grass"], name = name})
    table.insert(base_candidates, {id = tileid_map["grass"], name = name})
    table.insert(base_candidates, {id = tileid_map["grass"], name = name})
    table.insert(base_candidates, {id = tileid_map["grass_flowers"], name = name})
    table.insert(base_candidates, {id = tileid_map["rocky_grass"], name = name})
  elseif name == "forest" then
    table.insert(base_candidates, {id = tileid_map["grass"], name = name})
    table.insert(base_candidates, {id = tileid_map["grass"], name = name})
    table.insert(base_candidates, {id = tileid_map["grass"], name = name})
    table.insert(base_candidates, {id = tileid_map["grass"], name = name})
    table.insert(base_candidates, {id = tileid_map["grass_flowers"], name = name})
    table.insert(base_candidates, {id = tileid_map["rocky_grass"], name = name})
    table.insert(base_candidates, {id = tileid_map["tree"], name = name})
    table.insert(base_candidates, {id = tileid_map["tree"], name = name})
  elseif name == "desert" then
    table.insert(base_candidates, {id = tileid_map["sand"], name = name})
  end

  self.props.mapdata.layers[1].data = { }
  for i=1, self.props.width * self.props.height do
    local cid = math.random(1, #base_candidates)
    table.insert(self.props.mapdata.layers[1].data, base_candidates[cid].id)
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