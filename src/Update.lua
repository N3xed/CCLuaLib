shell.run("Core.api")
--shell.run("Ui.api")

function status_func(e)
  print(string.format("[%s](%d) %s", e.sender_name, e.percentage, e.message))
end

function init()
  Config:load("config.conf")
  StatusManager:addStatusHandler(status_func)
  
  if Updater:run() then
    ConsoleManager:log("Updated. Rebooting computer...")
  end
  Config:save()
end

init()