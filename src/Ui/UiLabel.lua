UiLabel = extend(UiObject, {text = "", theme = nil,listenerCollection = nil})
function UiLabel:init(x, y, text)
  self.x = x
  self.y = y
  self.width = string.len(text)
  self.height = 1
  self.text = text
  self.theme = ThemeManager:getTheme("label")
  self.listenerCollection = new(EventListenerCollection)
end
function UiLabel:onEvent(name, ev)
  self.listenerCollection:fireEvent(name, ev)
end
function UiLabel:draw()
  Graphics:setBackgroundColor(self.theme.background)
  Graphics:writeString(self.x,self.y,self.text,self.theme.font_color)
end
function UiLabel:setText(text)
  self.text = text
  self.width = string.len(text)
end
function UiLabel:setTheme(theme)
  self.theme = theme
end
function UiLabel:listeners()
  return self.listenerCollection
end