UiManager = {tickListeners = {}, running = false, initialized = false, listeners = {}, width = 0, height = 0}
function UiManager:init()
  if not self.initialized then
    self.initialized = true
    local w,h = term.getSize()
    self.width = w
    self.height = h
    ThemeManager:init()
    EventManager:addEventListener("timer", self.tick_listener,self)
    EventManager:addEventListener("key", self.key_listener, self)
    EventManager:addEventListener("key_up", self.keyUp_listener, self)
    EventManager:addEventListener("char", self.char_listener, self)
    EventManager:addEventListener("mouse_click", self.mouseClick_listener, self)
    EventManager:addEventListener("mouse_drag", self.mouseDrag_listener, self)
    EventManager:addEventListener("mouse_scroll", self.mouseScroll_listener, self)
    EventManager:addEventListener("mouse_up", self.mouseUp_listener, self)
    EventManager:addEventListener("term_resize", self.resize_listener, self)
    
    self.collection = new(UiContainer, 0, 0, self.width, self.height)
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
  local ev = {key = key, isHeld = isHeld, handled = false}
  self.collection:onEvent("keyDown", ev)
  self:fireEvent("keyDown", ev)
  self:draw()
end
function UiManager:keyUp_listener(key)
  local ev = {key = key, handled = false}
  self.collection:onEvent("keyUp", ev)
  self:fireEvent("keyUp", ev)
  self:draw()
end
function UiManager:char_listener(char)
  local ev = {char = char, handled = false}
  self.collection:onEvent("charReceive", ev)
  self:fireEvent("charReceive", ev)
  self:draw()
end
function UiManager:mouseClick_listener(button, x, y)
  local ev = {button = button, x = x, y = y, handled = false}
  self.collection:onEvent("mouseDown", ev)
  self:fireEvent("mouseDown", ev)
  self:draw()
end
function UiManager:mouseDrag_listener(button, x, y)
  local ev = {button = button, x = x, y = y, handled = false}
  self.collection:onEvent("mouseDrag", ev)
  self:fireEvent("mouseDrag", ev)
  self:draw()
end
function UiManager:mouseScroll_listener(direction, x, y)
  local ev = {direction = direction, x = x, y = y, handled = false}
  self.collection:onEvent("mouseScroll", ev)
  self:fireEvent("mouseScroll", ev)
  self:draw()
end
function UiManager:mouseUp_listener(button, x, y)
  local ev = {button = button, x = x, y = y, handled = false}
  self.collection:onEvent("mouseUp", ev)
  self:fireEvent("mouseUp", ev)
  self:draw()
end
function UiManager:resize_listener()
  local w,h = term.getSize()
  self.width = w
  self.height = h
  self.collection.width = w
  self.collection.height = h
  local ev = {width = w, height = h, handled = false}
  self.collection:onEvent("resized", ev)
  self:fireEvent("resized", ev)
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
  if not self.listeners[name] then
    return
  end
  for i,e in ipairs(self.listeners[name]) do
    if e.context then
      e.listener(e.context, ...)
    else
      e.listener(...)
    end
  end
end
function UiManager:draw()
  Graphics:clear()
  self.collection:draw()
  self:fireEvent("draw")
end
function UiManager:addUiObject(obj)
  self.collection:addUiObject(obj)
  self:draw()
end
function UiManager:removeUiObject(obj)
  self.collection:removeUiObject(obj)
  self:draw()
end
function UiManager:addEventListener(name, func, context)
  if self.listeners[name] then
    self.listeners[name] = {}
  end
  table.insert(self.listeners[name],{listener = func, context = context})
end
function UiManager:removeEventListener(name, func)
  for i,e in ipairs(self.listeners[name]) do
    if e.listener == func then
      table.remove(self.listeners[name],i)
      return true
    end
  end
  return false
end