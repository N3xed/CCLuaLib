shell.run("Core.api")
shell.run("Graphics.api")
shell.run("Ui.api")


function init()
  buttonTheme = new(Theme)
  buttonTheme.background = colors.blue
  buttonTheme.background_active = colors.red
  ThemeManager:setTheme("button",buttonTheme)
  barTheme = new(Theme)
  barTheme.background = colors.blue
  barTheme.background_active = colors.red
  ThemeManager:setTheme("progressbar",barTheme)

  UiManager:init()
  window = new(UiWindow, 1, 1, 15, 10)
  window.title = "a window"
  button = new(UiButton, 1, 1, 5, 2)
  button.text = "click"
  window.container:addUiObject(button)
  
  bar = new(UiProgressbar, 1, 6, 13, 3)
  bar:setProgress(23)
  bar.writePercentage = true
  window.container:addUiObject(bar)
  
  UiManager:addUiObject(window)
end

init()
--UiManager:draw()
EventManager:start()