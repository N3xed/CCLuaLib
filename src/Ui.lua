Theme = table:new{
  background = 0,
  background_hover = 0,
  background_active = 0,
  border = 0,
  border_hover = 0,
  border_active = 0,
  border_width = 1,
  font_color = 0xaaaaaa,
  font_size = 12
}

ThemeManager = {themes = {}, default = Theme}
function ThemeManager:init()
  if not Config:exists("theme") then
    Config:set("theme",self.themes)
  else
    self.themes = Config:get("theme")
  end
end
function ThemeManager:getTheme(name)
  if self.themes[name] then
    return self.themes[name]
  else
    return self.default
  end
end
function ThemeManager:setTheme(name, theme)
  self.themes[name] = theme
end

Graphics = {height = 0, width = 0, _monitor = false, scale = 1, xOffset = 0, yOffset = 0}
function Graphics:clear()
  term.clear()
end
function Graphics:setBackgroundColor(color)
  term.setBackgroundColor(color)
end
function Graphics:getBackgroundColor()
  return term.getBackgroundColor()
end
function Graphics:isColor()
  return term.isColor()
end
function Graphics:isMonitor()
  return self._monitor
end
function Graphics:setMonitor(value)
  self._monitor = value
end
function Graphics:setTextColor(value)
  term.setTextColor(value)
end
function Graphics:getTextColor()
  return term.getTextColor()
end
function Graphics:setScale(value)
  if not self._monitor then
    error("Cannot set scale on non monitor.",1)
  end
  self.scale = value
end
function Graphics:writeString(x, y, text)
  term.setCursorPos(x + self.xOffset, y + self.yOffset)
  term.write(text)
end
function Graphics:setOutput(target)
  term.redirect(target)
end
function Graphics:getOutput()
  return term.current()
end
function Graphics:drawPixel(x, y, color)
  paintutils.drawPixel(x + self.xOffset, y + self.yOffset, color)
end
function Graphics:drawRect(x1, y1, x2, y2, color)
  paintutils.drawBox(x1 + self.xOffset, y1 + self.yOffset, x2 + self.xOffset, y2 + self.yOffset, color)
end
function Graphics:fillRect(x1, y1, x2, y2, color)
  paintutils.drawFilledBox(x1 + self.xOffset, y1 + self.yOffset, x2 + self.xOffset, y2 + self.yOffset, color)
end
function Graphics:drawLine(x1, y1, x2, y2, color)
  paintutils.drawLine(x1 + self.xOffset, y1 + self.yOffset, x2 + self.xOffset, y2 + self.yOffset, color)
end
function Graphics:translate(xo, yo)
  self.xOffset = self.xOffset + xo
  self.yOffset = self.yOffset + yo
end

UiManager = {tickListeners = {}, running = false, initialized = false}
function UiManager:init()
  if not self.initialized then
    self.initialized = true
    EventManager:addEventListener("timer", self.tick_listener,self)
    EventManager:addEventListener("key", self.key_listener, self)
    EventManager:addEventListener("key_up", self.keyUp_listener, self)
    EventManager:addEventListener("char", self.char_listener, self)
    EventManager:addEventListener("mouse_click", self.mouseClick_listener, self)
    EventManager:addEventListener("mouse_drag", self.mouseDrag_listener, self)
    EventManager:addEventListener("mouse_scroll", self.mouseScroll_listener, self)
    EventManager:addEventListener("mouse_up", self.mouseUp_listener, self)
    EventManager:addEventListener("term_resize", self.resize_listener, self)
    
    
    
    self.collection = UiObjectCollection:new(nil, 0, 0, Graphics.width, Graphics.height, self)
  end
end
function UiManager:startTick()
  self.running = true
  self._timer = os.startTimer(1)
end
function UiManager:stopTick()
  self.running = false
  os.cancelTimer(self._timer)
end
function UiManager:tick_listener(timerId)
  if self._timer ~= timerId then
    return
  end
  for i,e in ipairs(self.tickListeners) do
    if e.context then
      e.listener(e.context)
    else
      e.listener()
    end
  end
  if self.running then
    self._timer = os.startTimer(1)
  end
