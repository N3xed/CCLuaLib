UiWindow = extend(UiObject,{elementCollection = nil, title = "", theme = nil, dragging = false})
function UiWindow:init(x, y, width, height)
  self.super.init(self, x, y, width, height)
  self.theme = ThemeManager:getTheme("window")
  self.elementCollection = new(UiContainer,x, y + self.theme.border_width, self.width, self.height - self.theme.border_width)
end
function UiWindow:draw()
  Graphics:fillRect(self.x,self.y,self.width,self.theme.border_width,self.theme.border)
  Graphics:writeString(self.x + 2, self.y + (self.theme.border_width / 2),self.title,self.theme.font_color)
  -- Button
  Graphics:fillRect(self.x,self.y + self.theme.border_width, self.width,self.height - self.theme.border_width,self.theme.background)
  self.elementCollection:draw()
end
function UiWindow:onEvent(name, ev)
  if name == "mouseDown" then
    self:mouseDown(ev)
  elseif name == "mouseUp" then
    self:mouseUp(ev)
  elseif name == "mouseDrag" then
    self:mouseDrag(ev)
  elseif name == "focusChange" then
    if not ev.focused then
      self.dragging = false
    end
    self.elementCollection:onEvent(name, ev)
  else
    self.elementCollection:onEvent(name, ev)
  end
  ev.handled = true
end
function UiWindow:mouseDown(ev)
  if Rect.containsPoint(self.x,self.y,self.width,self.theme.border_width,ev.x,ev.y) then
    self.dragging = true
  else
    self.elementCollection:onEvent("mouseDown", ev)
  end
end
function UiWindow:mouseUp(ev)
  self.dragging = false
  if not Rect.containsPoint(self.x,self.y,self.width,self.theme.border_width,ev.x,ev.y) then
    self.elementCollection:onEvent("mouseUp", ev)
  end
end
function UiWindow:mouseDrag(ev)
  if self.dragging then
    self:setPosition(ev.x, ev.y)
  end
  if not Rect.containsPoint(self.x,self.y,self.width,self.theme.border_width,ev.x,ev.y) then
    self.elementCollection:onEvent("mouseUp", ev)
  end
end
function UiWindow:setPosition(x, y)
  local dx = x - self.x
  local dy = y - self.y
  self.elementCollection.x = self.elementCollection.x + dx
  self.elementCollection.y = self.elementCollection.y + dy
  self.x = x
  self.y = y
  self:onEvent("positionChange", {x = x, y = y, deltax = dx, deltay = dy})
  if self.visible then
    UiManager:draw()
  end
end
function UiWindow:setTitle(text)
  self.title = text
  if self.visible then
    UiManager:draw()
  end
end
function UiWindow:setTheme(theme)
  self.theme = theme
  if self.visible then
    UiManager:draw()
  end
end
function UiWindow:container()
  return self.elementCollection
end