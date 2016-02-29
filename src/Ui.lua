VERSION = 0.1

Theme = {
  background = 0,
  background_hover = 0,
  background_active = 0,
  border = 0,
  border_hover = 0,
  border_active = 0,
  border_width = 1,
  font_color = 0xaaaaaa,
  font_size = 12
}

ThemeManager = {themes = {}, default = nil}
function ThemeManager:load(file)
  self.default = Theme
  self._filePath = file
  if not fs.exists(file) then
    local h = fs.open(file, "w")
    h.close()
  else
    local h = fs.open(file, "r")
    self.themes = textutils.unserialize(h.readAll())
    h.close()
  end
  EventManager:fireEvent("config_load","ThemeManager")
end
function ThemeManager:save()
  local h = fs.open(self._filePath, "w")
  h.write(textutils.serialize(self.themes))
  h.flush()
  h.close()
  EventManager:fireEvent("config_save", "ThemeManager")
end
function ThemeManager:getTheme(name)
  if self.themes[name] then
    return self.themes[name]
  else
    return self.default
  end
end
function ThemeManager:setTheme(name, theme)
  self.themes[name] = theme
end