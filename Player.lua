--[[

  Player class
 
]]--

local Inventory = require "Inventory"

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
          ,weapon = nil
          ,shield = nil
          ,helm = nil
          ,torso = nil
        }
    
    }
  setmetatable(itm, Player)
  itm.props.inventory = Inventory:new(24)

  return itm
  
end

function Player:set(prop, val)

  self.props[prop] = val
  
  return true
  
end

function Player:equip(item)
  
  if item:get("itemtype") == "weapon" then
    player:set("weapon", item)
  elseif item:get("itemtype") == "shield" then
    player:set("shield", item)
  elseif item:get("itemtype") == "helmet" then
    player:set("helmet", item)
  elseif item:get("itemtype") == "armor" then
    player:set("torso", item)
  elseif item:get("itemtype") == "legs" then
    player:set("legs", item)
  end
  
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