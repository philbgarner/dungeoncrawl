--[[

  Inventory class
 
]]--

local Inventory = {}
Inventory.__index = Inventory

function Inventory:new(max_slots)
  
  local itm = {
      
      props = {
          max_slots = max_slots
          ,items = {}
        }
    
    }
  setmetatable(itm, Inventory)
  return itm
  
end


function Inventory:getProperty(prop)
    
  if self.props[prop] == nil then
    return false
  end
  
  return self.props[prop]
  
end

function Inventory:max_slots()
  return self:getProperty("max_slots")
end

function Inventory:add(item)
  if self:getProperty("max_slots") < #self.props.items + 1 then
    return
  end
  table.insert(self.props.items, item)
end

function Inventory:get(index)
  if self.props.items[index] then return self.props.items[index] end
  return false
end

function Inventory:remove(index)
  if not self.props.items[index] then return false end
  return table.remove(self.props.items, index)
end

function Inventory:find(name)
  for i=1, #self.props.items do
    if name == self.props.items[i].name then
      return self.props.items[i].name
    end
  end
  return false
end

return Inventory