# v4-51-golf GitHub repo

### *Adding*
- Added landscapes:
  - One Sand__landscape with height waves
  - Two Sand__landlow A,B for fast FPS
* Started adding Objects
  - Add Gates and Turn markers
* Started Main scene 
  - Add Main scene
  - Updated scenes and scripts

### *Add Next*
- Add Driving overlays
- Add 1PV and side cameras
- Add Escape menus
  - Game settings
  - Scene settings
  - Car setup

## 25.12.04 

### MainSpaFlat.v1.2 with shaded terrain, light and camera
- Added Sand, Updated Sand shader
- Fixed Gimbal and Camera
- Modified Light

### Fixed
- Fixed Camera rotation jump when when y=360+n
  - Updated Gimbal logic
  - Added log overlay
  - Fixed keyboard/zoom rotation

### Added
- Braking with Vehicle3D or Braking with Wheels
  - separate front/rear values 

### Fixed
- Power sound too hight on 90%+ power
  - Added soft sounds
- Slip overlay showing 30% on slip 
  - Fixed using 100% values in function

## 25.12.03 Begin Overlays
- Added Scene loader
  - [F7] next scene
- Update project.* files
- Moved Pow sound to th Rear bamper
- Last update for lights and sounds feels juicy

### Improved v1.1
- Sound and Visual improvements in version 1.1
  - important duplicated to *v1.1.*
- tag v1.1

- Add WheelController to Vehicle
  - Add Slop indicators
  - Add Slip sounds to wheels
  - Tag sound
- Add EngineController for engine sounds:
  - Sound Scale from velocity, Volume from power

- Next:
1. Starting menu
  - Select scene
  - Select car
2. Also used as Escape menu

## Overlay 1.0
- Add Wheels Grip panel to overlay
  - 10/1 rate (show 10% as 100%)

- Copy Themes/FlatUI40 v4.0 to v4.4 to edit
- Edit theme
- Delete Project/.godot/* and re-import
- Test teme

## Fanta v1.1
- Re-export Fanta Car and Wheel from Blender
- Update Fanta v1.1 physics:
  - re-Import Car and Wheel models 
    - using Physics Collision Import Generator
  - Generate new Car body collisions
  - Simulate braking drift and speeding grip:
    - Add mult_slip_rear multiplier
    - Change suspension values
    - other improvements
- Add reverse engine control 

- Update Lights
- Merfe ZC's branch
- Upgrade Meshes from Project menu
- Delete unused Car mass 
  - Used default 40kg

- Improve Coasting with Engine LERP down
  - Add engine_brake_speed, engine_coast, coasting_speed

- Test Export with Lights 
  - 60 FPS settings

## 25.12.02 Godot Spa
- Tested: SpaHeight looks great, SpaFlat broken
- Tested: SpaFlat v1.1 lorks great!
- @REMEMBER! Using large GLB with collisions export/import steps: 
  - GLB Blender export
  - Physics Collision Import Generator 
    - add-on in GoDot
    - Enable it from Project Plugins
  - Add GLB from FileSystem to scene
  - Open it to edit, OPEN ANYWAY if confirm
  - Remove unnecessary nodes
  - Generate collisions from central-top menu
    - from Mesh, Create collision shape
    - use Static body child, trimesh
  - Save as, new scene, than add it to the project

- Create Spa and Spa Height track
  - Path-based
  - Standart materials, without textures
  - Using [video](https://www.youtube.com/watch?v=uJMPLeL8G6M)

- Add Blender Spa project
- Export and test stright forward track

## 25.12.01 Start refactoring
- Branch refactor
  - Refactor project files
    - Root files
      - LFS and gitignore files
    - Move Materials to folder
    - Main scene
    - Fanta scene
      - Both using Gravity scale 2.0 
      - Deleted grav_mod var

      - Current values when Tested both cars 

	## Vehicle.gd

	TESTED 699f 205kph, 4sec to 100kph

	MAX_SPEED = 100.0

	MAX_POWER = 700.0 # per each Traction wheel

	First gear 0-33kph

	## VehicleFanta.gd

	TESTED 799f 235kph, 4.5sec to 100kph

	MAX_SPEED = 125.0

	MAX_POWER = 800.0 # per each Traction wheel

	First gear 0-40kph

## 25.11.31 Tag landgen-00 
- Start building LandGen Chank generation Tool

## 25.11.31 Shaders and Noises
- Terra proto tested exported looks great
- Adeded noise to terra's collisionshape3d
- Added viewport's modes with [F6] key
- Added Your first 3D shader to Terra mech

## 25.11.289 Fanta Supercar
- Added Fanta blender model
  - Wheels
  - Car body
  - @BUG with collision!!!
- New physics for Fanta
- Tested max speed 320KPH
  - used MAX_SPEED 140ms(500KPH)

## @TODO
1. Add Gears, physics, visuals
  - Using added engine power graph
  - Auto gearbox with auto clutch
  - Interface to change gears ratio
    - Click to select gear and max ratio with overlay
2. Add complex interface
  - Car settings using Vehicle2D vars in the script
  - Ball settings
  - Game settings 

## 25.11.29 Need to chill a day
- Tested Physics Boxes
  - Physics NOT WORK between StaticBody3D and VehicleBody3D
- Fixed Textures, Shadows, AA, Import
  - Reimport crashed and killed textures

### Finished
- Tested fixed values:
  - match_power=power_curve, 
  - Rest, Travel, Stiff, MaxV
- Add Camera Pan with Mouse 
- Updated, Upgraded, Exported
- Tested Setup Vehicle3D and its PhysicsMaterial values
- Tested Setup Wheel3Ds values

- Fixed Camera Gimble follow the Car
  - separate lerp for each axe
  - keyboard camera rotation

- Added Engine Power curve overlay 
  - call_draw_curve(curve: Array)

## 25.11.27
- Added Ball normal
- Added wheel normal
- Added Dodge car model
- Added export variables, almost all
- Car rescaled to 0.8x
  - @REMEMBER values tested with Dodge scaled 0.8 1000kg 1.5G
- Main and RaceTrack rebuilt 

## 25.11.26 - Add Velicle
- Added Center of Mass with node
- Juicy:
   - Smooth Camera gimble rotation
   - Added Gimble Light
   - Tested export

- Fixed Reloading messages and signals 
- Enabled Occlusion Culling with 256 rays
- @REMEMBER to set Vehicle Phys.Material
  - Friction 0.01
  - Bounce 0.5
  - Linea Dump 0.5
  - ALL wheels: Wheel Roll Influence 0.01

- Test Export
- Fixed CameraGimble to Car
  - @TODO smooth gimble
- Added Car Values settings Tested for 1000 kg 3x2m car
  - Tested for 1000 kg 3x2m car
  - [See Image](./Docs/Car_Values_Settings.png)

- Added Steering, Acc/Brake controls
- Cleaned up Scripts and Scenes
- Modified CamerGimbal
  - Follow the car
- Created Vehicle2D scene with Wheel3D nodes
- Add Vehicle to Main scene

## @STORY
1. CarBall online duel game
  - Drive and bounce the ball 
  - Hit the opponent's gate
  - 1x1 ELO rated duels
2. Build your own Course
  - The Courses are built with 3D Grids
  - City driving between the Courses
  - StreetRacing duels in the City

