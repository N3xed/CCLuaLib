VERSION = 0.1

EventManager = {eventHandlers = {}, running = false}
function EventManager:run()
  while self.running do
    local event, arg1, arg2, arg3 = os.pullEvent()
    if self.eventHandlers[event] then
      for i=1, #self.eventHandlers[event] do
        local e = self.eventHandlers[event][i]
        if e.context then
          e.handler(e.context, arg1, arg2, arg3)
        else
          e.handler(arg1, arg2, arg3)
        end
      end
    end
  end
end
function EventManager:isPresent()
  return self.running
end
function EventManager:start()
  self.running = true
  self:run()
end
function EventManager:startAsCoroutine()
  self._c = coroutine.create(self.run)
  self.running = true
  coroutine.resume(self._c,self)
end
function EventManager:stop()
  self.running = false
  os.queueEvent("eventListenerStop")
end
function EventManager:addEventListener(event, func, context)
  if not self.eventHandlers[event] then
    self.eventHandlers[event] = {}
  end
  table.insert(self.eventHandlers[event], {handler = func, context = context})
end
function EventManager:removeEventHandler(event, handler)
  for i=1,#self.eventHandlers[event] do
    if self.eventHandlers[event][i].handler == handler then
      table.remove(self.eventHandlers[event], i)
      return true
    end
  end
  return false
end
function EventManager:fireEvent(name, ...)
  os.queueEvent(name, ...)
end
function EventManager:fireEventSync(name, ...)
  if self.eventHandlers[name] then
    for i=1, #self.eventHandlers[name] do
      local e = self.eventHandlers[name][i]
      if e.context then
        e.handler(e.context, ...)
      else
        e.handler(...)
      end
    end
  end
end

function string.split(s, splitter)
  result = {}
  for i in string.gmatch(s, "%S+") do
    table.insert(result,i)
  end
  
  return result
end

ConsoleManager = {stringBuffer = ""}
function ConsoleManager:charHandler(char)
  self.stringBuffer = self.stringBuffer .. char
end
function ConsoleManager:enterHandler(key, isHeld)
  if key == 28 then
    EventManager:fireEvent("console_cmd", self.stringBuffer)
    self.stringBuffer = ""
  end
end
function ConsoleManager:start()
  EventManager:addEventListener("char", ConsoleManager.charHandler, self)
  EventManager:addEventListener("key", ConsoleManager.enterHandler, self)
end
function ConsoleManager:stop()
  EventManager:removeEventHandler("char",self.charHandler)
  EventManager:removeEventHandler("key",self.enterHandler)
end
function ConsoleManager:log(message)
  EventManager:fireEvent("console_log", message)
end

CommandManager = {commandHandlers = {}}
function CommandManager:handler(cmd)
  cmds = string.split(cmd, " ")
  for i=1, #self.commandHandlers do
    if self.commandHandlers[i].name == cmds[1] then
      self.commandHandlers[i].handler(cmds)
    end
  end
end
function CommandManager:start()
  EventManager:addEventListener("console_cmd", self.handler, self)
end
function CommandManager:stop()
  EventManager:removeEventHandler("console_cmd", self.handler)
end
function CommandManager:addCommandHandler(name, func)
  table.insert(self.commandHandlers, {name = name, handler = func})
end
function CommandManager:removeCommandHandler(name)
  for i=1, #self.commandHandlers do
    if self.commandHandlers[i].name == name then
      table.remove(self.commandHandlers,i)
      return true
    end
  end
  return false
end

RednetManager = {isOpen = false, side = "", handlers = {}}
function RednetManager:listener(sender, message, protocol)
  if self.handlers[protocol] then
    ConsoleManager:log("Handling 'rednet_event' with protocol: '"..protocol.."'")
    for i=1, #self.handlers[protocol] do
      local e = self.handlers[protocol][i]
      if e.context then
        e.handler(e.context, sender, message)
      else
        e.handler(sender, message)
      end
    end
  end
end
function RednetManager:init(side)
  if not self.isOpen then
    EventManager:addEventListener("rednet_message", self.listener, self)
    rednet.open(side)
    self.isOpen = true
    self.side = side
  end
end
function RednetManager:addRednetListener(protocol, func, context)
  if not self.handlers[protocol] then
    self.handlers[protocol] = {}
  end
  table.insert(self.handlers[protocol], {handler = func, context = context})
end
function RednetManager:removeRednetListener(protocol, func)
  for i=1, #self.handlers[protocol] do
    if self.handlers[protocol][i].handler == func then
      table.remove(self.handlers[protocol],i)
      return true
    end
  end
  return false
end
function RednetManager:close()
  if self.isOpen then
    rednet.close(self.side)
  end
end

Config = {data = {}}
function Config:get(key)
  return self.data[key]
end
function Config:set(key, data)
  self.data[key] = data
end
function Config:unset(key)
  self[key] = nil
end
function Config:exists(key)
  for k,v in pairs(self.data) do
    if k == key then
      return true
    end
  end
  return false
end
function Config:load(file)
  self._filePath = file
  if not fs.exists(file) then
    local h = fs.open(file, "w")
    h.close()
  else
    local h = fs.open(file, "r")
    self.data = textutils.unserialize(h.readAll())
    h.close()
  end
  EventManager:fireEvent("config_load", "Config")
end
function Config:save()
  local h = fs.open(self._filePath, "w")
  h.write(textutils.serialize(self.data))
  h.flush()
  h.close()
  EventManager:fireEvent("config_save", "Config")
end


















