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
          ,endurance = 5
          ,endurance_max = 5
          ,endurance_rechargeRate = 0.25
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

function Player:update(dt)
  
  if self:get("endurance") < self:get("endurance_max") then
    self:set("endurance", self:get("endurance") + self:get("endurance_rechargeRate") * dt) 
    if self:get("endurance") > self:get("endurance_max") then
      self:set("endurance", self:get("endurance_max"))
    end
  end
  
end

return Player