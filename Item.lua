--[[

  Item class
 
]]--

local Item = {}
Item.__index = Item

function Item:new(image, name)
  local itm = {
      name = name
      ,props = {

        }
    
    }
  setmetatable(itm, Item)
  
  if type(image) == "string" then
    itm.props.imageFile = image
    itm.props.image = love.graphics.newImage(image)
  else
    itm.props.image = image
    itm.props.imagefile = false
  end
  
  return itm
  
end


function Item:get(prop)
    
  if self.props[prop] == nil then
    return false
  end
  
  return self.props[prop]
  
end


return Item