end
function UiManager:key_listener(key, isHeld)
  self.collection:fireEvent("keyPressed", key, isHeld)
  self.collection:keyPressed(key, isHeld)
  self:draw()
end
function UiManager:keyUp_listener(key)
  self.collection:fireEvent("keyUp", key)
  self.collection:keyUp(key)
  self:draw()
end
function UiManager:char_listener(char)
  self.collection:fireEvent("charReceived", char)
  self.collection:charReceived(char)
  self:draw()
end
function UiManager:mouseClick_listener(button, x, y)
  self.collection:fireEvent("mouseClicked", button, x, y)
  self.collection:mouseClicked(button, x, y)
  self:draw()
end
function UiManager:mouseDrag_listener(button, x, y)
  self.collection:fireEvent("mouseDragged", button, x, y)
  self.collection:mouseDragged(button, x, y)
  self:draw()
end
function UiManager:mouseScroll_listener(direction, x, y)
  self.collection:fireEvent("mouseScrolled", direction, x, y)
  self.collection:mouseScrolled(direction, x, y)
  self:draw()
end
function UiManager:mouseUp_listener(button, x, y)
  self.collection:fireEvent("mouseUp", button, x, y)
  self.collection:mouseUp(button, x, y)
  self:draw()
end
function UiManager:resize_listener()
  local w,h = term.getSize()
  
  Graphics:setSize(w,h)
  self.collection:fireEvent("resized", w, h)
  self.collection:resized(w, h)
  self:draw()
end
function UiManager:addTickListener(func, context)
  table.insert(self.tickListeners,{listener = func, context = context})
end
function UiManager:removeTickListener(func)
  for i,e in ipairs(self.tickListeners) do
    if e.listener == func then
      table.remove(self.tickListeners,i)
      return true
    end
  end
  return false
end
function UiManager:fireEvent(name, ...)
  self.collection:fireEvent(name, ...)
end
function UiManager:draw()
  Graphics:clear()
  self.collection:draw()
  self.collection:fireEvent("draw")
end
function UiManager:addUiObject(obj)
  self.collection:addUiObject(obj)
end
function UiManager:removeUiObject(obj)
  self.collection:removeUiObject(obj)
end
function UiManager:addEventListener(name, func, context)
  self.collection:addEventListener(name, func, context)
end
function UiManager:removeEventListener(name, func)
  self.collection:removeEventListener(name, func)
end

Rect = {}
function Rect.containsPoint(xRect, yRect, width, height, x, y)
  return (x >= xRect) and (x <= (xRect + width)) and (y >= yRect) and (y <= (yRect + height))
end

UiObject = table:new{listeners = {}, focused = false, visible = true, x = 0, y = 0, width = 0, height = 0, parent = nil}
function UiObject:init(x, y, width, height, parent)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.parent = parent
end
function UiObject:addEventListener(name, func, context)
  if not self.listeners[name] then
    self.listeners[name] = {}
  end
  table.insert(self.listeners[name], {listener = func, context = context})
end
function UiObject:removeEventListener(name, func)
  for i,e in ipairs(self.listeners[name]) do
    if e.listener == func then
      table.remove(self.listeners[name], i)
      return true
    end
  end
  return false
end
function UiObject:fireEvent(name, ...)
  if self.listeners[name] then
    for i,e in ipairs(self.listeners[name]) do
      if e.context then
        e.listener(e.context, ...)
      else
        e.listener(...)
      end
    end
  end
end
function UiObject:setPosition(x, y)
  self.x = x
  self.y = y
  if self.visible then
    UiManager:draw()
  end
end
function UiObject:setSize(width, height)
  self.width = width
  self.height = height
  if self.visible then
    UiManager:draw()
  end
end
function UiObject:setVisible(value)
  self.visible = value
  self:fireEvent("visibleChanged", value)
  self:visibleChanged(value)
  UiManager:draw()
