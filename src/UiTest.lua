shell.run("Core.api")
shell.run("Graphics.api")
shell.run("Ui.api")


function init()
  UiManager:init()
  window = new(UiWindow, 1, 1, 15, 10)
  window.title = "a window"
  button = new(UiButton, 1, 1, 5, 2)
  button.text = "click"
  window.container:addUiObject(button)
  
  UiManager:addUiObject(window)
end

init()
--UiManager:draw()
EventManager:start()