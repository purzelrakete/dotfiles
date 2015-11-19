-- close all chrome tabs

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "j", function()
  local chrome = "Google Chrome"
  local app = hs.application.find(chrome)

  if app then
    app:kill()
  end

  hs.application.open(chrome)
end)

-- reload hammerspoon configuration

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "r", function()
  hs.reload()
  hs.alert.show("Config loaded")
end)
