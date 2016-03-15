UiButton = extend(UiObject, {text = "", theme = nil, listenerCollection = nil, active = false})
function UiButton:init(x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.theme = ThemeManager:getTheme("button")
  self.listenerCollection = new(EventListenerCollection)
end
function UiButton:draw()
  if self.active and self.enabled then
    Graphics:fillRect(self.x,self.y,self.width,self.height,self.theme.background_active)
    Graphics:setBackgroundColor(self.theme.background_active)
  else
    Graphics:fillRect(self.x, self.y, self.width, self.height, self.theme.background)
    Graphics:setBackgroundColor(self.theme.background)
  end
  Graphics:writeStringCentered(self.x,self.y,self.width,self.height,self.text,self.theme.font_color)
end
function UiButton:onEvent(name, ev)
  if name == "mouseDown" then
    self.active = true
  elseif name == "mouseUp" then
    self.active = false
  end
  if self.enabled then
    self.listenerCollection:fireEvent(name, ev)
  end
end
function UiButton:setText(text)
  self.text = text
end
function UiButton:setTheme(theme)
  self.theme = theme
end
function UiButton:listeners()
  return self.listenerCollection
end