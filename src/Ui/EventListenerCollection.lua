EventListenerCollection = extend(table, {listeners = {}})
function EventListenerCollection:addEventListener(name, func, context)
  if self.listeners[name] then
    self.listeners[name] = {}
  end
  table.insert(self.listeners[name], {listener = func, context = context})
end
function EventListenerCollection:removeEventListener(name, func)
  if not self.listeners[name] then
    return
  end
  for i,e in ipairs(self.listeners[name]) do
    if e.listener == func then
      table.remove(self.listeners[name], i)
    end
  end
end
function EventListenerCollection:fireEvent(name, ...)
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
function EventListenerCollection:fireEventRev(name, ...)
  if not self.listeners[name] then
    return
  end
  for i=#self.listeners[name], 1, -1 do
    local e = self.listeners[name][i]
    if e.context then
      e.listener(e.context, ...)
    else
      e.listener(...)
    end
  end
end