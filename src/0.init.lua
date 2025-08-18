--hackweek-pico8-game
-- vim: sw=2 ts=2 et

x=64
y=127 - 8
c=127
clock=0

-- const
num_enemies = 8
row_height = 12
gap_width = 10
bg_color = 7

rows = {}
enemies = {}

function sign(x)
  -- can't use int division because of femto8
  return x / abs(x)
end

function _init()
  for i = 1,num_enemies do
    rows[i] = {}
    prev = 0
    for j = 1,rnd(3) + 1 do
      prev = rnd(128 - gap_width - prev)
      rows[i][j] = prev
    end

    enemies[i] = { x_pos = rnd(127 - gap_width), dir = 1 }
  end
end

function _update()
    if (btn(0)) then x-=1 end
    if (btn(1)) then x+=1 end
    if (btn(2)) then y-=1 end
    if (btn(3)) then y+=1 end
    if (btn(4)) then y-=4 end
    if (btn(5)) then c=64 end

    -- edge collision
    x = mid(0, x, 127)
    y = mid(0, y, 127)

end

function _draw()
    rectfill(0,0,127,127,5)
    spr(1,x,y)
end

  for y,data in pairs(enemies) do
    spr(2,data.x_pos, y * row_height + 4)
  end

  spr(1,x,y)
end
