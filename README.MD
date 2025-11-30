# v4-51-golf GitHub repo

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

