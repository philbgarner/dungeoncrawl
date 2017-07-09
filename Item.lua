--[[

  Item class
 
]]--

local Item = {}
Item.__index = Item

function Item:new(image, name)
  
  local itm = {
      
      props = {
          image = image 
          ,props = {
              name = name
            }
        }
    
    }
  setmetatable(itm, Item)
  return itm
  
end


function Item:get(prop)
    
  if self.props[prop] == nil then
    return false
  end
  
  return self.props[prop]
  
end

function Item:get(index)
  if self.props.items[index] then return self.props.items[index] end
  return false
end

return Item