--hackweek-pico8-game

x=64
y=64
c=127

function _update()
 if (btn(0)) then x-=1 end
 if (btn(1)) then x+=1 end
 if (btn(2)) then y-=1 end
 if (btn(3)) then y+=1 end
 if (btn(4)) then c=127 end
 if (btn(5)) then c=64 end
end

function _draw()
 rectfill(0,0,127,127,5)
 spr(1,x,y)
end

