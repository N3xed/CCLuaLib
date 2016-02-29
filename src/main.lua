EventManager = {eventHandlers = {}, running = false}
function EventManager:run()
  while self.running do
    local event, arg1, arg2, arg3 = os.pullEvent()
    if self.eventHandlers[event] then
      for i=1, #self.eventHandlers[event] do
        self.eventHandlers[event][i](arg1, arg2, arg3)
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
function EventManager:stop()
  self.running = false
  os.queueEvent("eventListenerStop")
end
function EventManager:addEventListener(event, func)
  if not self.eventHandlers[event] then
    self.eventHandlers[event] = {}
  end
  table.insert(self.eventHandlers[event], func)
end
function EventManager:removeEventHandler(event, handler)
  for i=1,table.getn(self.eventHandlers[event]) do
    if self.eventHandlers[event][i] == handler then
      table.remove(self.eventHandlers[event], i)
      break
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
function ConsoleManager:fireCommand()
  os.queueEvent("console_cmd", self.stringBuffer)
end
function ConsoleManager.charHandler(char)
  ConsoleManager.stringBuffer = ConsoleManager.stringBuffer .. char
  term.write(char)
end
function ConsoleManager.enterHandler(key, isHeld)
  if key == 28 then
    print("")
    os.queueEvent("console_cmd", ConsoleManager.stringBuffer)
    ConsoleManager.stringBuffer = ""
  end
end
function ConsoleManager:start()
  EventManager:addEventListener("char", ConsoleManager.charHandler)
  EventManager:addEventListener("key", ConsoleManager.enterHandler)
end
function ConsoleManager:stop()
  EventManager:removeEventHandler("char", ConsoleManager.charHandler)
end
function ConsoleManager:log(message)
  print(message)
end

CommandManager = {commandHandlers = {}}
function CommandManager.handler(cmd)
  cmds = string.split(cmd, " ")
  for i=1, #CommandManager.commandHandlers do
    if CommandManager.commandHandlers[i].name == cmds[1] then
      CommandManager.commandHandlers[i].handler(cmds)
    end
  end
end
function CommandManager:start()
  EventManager:addEventListener("console_cmd",self.handler)
end
function CommandManager:stop()
  EventManager:removeEventHandler("console_cmd",self.handler)
end
function CommandManager:addCommandHandler(name, func)
  result = {}
  result.name = name
  result.handler = func
  table.insert(self.commandHandlers, result)
end

Item = {name = "", raw_name = "", chest_id = 0, oredict = {}}
function Item.new (name, raw_name, chest_id, oredict)
  result = Item
  result.name = name
  result.raw_name = raw_name
  result.chest_id = chest_id
  result.oredict = oredict
  return result
end

ItemManager = {items = {}}
function ItemManager:addItem(item)
  table.insert(self.items, item)
end
function ItemManager:existsItem(raw_name)
  for i=1, #self.items do
    if self.items[i].raw_name == raw_name then
      return true
    end
  end
  return false
end
function ItemManager:getItem(raw_name)
  for i=1, #self.items do
    if self.items[i].raw_name == raw_name then
      return self.items[i]
    end
  end
  return nil
end

RednetManager = {isOpen = false, side = "", handlers = {}}
function RednetManager.listener(sender, message, protocol)
  if RednetManager.handlers[protocol] then
    ConsoleManager:log("Handling 'rednet_event' with protocol: '"..protocol.."'")
    for i=1, #RednetManager.handlers[protocol] do
      RednetManager.handlers[protocol][i](sender, message)
    end
  end
end
function RednetManager:init(side)
  if not self.isOpen then
    EventManager:addEventListener("rednet_message",RednetManager.listener)
    rednet.open(side)
    self.isOpen = true
    self.side = side
  end
end
function RednetManager:addRednetListener(protocol, func)
  if not self.handlers[protocol] then
    self.handlers[protocol] = {}
  end
  table.insert(self.handlers[protocol],func)
end
function RednetManager:removeRednetListener(protocol, func)
  for i=1, #self.handlers[protocol] do
    if self.handlers[protocol][i] == func then
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

Chest = {id = 0, name = "", items = {}}
function Chest.new(id, name, items)
  result = Chest
  result.id = id
  result.name = name
  result.items = items
  return result
end

ChestManager = {chests = {}}
function ChestManager.scanReceive(sender, message)
  table.insert(ChestManager.chests, message)
end
function ChestManager:scan()
  self.chests = {}
  rednet.broadcast("info", "chest_info")
end
function ChestManager:init()
  RednetManager:addRednetListener("chest_info", self.scanReceive)
end

function query_func(sender, message)
  item = ItemManager:getItem(message)
  if not item then
    rednet.send(sender, nil, "item_query")
    ConsoleManager:log("Item not found: '"..message.."'.")
  else
    rednet.send(sender, item, "item_query")
    ConsoleManager:log("Item '"..item.raw_name.."' found. Sending data.")
  end
end
function itemAdd_func(sender, message)
  ItemManager:addItem(message)
  ConsoleManager:log("Found new item: {name='"..message.name.."', raw_name='"..message.raw_name.."'}")
end

function exit_func(args)
  close()
end

function main(rednet_side)
  ConsoleManager:start()
  CommandManager:start()
  RednetManager:init(rednet_side)
  
  ChestManager:init()
  ChestManager:scan()
  
  RednetManager:addRednetListener("item_query",query_func)
  RednetManager:addRednetListener("item_add",itemAdd_func)
  
  CommandManager:addCommandHandler("exit",exit_func)
  
  ConsoleManager:log("Initialized.")
  
  EventManager:start()
end
function close()
  RednetManager:close()
  CommandManager:stop()
  ConsoleManager:stop()
  EventManager:stop()
end

main("back")

















