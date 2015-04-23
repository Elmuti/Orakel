![alt tag](http://puu.sh/gmAS2/7fe266107d.png)

## Documentation

Full documentation for everything and beyond can be found in the [Orakel wiki](https://github.com/RicochetSoftware/Orakel/wiki/Introduction)

## To-Do list / Suggestions

Everything on that matter can be found on our [Trello page](https://trello.com/b/848sAYmT/orakel)!

## Third party code utilization

Orakel utilizes some third party code, Including [CruxAnimation](https://github.com/wes-BAN/crux-animation), The CFrameInterp module made by [Mark Langen](https://github.com/stravant)
and snippets of library code from [Jonathan Holmes](https://github.com/Vorlias) and [Quenty](https://github.com/Quenty).


## Update / Change Log


#### Version 0.8.9.3
- New library "CFrameLib.lua"
- Moved "Orakel.TweenModel" to Libraries/Utilities/CFrameLib.lua
- New entity "math_counter" on the works
- New entity "logic_timer" on the works
- New entity "logic_auto" on the works

#### Version 0.8.9.2

- New input "FireUser1" on all entities
- New input "FireUser2" on all entities
- New input "FireUser3" on all entities
- New input "FireUser4" on all entities
- New output "OnUser1" on all entities
- New output "OnUser2" on all entities
- New output "OnUser3" on all entities
- New output "OnUser4" on all entities

#### Version 0.8.9.0

- Added Camera / Control scripts
- New entity "ambient_generic"
- New entity "light"
- New entity "light_surface"
- Light behaviour system based on strings
- Fixed SoundLib.PlaySoundClient
- Fixed SoundLib.PlaySoundClientAsync
- Fixed SoundLib.PlaySoundClientEvent

#### Version 0.8.8.9

- Entities now have both inputs and outputs.
- New entity "point_viewcontrol"
- Deprecated "prop_fluorescent", as it is obsolete
- Google Analytics support

#### Version 0.8.8.0

- Created a Main Menu
- New entity "point_viewcontrol"

#### Version 0.8.7.2

- Damagetypes and damage handling
- Model tweening
- Adopted CruxAnimation
- Added navigation clips (Brush entity "nav_clip")
- Defined all entities inside their modules and removed all dependencies outside of those modules