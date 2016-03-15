Graphics = {_monitor = false, scale = 1, xOffset = 0, yOffset = 0}
function Graphics:clear()
  term.setBackgroundColor(colors.black)
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
function Graphics:writeString(x, y, text, color)
  if color then
    term.setTextColor(color)
  end
  local xp = x + self.xOffset
  local yp = y + self.yOffset
  
  term.setCursorPos(xp, yp)
  term.write(text)
end
function Graphics:writeStringCentered(x, y, width, height, text, color)
  local yp = y + (height / 2)
  local xp = x + (width / 2) - (string.len(text) / 2)
  self:writeString(xp, yp, text, color)
end
function Graphics:setOutput(target)
  term.redirect(target)
end
function Graphics:getOutput()
  return term.current()
end
function Graphics:drawPixel(x, y, color)
  local xp = x + self.xOffset
  local yp = y + self.yOffset
  if xp > UiManager.width or yp > UiManager.height then
    return
  end
  paintutils.drawPixel(xp, yp, color)
end
function Graphics:drawRect(x, y, width, height, color)
  local xp = x + self.xOffset
  local yp = y + self.yOffset
  
  paintutils.drawBox(xp, yp, xp + width, yp + height, color)
end
function Graphics:fillRect(x, y, width, height, color)
  local xp = x + self.xOffset
  local yp = y + self.yOffset
  
  paintutils.drawFilledBox(xp, yp, xp + width, yp + height, color)
end
function Graphics:drawLine(x1, y1, x2, y2, color)
  paintutils.drawLine(x1 + self.xOffset, y1 + self.yOffset, x2 + self.xOffset, y2 + self.yOffset, color)
end
function Graphics:translate(xo, yo)
  self.xOffset = self.xOffset + xo
  self.yOffset = self.yOffset + yo
end