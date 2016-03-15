EventManager = {eventHandlers = {}, running = false}
function EventManager:run()
  while self.running do
    local event, arg1, arg2, arg3 = os.pullEvent()
    if self.eventHandlers[event] then
      for i,e in ipairs(self.eventHandlers[event]) do
        if e.context then
          e.handler(e.context, arg1, arg2, arg3)
        else
          e.handler(e.context, arg1, arg2, arg3)
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

function table:init()
end
function extend(base, o)
  o = o or {}
  setmetatable(o, base)
  base.__index = base
  return o
end
function new(o, ...)
  local result = {}
  setmetatable(result,o)
  o.__index = o
  result:init(...)
  return result
end

function string.split(s, delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( s, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( s, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( s, delimiter, from  )
  end
  table.insert( result, string.sub( s, from  ) )
  return result
end
function string.unwrapOnce(s, opener, closer)
  s = string.gsub(s,opener,"",1)
  return string.sub(s,1, string.len(s) - string.len(closer))
end
function string.toBool(s)
  s = string.gsub(s," ","")
  return s == "true"
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
  EventManager:fireEvent("console_log",message)
end

CommandManager = {commandHandlers = {}}
function CommandManager:handler(cmd)
  local cmds = string.split(cmd, " ")
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
end

StateContext = {}
function StateContext:init(name, sender, handler_name)
  self.name = name
  self.sender = sender
  self.handler_name = handler_name
end
function StateContext:commit(message, percentage)
  StateManager:fire(self.handler_name, {name = self.name, sender = self.sender, message = message, percentage = percentage, finished = false})
end
function StateContext:close(message)
  StateManager:fire(self.handler_name, {name = self.name, sender = self.sender, message = message, percentage = 100, finished = true})
end

StateManager = {handlers = {}}
function StateManager:addHandler(name, func, context)
  if not self.handlers[name] then
    self.handlers[name] = {}
  end

  table.insert(self.handlers[name], {handler = func, context = context})
end
function StateManager:removeHandler(func)
  for i,e in ipairs(self.handlers) do
    if e.handler == func then
      table.remove(self.handlers,i)
      return true
    end
  end
  return false
end
function StateManager:fire(name, ev)
  if self.handlers[name] then
    for i,e in ipairs(self.handlers[name]) do
      if e.context then
        e.handler(e.context, ev)
      else
        e.handler(ev)
      end
    end
  end
end
function StateManager:createContext(name, sender, handler_name)
  return new(StateContext, name, sender, handler_name)
end

Updater = {versions = {}}
function Updater:init()
  if not Config:exists("versions_lookup") then
    Config:set("versions_lookup", {})
  else
    self.versions = Config:get("versions_lookup")
  end
end
function Updater:getApiVersion(name)
  if self.versions[name] then
    return self.versions[name]
  else
    return 0
  end
end
function Updater:setApiVersion(name, version)
  self.versions[name] = version
end
function Updater:run()
  local lookupUrl = "http://192.168.1.1/lookup.txt"
  local updateUrl = "http://192.168.1.1/src/"
  
  local context = StateManager:createContext("Updater", self, "update")
  context:commit("Getting lookup", 0)
  
  local lookupTable = {}
  do
    local success, handle = Updater.httpGet(lookupUrl)
    if not success then
      context:close("Failed")
      return false
    end
    
    local lookupText = handle.readAll()
    lookupText = string.gsub(lookupText, "\n", "")
    lookupText = string.gsub(lookupText, " ", "")
    local lookups = string.split(lookupText, ";")
    
    for i=1, #lookups do
      local e = lookups[i]
      if e ~= "" then
        local unwrapped_split = string.split(string.unwrapOnce(e, "{", "}"), ",")
        local result = {}
        result.net_files = string.split(string.unwrapOnce(unwrapped_split[1], "{", "}"), "|")
        result.version = tonumber(unwrapped_split[2])
        result.file_name = unwrapped_split[3]
        result.forceUpdate = string.toBool(unwrapped_split[4])
        
        if result.forceUpdate or (self:getApiVersion(result.file_name) < result.version) then
          table.insert(lookupTable, result)
        end
      end
    end
  end
  
  if #lookupTable == 0 then
    context:close("No updates found")
    return false
  end
  
  for k,v in ipairs(lookupTable) do
    context:commit(string.format("[%d/%d] Getting files from server.",k, #lookupTable), 100 / (#lookupTable + 2) * (k))
    lookupTable[k].sources = {}
    for k1, v1 in ipairs(v.net_files) do
      if v1 ~= "" then
        context:commit(string.format("[%d/%d](%d/%d) Getting file: \'%s\'",k, #lookupTable, k1, #v.net_files, v1), 100 / (#lookupTable + 2) * (k))
        local success, handle = Updater.httpGet(updateUrl..v1)
        if not success then
          context:close(string.format("[%d/%d](%d/%d) Failed getting file: \'%s\'",k, #lookupTable, k1, #v.net_files, v1))
          return false
        end
        table.insert(lookupTable[k].sources,k1,handle.readAll())
        handle.close()
      end
    end
  end
  
  for k,v in ipairs(lookupTable) do
    context:commit(string.format("[%d/%d] Updating file: \'%s\'",k, #lookupTable, v.file_name), 100 / (#lookupTable + 2) * (#lookupTable + 1))
    local handle = fs.open(v.file_name, "w")
    for k1,v1 in ipairs(lookupTable[k].sources) do
      context:commit(string.format("[%d/%d](%d/%d) Updating file: \'%s\'",k, #lookupTable,k1, #lookupTable[k].sources, v.file_name), 100 / (#lookupTable + 2) * (#lookupTable + 1))
      handle.writeLine(v1)
    end
    handle.flush()
    handle.close()
    
    Updater:setApiVersion(v.file_name,v.version)
  end
  
  context:close("Finished")
  return true
end
function Updater.httpGet(url)
  local h = http.get(url)
  local result = false
  if h.getResponseCode() == 200 then
    result = true
  else
    h.close()
  end
  return result, h
end











