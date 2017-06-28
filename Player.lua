--[[

  Player class
 
]]--

local Inventory require "Inventory"

local Player = {}
Player.__index = Player

function Player:new(name)
  
  local itm = {
      
      props = {
          name = name
          ,direction = "up"
        }
    
    }
  setmetatable(itm, Player)
  return itm
  
end

function Player:set(prop, val)

  self.props[prop] = val
  
  return true
  
end

function Player:get(prop)
    
  if self.props[prop] == nil then
    return false
  end
  
  return self.props[prop]
  
end

return Player