Theme = extend(table,{
  background = colors.gray,
  background_active = colors.lightGray,
  border = colors.green,
  border_active = colors.red,
  border_width = 3,
  font_color = colors.white,
  font_color_active = colors.white
})

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
