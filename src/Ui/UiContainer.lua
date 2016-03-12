UiContainer = extend(UiObject, {elements = {}, lastFocusObject = nil, dispatcher = nil, x = 0, y = 0, width = 0, height = 0, lastFocusObject = nil})
function UiContainer:init(x, y, width, height)
  self.dispatcher = EventDispatcher:new()
  self.x = x
  self.y = y
  self.width = width
  self.height = height
end
function UiContainer:addUiObject(obj)
  obj.parent = self
  table.insert(self.elements, obj)
end
function UiContainer:removeUiObject(obj)
  for i,e in ipairs(self.elements) do
    if e == obj then
      obj.parent = nil
      table.remove(self.elements,i)
      return true
    end
  end
  return false
end
function UiContainer:draw()
  for i,e in ipairs(self.elements) do
    if e.visible then
      e:draw()
    end
  end
end
s = "positionChange, sizeChange, visibleChange, focusChange, resized, keyDown, keyUp, mouseDown, mouseUp, mouseScroll, mouseDrag, charReceive"
function UiContainer:onEvent(name, ev)
  self.dispatcher:set(name, ev)
  self.dispatcher:dispatch("mouseDown", self.mouseDown, self)
  self.dispatcher:dispatch("mouseUp", nil, self)
  self.dispatcher:dispatch("mouseScroll", nil, self)
  self.dispatcher:dispatch("mouseDrag", nil, self)
  self.dispatcher:dispatch("keyDown", nil, self)
  self.dispatcher:dispatch("keyUp", nil, self)
  self.dispatcher:dispatch("charReceive", nil, self)
  self.dispatcher:dispatch("resized", nil, self)
  self.dispatcher:dispatch("focusChange", nil, self)
  --self.dispatcher:dispatch("visibleChange", nil, self)
  --self.dispatcher:dispatch("sizeChange", nil, self)
  self.dispatcher:dispatch("positionChange", nil, self)
  self.dispatcher:remove()
end
function UiContainer:resized(ev)
  for i,e in ipairs(self.elements) do
    e:onEvent("resized", ev)
  end
end
function UiContainer:focusChange(ev)
  if (not ev.focused) and self.lastFocusObject then
    self.lastFocusObject.focused = false
    self.lastFocusObject:onEvent("focusChange", ev)
  end
end
function UiContainer:visibleChange(ev)
end
function UiContainer:sizeChange(ev)
end
function UiContainer:positionChange(ev)
  ev.x = ev.x - self.x
  ev.y = ev.y - self.y  
  for i=#self.elements, 1, -1 do
    local e = self.elements[i]
    e:onEvent("positionChange", ev)
  end
  ev.x = ev.x + self.x
  ev.y = ev.y + self.y
end
function UiContainer:keyDown(ev)
  if self.lastFocusObject then
    self.lastFocusObject:onEvent("keyDown", ev)
  end
end
function UiContainer:keyUp(ev)
  if self.lastFocusObject then
    self.lastFocusObject:onEvent("keyUp", ev)
  end
end
function UiContainer:charReceive(ev)
  if self.lastFocusObject then
    self.lastFocusObject:onEvent("charReceive", ev)
  end
end
function UiContainer:mouseUp(ev)
  ev.x = ev.x - self.x
  ev.y = ev.y - self.y  
  self.lastFocusObject:onEvent("mouseUp", ev)
  ev.x = ev.x + self.x
  ev.y = ev.y + self.y
end
function UiContainer:mouseScroll(ev)
  ev.x = ev.x - self.x
  ev.y = ev.y - self.y
    if self.lastFocusObject then
      self.lastFocusObject:onEvent("mouseScroll", ev)
    end
  ev.x = ev.x + self.x
  ev.y = ev.y + self.y
end
function UiContainer:mouseDrag(ev)
  ev.x = ev.x - self.x
  ev.y = ev.y - self.y
  for i=#self.elements, 1, -1 do
    local e = self.elements[i]
    if Rect.containsPoint(self.x,self.y,self.width,self.height,ev.x,ev.y) then
      e:onEvent("mouseDrag", ev)
      if ev.handled then
        break
      end
    end
  end
  ev.x = ev.x + self.x
  ev.y = ev.y + self.y
end
function UiContainer:mouseDown(ev)
  ev.x = ev.x - self.x
  ev.y = ev.y - self.y
  
  local found = false
  for i=#self.elements, 1, -1 do
    local e = self.elements[i]
    if Rect.containsPoint(self.x,self.y,self.width,self.height,ev.x,ev.y) then
      found = true
      if e ~= self.lastFocusObject then
        if self.lastFocusObject then
          self.lastFocusObject.focused = false
          self.lastFocusObject:onEvent("focusChange", {focused = false})
        end
      
        e.focused = true
        e:onEvent("focusChange", {focused = true})
        self.lastFocusObject = e
      end
      
      e:onEvent("mouseDown", ev)
      if ev.handled then
        break
      end
    end
  end
  
  if self.lastFocusObject and (not found) then
    self.lastFocusObject.focused = false
    self.lastFocusObject:onEvent("focusChange", {focused = false})
    self.lastFocusObject = nil
  end
  
  ev.x = ev.x + self.x
  ev.y = ev.y + self.y
end