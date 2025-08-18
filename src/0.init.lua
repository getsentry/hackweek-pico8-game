-- vim: sw=2 ts=2 et

-- 0/1 = flip/flop (used for slow-mo)
-- 2 = game over
state=0

player = { x_pos = 64, y_pos = 127 - 8, width = 8, height = 8 }
walls = {}
enemies = {}

-- const
num_enemies = 8
row_height = 12
gap_width = 10
bg_color = 7

function sign(x)
  -- can't use int division because of femto8
  return x / abs(x)
end

function _init()
  wall_i = 1
  for i = 1,num_enemies do
    previous_wall = 0
    gap_position = 0
    num_gaps = flr(rnd(3) + 1)
    for gap_i = 1,num_gaps do
      -- ensure there's room for this gap and potentially more gaps
      remaining_gaps = num_gaps - gap_i + 1
      min_space_needed = remaining_gaps * gap_width
      max_gap_position = 128 - min_space_needed
      
      if previous_wall >= max_gap_position then
        -- not enough room for more gaps, skip
        break
      end
      
      gap_position = flr(previous_wall + rnd(max_gap_position - previous_wall))
      wall_width = gap_position - previous_wall
      
      if wall_width > 0 then
        walls[wall_i] = { x_pos = previous_wall, y_pos = (i+1)*row_height, width = wall_width, height = 1 }
        wall_i += 1
      end
      
      previous_wall = gap_position + gap_width
    end
    -- add final wall segment from last gap to end of screen
    if previous_wall < 128 then
      walls[wall_i] = { x_pos = previous_wall, y_pos = (i+1)*row_height, width = 128 - previous_wall, height = 1 }
      wall_i += 1
    end

    enemies[i] = { y_pos = i * row_height + 4, x_pos = rnd(127 - gap_width), direction = 1, width = 8, height = 8 }
  end
end

function _update()
  if state == 2 then
    return
  elseif state == 0 then
    state = 1
  else
    state = 0
  end

  -- moving enemy (state == 0 => every second frame, half-speed)
  if state == 0 then
    for y,data in pairs(enemies) do
      data.x_pos += data.direction

      if data.x_pos < 0 or data.x_pos > 128 - 8 then
        data.direction *= -1
      end
    end
  end

  player_x_moved = 0
  player_y_moved = 0
  -- moving around the player
  if btn(4) and btn(5) then
    -- holding X and O moves up
    player_y_moved = -1
  elseif btn(4) then
    -- holding X moves left
    player_x_moved = -1
  elseif btn(5) then
    -- holding O moves right
    player_x_moved = 1
  end

  player.x_pos += player_x_moved
  player.y_pos += player_y_moved

  -- edge collision
  player.x_pos = mid(0, player.x_pos, 127 - player.width)
  player.y_pos = mid(0, player.y_pos, 127 - player.height)

  -- enemy collision
  for enemy in all(enemies) do
    -- padding=2 => can overlap by 1-2 pixels
    if collides(enemy, player, 2) then
      -- game over
      state = 2
    end
  end

  -- wall collision
  for wall in all(walls) do
    if collides(wall, player, 2) then
      -- revert player movement
      player.x_pos -= player_x_moved
      player.y_pos -= player_y_moved
    end
  end
end

function collides(obj1, obj2, padding)
  x = obj1.x_pos
  y = obj1.y_pos
  x2 = obj2.x_pos
  y2 = obj2.y_pos

  if x + obj1.width - padding < x2 or y + obj1.height - padding < y2 or x2 + obj2.width - padding < x or y2 + obj2.height - padding < y then
    return false
  end
  return true
end

function _draw()
  if state == 2 then
    rectfill(0,0,127,127,bg_color)
    print("GAME OVER", 64, 64, 0)
  else
    rectfill(0,0,127,127,bg_color)
    for wall in all(walls) do
      rectfill(wall.x_pos,wall.y_pos,wall.x_pos + wall.width - 1,wall.y_pos + wall.height - 1,100)
    end

    for data in all(enemies) do
      spr(2,data.x_pos, data.y_pos)
    end

    spr(1,player.x_pos,player.y_pos)
  end
end
