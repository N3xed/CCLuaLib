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
function string.unwrap(s, opener, closer)
  local result = {}
  local from = 1
  local to = 1
  local delim_from, delim_to = string.find(s,opener,from)
  local openerCount = 0
  while delim_from or (openerCount > 0) do
    if openerCount == 0 then
      from = delim_to + 1
      to = from
    else
      local delim1_from, delim1_to = string.find(s,closer,to)
      if not delim1_from then
        break
      end
      if (delim1_from < delim_from) or not delim_from then
        if (delim1_from - 1) < from then
          table.insert(result,"")
        else
          table.insert(result,string.sub(s,from,delim1_from - 1))
        end
        openerCount = 0
        from = delim1_to + 1
        to = from
      else 
        openerCount = openerCount + 1
        to = delim1_to + 1
      end
    end
    delim_from, delim_to = string.find(s,opener,to)
  end
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

StatusManager = {handlers = {}}
function StatusManager:addStatusHandler(func, context)
  table.insert(self.handlers, {handler = func, context = context})
end
function StatusManager:removeStatusHandler(func)
  for i=1, #self.handlers do
    if self.handlers[i].handler == func then
      table.remove(self.handlers,i)
      return true
    end
  end
  return false
end
function StatusManager:_fire(e)
  for i=1,#self.handlers do
    local e = self.handlers[i]
    if e.context then
      e.handler(context, e)
    else
      e.handler(e)
    end
  end
end
function StatusManager:commitInitial(sender_name, message, percentage, sender)
  self:_fire({sender_name = sender_name, message = message, percentage = percentage, init = true, close = false, sender = sender})
end
function StatusManager:commitUpdate(sender_name, message, percentage, sender)
  self:_fire({sender_name = sender_name, message = message, percentage = percentage, init = false, close = false, sender = sender})
end
function StatusManager:commitClose(sender_name, message, percentage, sender)
  self:_fire({sender_name = sender_name, message = message, percentage = percentage, init = false, close = true, sender = sender})
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
  local lookupUrl = "https://raw.githubusercontent.com/N3xed/ComputerCraft/master/lookup.txt"
  local updateUrl = "https://raw.githubusercontent.com/N3xed/ComputerCraft/master/src/"
  
  StatusManager:commitInitial("Updater","Getting lookup.", 0, self)
  
  local lookupTable = {}
  do
    local success, handle = Updater.httpGet(lookupUrl)
    if not success then
      StatusManager:commitClose("Updater","Failed",100,self)
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
        result.net_files = string.split(string.unwrapOnce(unwrapped_split[1], "{", "}"), "/")
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
    StatusManager:commitClose("Updater","No updates found. Finished.", 100,self)
    return false
  end
  
  for k,v in ipairs(lookupTable) do
    StatusManager:commitUpdate("Updater",string.format("[%d/%d] Getting files from server.",k, #lookupTable), 100 / (#lookupTable + 2) * (k),self)
    lookupTable[k].sources = {}
    for k1, v1 in ipairs(v.net_files) do
      StatusManager:commitUpdate("Updater",string.format("[%d/%d](%d/%d) Getting file: \'%s\'",k, #lookupTable, k1, #v.net_files, v1), 100 / (#lookupTable + 2) * (k),self)
      local success, handle = Updater.httpGet(updateUrl..v1)
      if not success then
        StatusManager:commitClose("Updater",string.format("[%d/%d](%d/%d) Failed getting file: \'%s\'",k, #lookupTable, k1, #v.net_files, v1), 100,self)
        return false
      end
      table.insert(lookupTable[k].sources,k1,handle.readAll())
      handle.close()
    end
  end
  
  for k,v in ipairs(lookupTable) do
    StatusManager:commitUpdate("Updater",string.format("[%d/%d] Updating file: \'%s\'",k, #lookupTable, v.file_name), 100 / (#lookupTable + 2) * (#lookupTable + 1),self)
    local handle = fs.open(v.file_name, "w")
    for k1,v1 in ipairs(lookupTable[k].sources) do
      StatusManager:commitUpdate("Updater",string.format("[%d/%d](%d/%d) Updating file: \'%s\'",k, #lookupTable,k1, #lookupTable[k].sources, v.file_name), 100 / (#lookupTable + 2) * (#lookupTable + 1),self)
      handle.writeLine(v1)
    end
    handle.flush()
    handle.close()
    
    Updater:setApiVersion(v.file_name,v.version)
  end
  
  StatusManager:commitClose("Updater","Finished.",100,self)
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














