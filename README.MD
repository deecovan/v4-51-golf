# v4-51-golf GitHub repo

## @CONTINUE 
- Add Ball normal
- Add complex interface
  - Game settings
  - Car settings
  - Ball settings
- Start draw 1x1 course

## 25.11.26 - Add Velicle
- Add Center of Mass with node
- Juicy:
   - Smooth Camera gimble rotation
   - Add Gimble Light
   - Test export

- Fix Reloading messages and signals 
- Enable Occlusion Culling with 256 rays
- @REMEMBER to set Vehicle Phys.Material
  - Friction 0.01
  - Bounce 0.5
  - Linea Dump 0.5
  - ALL wheels: Wheel Roll Influence 0.01

- Test Export
- Fix CameraGimble to Car
  - @TODO smooth gimble
- Add Car Values settings Tested for 1000 kg 3x2m car
  - Tested for 1000 kg 3x2m car
  - [See Image](./Docs/Car_Values_Settings.png)

- Add Steering, Acc/Brake controls
- Clean up Scripts and Scenes
- Modify CamerGimbal
  - Follow the car
- Create Vehicle2D scene with Wheel3D nodes
- Add Vehicle to Main scene

## @BACKLOG
- Add Ball is_lowspeed and add_friction functions

- Add David Sirera's cars
- Add Kenney's city assets

## @STORY
1. CarBall online duel game
  - Drive and bounce the ball 
  - Hit the opponent's gate
  - 1x1 ELO rated duels
2. Build your own Course
  - The Courses are built with 3D Grids
  - City driving between the Courses
  - StreetRacing duels in the City

## 25.11.25
- Remake Golf3D from the book
