pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- 🎮 Platformer Game
-- A fun 2D platformer with jumping, enemies, and collectibles

-- 📐 game settings
gravity = 0.5
jump_power = -8
player_speed = 2
screen_w = 128
screen_h = 128

-- 👤 player variables
player = {
  x = 10,
  y = 100,
  vx = 0,
  vy = 0,
  width = 6,
  height = 8,
  on_ground = false,
  color = 10,  -- yellow
  health = 3
}

-- 🏗️ platforms
platforms = {}
-- ground platform
add(platforms, {x=0, y=120, w=128, h=8})
-- floating platforms
add(platforms, {x=20, y=100, w=20, h=4})
add(platforms, {x=50, y=80, w=20, h=4})
add(platforms, {x=80, y=60, w=20, h=4})
add(platforms, {x=110, y=40, w=18, h=4})
add(platforms, {x=10, y=40, w=20, h=4})

-- 👹 enemies
enemies = {}
add(enemies, {x=30, y=92, w=6, h=6, vx=1, color=8, health=1})
add(enemies, {x=90, y=52, w=6, h=6, vx=-1, color=8, health=1})

-- ⭐ collectibles
collectibles = {}
add(collectibles, {x=25, y=90, w=4, h=4, collected=false, color=11})
add(collectibles, {x=55, y=70, w=4, h=4, collected=false, color=11})
add(collectibles, {x=85, y=50, w=4, h=4, collected=false, color=11})

-- 🎯 game state
score = 0
game_over = false
level_complete = false

-- 🎮 input and movement
function _update()
  if game_over then
    if btn(4) then  -- restart on button press
      reset_game()
    end
    return
  end
  
  if level_complete then
    if btn(4) then  -- next level on button press
      next_level()
    end
    return
  end
  
  -- player input
  player.vx = 0
  if btn(0) then player.vx = -player_speed end  -- left
  if btn(1) then player.vx = player_speed end   -- right
  
  -- jumping
  if btn(4) and player.on_ground then
    player.vy = jump_power
    player.on_ground = false
  end
  
  -- apply gravity
  player.vy += gravity
  
  -- update player position
  player.x += player.vx
  player.y += player.vy
  
  -- collision detection with platforms
  player.on_ground = false
  for p in all(platforms) do
    if check_collision(player, p) then
      if player.vy > 0 then  -- falling down
        player.y = p.y - player.height
        player.vy = 0
        player.on_ground = true
      elseif player.vy < 0 then  -- jumping up
        player.y = p.y + p.h
        player.vy = 0
      end
    end
  end
  
  -- keep player on screen
  if player.x < 0 then player.x = 0 end
  if player.x > screen_w - player.width then player.x = screen_w - player.width end
  if player.y > screen_h - player.height then 
    player.y = screen_h - player.height
    player.vy = 0
    player.on_ground = true
  end
  
  -- update enemies
  update_enemies()
  
  -- check collectibles
  check_collectibles()
  
  -- check enemy collisions
  check_enemy_collisions()
  
  -- check win condition
  if #collectibles == 0 then
    level_complete = true
  end
end

-- 🖼️ render everything
function _draw()
  cls(0)  -- black background
  
  -- draw platforms
  for p in all(platforms) do
    rectfill(p.x, p.y, p.x + p.w - 1, p.y + p.h - 1, 3)  -- green
  end
  
  -- draw collectibles
  for c in all(collectibles) do
    if not c.collected then
      rectfill(c.x, c.y, c.x + c.w - 1, c.y + c.h - 1, c.color)
    end
  end
  
  -- draw enemies
  for e in all(enemies) do
    rectfill(e.x, e.y, e.x + e.w - 1, e.y + e.h - 1, e.color)
  end
  
  -- draw player
  rectfill(player.x, player.y, player.x + player.width - 1, player.y + player.height - 1, player.color)
  
  -- draw UI
  print("score: " .. score, 2, 2, 7)
  print("health: " .. player.health, 2, 10, 7)
  
  -- game over screen
  if game_over then
    rectfill(20, 50, 108, 78, 1)
    print("game over!", 45, 60, 7)
    print("press ❎ to restart", 35, 70, 7)
  end
  
  -- level complete screen
  if level_complete then
    rectfill(20, 50, 108, 78, 2)
    print("level complete!", 40, 60, 0)
    print("press ❎ for next level", 30, 70, 0)
  end
end

-- 🔧 utility functions
function check_collision(a, b)
  -- handle different property names for width/height
  local a_w = a.width or a.w
  local a_h = a.height or a.h
  local b_w = b.width or b.w
  local b_h = b.height or b.h
  
  return a.x < b.x + b_w and
         a.x + a_w > b.x and
         a.y < b.y + b_h and
         a.y + a_h > b.y
end

function update_enemies()
  for e in all(enemies) do
    -- simple enemy AI - move back and forth
    e.x += e.vx
    
    -- bounce off screen edges
    if e.x <= 0 or e.x >= screen_w - e.w then
      e.vx = -e.vx
    end
    
    -- apply gravity to enemies
    e.vy = (e.vy or 0) + gravity
    e.y += e.vy
    
    -- enemy platform collision
    for p in all(platforms) do
      if check_collision(e, p) then
        if e.vy > 0 then
          e.y = p.y - e.h
          e.vy = 0
        end
      end
    end
  end
end

function check_collectibles()
  for c in all(collectibles) do
    if not c.collected and check_collision(player, c) then
      c.collected = true
      score += 100
      del(collectibles, c)
    end
  end
end

function check_enemy_collisions()
  for e in all(enemies) do
    if check_collision(player, e) then
      player.health -= 1
      if player.health <= 0 then
        game_over = true
      else
        -- knockback effect
        player.vy = -4
        player.x += (player.x < e.x) and -10 or 10
      end
    end
  end
end

function reset_game()
  player.x = 10
  player.y = 100
  player.vx = 0
  player.vy = 0
  player.health = 3
  score = 0
  game_over = false
  level_complete = false
  
  -- reset collectibles
  collectibles = {}
  add(collectibles, {x=25, y=90, w=4, h=4, collected=false, color=11})
  add(collectibles, {x=55, y=70, w=4, h=4, collected=false, color=11})
  add(collectibles, {x=85, y=50, w=4, h=4, collected=false, color=11})
end

function next_level()
  -- simple level progression - add more platforms and enemies
  level_complete = false
  score += 500  -- bonus for completing level
  
  -- add more platforms
  add(platforms, {x=40, y=30, w=15, h=4})
  add(platforms, {x=70, y=20, w=15, h=4})
  
  -- add more enemies
  add(enemies, {x=45, y=22, w=6, h=6, vx=1, color=8, health=1})
  
  -- add more collectibles
  add(collectibles, {x=42, y=20, w=4, h=4, collected=false, color=11})
  add(collectibles, {x=72, y=10, w=4, h=4, collected=false, color=11})
end

