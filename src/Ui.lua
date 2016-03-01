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

ThemeManager = {themes = {}, default = Theme}
function ThemeManager:init()
  if not Config:exists("theme") then
    Config:set("theme",self.themes)
  else
    self.themes = Config:get("theme")
  end
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

