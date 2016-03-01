shell.run("Core.api")
shell.run("Ui.api")

function status_func(e)
  print(string.format("sender_name:\'%s\', message:\'%s\', percentage:\'%d\'", e.sender_name, e.message, e.percentage))
end

function init()
  Config:load("config.conf")
  StatusManager:addStatusHandler(status_func)
  
  if Updater:run() then
    ConsoleManager:log("Updated. Rebooting computer...")
    event,key = os.pullEvent("key")
    os.reboot()
  end
end

init()