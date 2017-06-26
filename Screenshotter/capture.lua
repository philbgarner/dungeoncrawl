--[[
The MIT License (MIT)

Copyright (c) 2013 Jonathon Walsh

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]

--folder under the saved data directory to store screen shots
SCREENSHOTTER_FOLDER_NAME = SCREENSHOTTER_FOLDER_NAME or "Screenshots"

--image formate to use
SCREENSHOTTER_IMAGE_FORMAT = SCREENSHOTTER_IMAGE_FORMAT or "png"

--rate of recording. This is the # of FPS the resulting images will be of
SCREENSHOTTER_RECORD_RATE = SCREENSHOTTER_RECORD_RATE or 1/15

--rate of writing to files. The slower this is the less of an impact recording will have on the
--frame rate, but the longer the game needs to write out the image files
SCREENSHOTTER_WRITE_RATE = SCREENSHOTTER_WRITE_RATE or 1/5 

local shotterFolder = SCREENSHOTTER_FOLDER_NAME .. "/" --Helper folder name that includes trailing slash

--Image recording variables
local isRecording = false
local recordName = nil
local recordIndex = 1

--Image recording throttling variables
local writeFrameTime = SCREENSHOTTER_WRITE_RATE
local recordFrameTime = 0
local capturedFrames = {}

--Image cropping variables
local useBounds = false
local bounds = {x = -1,  y = -1, width = 0, height = 0}

--Generates a cropped image data object to be written to a file
local function getCroppedData()
  local cropped = love.image.newImageData(bounds.width, bounds.height)
  local raw = love.graphics.newScreenshot( )
  
  --Pixel color values
  local r
  local g
  local b
  local a
  
  --Copy pixel values from the screenshot to the cropped image
  for x = 0, bounds.width - 1, 1 do
    for y = 0, bounds.height - 1, 1 do
      r, g, b, a = raw:getPixel(x + bounds.x, y + bounds.y)
      cropped:setPixel(x, y, r, g, b, a)
    end
  end
  
  return cropped
end

--Gets all the necessary data for a screen shot to be written later
local function getShotData()
  local frameName
  local data
  
  if isRecording == true then
    love.filesystem.createDirectory(shotterFolder .. recordName)
    frameName = shotterFolder .. recordName .. "/" .. os.time() .. "_" .. recordIndex .. "." .. SCREENSHOTTER_IMAGE_FORMAT
  else
    love.filesystem.createDirectory(SCREENSHOTTER_FOLDER_NAME)
    frameName = shotterFolder .. os.time() .. "_" .. recordIndex .. "." .. SCREENSHOTTER_IMAGE_FORMAT
  end
  print("frameName", frameName)
  --Index ensures uniqueness of screenshots taken
  recordIndex = recordIndex + 1
  
  if useBounds then
    data = getCroppedData()
  else
    data = love.graphics.newScreenshot( )
  end
  
  return {
    name = frameName,
    data = data
  }
end

--Captures the current frame in the queue to be drawn
local function captureFrame()
  table.insert(capturedFrames, #capturedFrames + 1, getShotData())
end

--Write the frame to the next file
local function writeFrame()
  if #capturedFrames == 0 then
    return
  end
  
  local shotData = table.remove(capturedFrames, 1)
  local file = love.filesystem.newFile(shotData.name)
  if file:open("w") == true then
    shotData.data:encode(SCREENSHOTTER_IMAGE_FORMAT, shotData.name)
  end
  file:close()
end

--Capture API table
local Capture = {}

--[[
  Takes a single shot of the screen as seen last frame. Maybe a cropped shot
  ]]
function Capture.takeShot()
  captureFrame()
end

--[[
  Returns true if the system is cropping screenshots
  ]]
function Capture.isCropping()
  return useBounds
end

--[[
  Provides access to the bounds of the current cropping rectangle
  returns x, y, width, height
  ]]
function Capture.getCrop()
  return bounds.x, bounds.y, bounds.width, bounds.height
end

--[[
  Clears the cropping boundary being used
  ]]
function Capture.clearBounds()
  useBounds = false
end

--[[
  Sets a cropping boundary for the screen shotter
  if set the resulting screenshots will be cropped
  to the indicated bounds
  x: left coordinate of the cropping rectangle
  y: bottom coordinate of the cropping rectangle
  w: width of the cropping rectangle
  h: height of the cropping rectangle
  ]]
function Capture.setBounds(x, y, w, h)
  --Enforce valid boundaries
  if x < 0 or x > love.window.getWidth() or
     y < 0 or y > love.window.getHeight() or
     w < 0 or h < 0 or 
     x + w > love.window.getWidth() or 
     y + h > love.window.getWidth() then
    return
  end
  
  bounds.x = x
  bounds.y = y
  bounds.width = w
  bounds.height = h
  useBounds = true
end

--[[
  Start recording the screen
  name (optional): the sub-folder name to store the recording otherwise
   current time is used
  ]]
function Capture.startRecording(name)
  if isRecording == true then
    return
  end
  recordName = name or os.time() 
  recordIndex = 1
  isRecording = true
  recordFrameTime = 0
end

--[[
  Stop recording the screen
  ]]
function Capture.stopRecording()
  if isRecording == false then
    return
  end
  recordName = nil
  recordIndex = 1
  isRecording = false
  recordFrameTime = 0
end

--[[
  Whether or not the screen shooter is recording. True if a record is in progress
  ]]
function Capture.isRecording()
  return isRecording
end

--[[
  Update call for the screen shooter. Must be called to enable recording,
  otherwise it's not necessary.
  ]]
function Capture.update(dt)
  --Image capturing throttler
  if isRecording == true then
    recordFrameTime =  recordFrameTime - (dt or love.timer.getDelta( ))
    if recordFrameTime <= 0 then
      recordFrameTime = SCREENSHOTTER_RECORD_RATE
      captureFrame()
    end
  end
  
  --Image writing throttler
  if #capturedFrames > 0 then
    writeFrameTime =  writeFrameTime - (dt or love.timer.getDelta( ))
    if writeFrameTime <= 0 then
      writeFrameTime = SCREENSHOTTER_WRITE_RATE
      writeFrame()
    end
  end
end

return Capture