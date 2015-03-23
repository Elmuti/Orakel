local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local lib = {}

--a: Max. brightness
--z: 0 brightness
lib.UpdateInterval = 1/20 -- = 0.05 seconds = 50 milliseconds
lib.Appearances = "abcdefghijklmnopqrstuvwxyz" --26 characters



local function nthCharacter(char)
  for c = 1, lib.Appearances:len() do
    if lib.Appearances:sub(c,c) == char then
      return c
    end
  end
  return nil
end


function lib.BrightFromChar(char)
  local nth = nthCharacter(char)
  return (1 - (lib.UpdateInterval * nth))
end


return lib