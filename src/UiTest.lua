shell.run("Core.api")
shell.run("Graphics.api")
shell.run("Ui.api")

UiManager:init()

local window = new(UiWindow, 5, 5, 30, 30)
window.title = "a window"
local button = new(UiButton, 1, 1, 10, 5)
button.text = "click"
window:container():addUiObject(button)

UiManager:addUiObject(window)

EventManager:start()