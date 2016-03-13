shell.run("Core.api")
shell.run("Graphics.api")
shell.run("Ui.api")


function init()
  UiManager:init()
  window = new(UiWindow, 5, 5, 30, 30)
  window.title = "a window"
  button = new(UiButton, 1, 1, 10, 5)
  button.text = "click"
  window.container:addUiObject(button)
  
  UiManager:addUiObject(window)
end

init()
EventManager:start()