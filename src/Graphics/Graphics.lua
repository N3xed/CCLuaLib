Graphics = {_monitor = false, scale = 1, xOffset = 0, yOffset = 0}
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
function Graphics:writeString(x, y, text, color)
  if color then
    term.setTextColor(color)
  end
  term.setCursorPos(x + self.xOffset, y + self.yOffset)
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
  paintutils.drawPixel(x + self.xOffset, y + self.yOffset, color)
end
function Graphics:drawRect(x, y, width, height, color)
  paintutils.drawBox(x + self.xOffset, y + self.yOffset, x + width + self.xOffset, y + height + self.yOffset, color)
end
function Graphics:fillRect(x, y, width, height, color)
  paintutils.drawFilledBox(x + self.xOffset, y + self.yOffset, x + width + self.xOffset, y + height + self.yOffset, color)
end
function Graphics:drawLine(x1, y1, x2, y2, color)
  paintutils.drawLine(x1 + self.xOffset, y1 + self.yOffset, x2 + self.xOffset, y2 + self.yOffset, color)
end
function Graphics:translate(xo, yo)
  self.xOffset = self.xOffset + xo
  self.yOffset = self.yOffset + yo
end