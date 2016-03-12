EventDispatcher = extend(table, {eventName = nil, eventObj = nil})
function EventDispatcher:init()
end
function EventDispatcher:set(name, event)
  self.eventName = name
  self.eventObj = event
end

function EventDispatcher:dispatch(name, func, context)
  if self.eventName == name then
    if context then
      func(context, self.eventObj)
    else
      func(self.eventObj)
    end
  end
end
function EventDispatcher:remove()
  self.eventName = nil
  self.eventObj = nil
end