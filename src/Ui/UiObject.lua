UiObject = extend(table,{focused = false, visible = true, x = 0, y = 0, width = 0, height = 0, parent = nil, enabled = true})
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
function UiObject:setEnabled(value)
  self.enabled = value
end
function UiObject:setPosition(x, y)
  local dx = x - self.x
  local dy = y - self.y
  self.x = x
  self.y = y
  self:onEvent("positionChange", {deltax = dx, deltay = dy})
end
function UiObject:move(xo, yo)
  self.x = self.x + xo
  self.y = self.y + yo
  self:onEvent("positionChange", {deltax = xo, deltay = yo})
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