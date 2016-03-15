UiProgressbar = extend(UiObject,{progress = 0, writePercentage = true, maxProgress = 100})
function UiProgressbar:init(x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.theme = ThemeManager:getTheme("progressbar")
end
function UiProgressbar:draw()
  local w = self.width / self.maxProgress * self.progress

  Graphics:fillRect(self.x,self.y,w,self.height,self.theme.background_active)
  Graphics:fillRect(self.x + w, self.y, self.width - w, self.height, self.theme.background)
  if self.writePercentage then
    local text = string.format("%.0d%%",self.progress)
    Graphics:writeStringCentered(self.x,self.y,self.width,self.height,text)
  end
end
function UiProgressbar:setProgress(value)
  self.progress = value
end
function UiProgressbar:getProgress()
  return self.progress
end