end
function UiObject:draw()
end
function UiObject:focusChanged(focused)
end
function UiObject:visibleChanged(visible)
end
function UiObject:keyPressed(key, isHeld)
end
function UiObject:keyUp(key)
end
function UiObject:charReceived(char)
end
function UiObject:mouseClicked(button, x, y)
end
function UiObject:mouseDragged(button, x, y)
end
function UiObject:mouseScrolled(direction, x, y)
end
function UiObject:mouseUp(button, x, y)
end
function UiObject:resized(screenWidth, screenHeight)
end

UiObjectCollection = UiObject:new{elements = {}, lastFocusObject = nil}
function UiObjectCollection:addUiObject(obj)
  table.insert(self.elements, 1, obj)
end
function UiObjectCollection:removeUiObject(obj)
  for i,e in ipairs(self.elements) do
    if e == obj then
      table.remove(self.elements,i)
      return true
    end
  end
  return false
end
function UiObjectCollection:focusChanged(focused)
  if not focused then
    if self.lastFocusObject then
      self.lastFocusObject.focused = false
      self.lastFocusObject:fireEvent("focusChanged", false)
      self.lastFocusObject:focusChanged(false)
      self.lastFocusObject = nil
    end
  end
end
function UiObjectCollection:visibleChanged(visible)
end
function UiObjectCollection:keyPressed(key, isHeld)
  self.lastFocusObject:fireEvent("keyPressed", key, isHeld)
  self.lastFocusObject:keyPressed(key, isHeld)
end
function UiObjectCollection:keyUp(key)
  self.lastFocusObject:fireEvent("keyUp", key)
  self.lastFocusObject:keyUp(key)
end
function UiObjectCollection:charReceived(char)
  self.lastFocusObject:fireEvent("charReceived", char)
  self.lastFocusObject:charReceived(char)
end
function UiObjectCollection:mouseClicked(button, x, y)
  local found = false
  local xp = x - self.width
  local yp = y - self.height
  for i,e in ipairs(self.elements) do
    if Rect.containsPoint(self.x,self.y,self.width,self.height,x,y) then
      found = true
      if self.lastFocusObject and (self.lastFocusObject ~= e) then
        self.lastFocusObject.focused = false
        self.lastFocusObject:fireEvent("focusChanged", false)
        self.lastFocusObject:focusChanged(false)
        self.lastFocusObject = nil
      end
      if not e.focused then
        e.focused = false
        e:fireEvent("focusChanged", false)
        e:focusChanged(false)
        self.lastFocusObject = e
      end
      e:fireEvent("mouseClicked", button, xp, yp)
      if e:mouseClicked(button, xp, yp) then
        return
      end
    end
  end
  
  if (not found) and self.lastFocusObject then
    self.lastFocusObject.focused = false
    self.lastFocusObject:fireEvent("focusChanged", false)
    self.lastFocusObject:focusChanged(false)
    self.lastFocusObject = nil
  end
end
function UiObjectCollection:mouseDragged(button, x, y)
  local xp = x - self.width
  local yp = y - self.height
  
  for i,e in ipairs(self.elements) do
    if Rect.containsPoint(self.x,self.y,self.width,self.height,x,y) then
      e:fireEvent("mouseDragged", button, xp, yp)
      if e:mouseDragged(button, xp, yp) then
        return
      end
    end
  end
end
function UiObjectCollection:mouseScrolled(direction, x, y)
  self:fireEvent("mouseScrolled", direction, x, y)
end
function UiObjectCollection:mouseUp(button, x, y)
  self:fireEvent("mouseUp", button, x, y)
end
function UiObjectCollection:draw()
  Graphics:translate(self.x,self.y)
  for i,e in ipairs(self.elements) do
    if e.visible then
      e:draw()
      e:fireEvent("draw")
    end
  end
  Graphics:translate(-self.x,-self.y)
end
function UiObjectCollection:resized(screenWidth, screenHeight)
  for i,e in ipairs(self.elements) do
    e:fireEvent("resized", screenWidth, screenHeight)
    e:resized(screenWidth, screenHeight)
  end
end


