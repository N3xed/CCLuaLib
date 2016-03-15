shell.run("Core.api")
shell.run("Graphics.api")
shell.run("Ui.api")

Config:load("config.conf")

local theme = new(Theme)
theme.background = colors.blue
theme.background_active = colors.red
ThemeManager:setTheme("button",theme)
ThemeManager:setTheme("progressbar",theme)

local updaterWindow = new(UiWindow,1, 1, 49, 15)
updaterWindow:setTitle("Updater")
local progressbar = new(UiProgressbar, 1, 1, 47, 3)
local label = new(UiLabel, 1, 5, "Updating")
local button = new(UiButton, 41, 10, 7, 3)
button.enabled = false
button.text = "Ok"

updaterWindow.container:addUiObject(progressbar)
updaterWindow.container:addUiObject(label)
updaterWindow.container:addUiObject(button)

function status_func(e)
  progressbar:setProgress(e.percentage)
  label:setText(e.message)
  
  if e.finished then
    button.enabled = true
  end
  UiManager:draw()
end

function button_handler()
  --Config:save()
  EventManager:stop()
end

function run()
  Updater:init()
  Updater:run()
end

UiManager:init()
UiManager:addUiObject(updaterWindow)

StateManager:addHandler("update", status_func)
button:listeners():addEventListener("mouseUp", button_handler)
UiManager:addEventListener("keyDown",button_handler)

UiManager:draw()

run()
EventManager:start()
UiManager:dispose()