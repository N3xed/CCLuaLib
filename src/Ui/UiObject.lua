UiObject = extend(table,{focused = false, visible = true, x = 0, y = 0, width = 0, height = 0, parent = nil})
function UiObject:init(x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
end
--
--  Available events:
--  positionChange, sizeChange, visibleChange,focusChange, resized, keyDown, keyUp, mouseDown, mouseUp, mouseScroll, mouseDrag, charReceive
--
function UiObject:onEvent(name, ev)
end

function UiObject:setPosition(x, y)
  local dx = x - self.x
  local dy = y - self.y
  self.x = x
  self.y = y
  self:onEvent("positionChange", {x = x, y = y, deltax = dx, deltay = dy})
end
function UiObject:setSize(width, height)
  self.width = width
  self.height = height
  self:onEvent("sizeChange", {width = width, height = height})
end
function UiObject:setVisible(value)
  self.visible = value
  self:onEvent("visibleChange", {visible = value})
end
function UiObject:draw()
end