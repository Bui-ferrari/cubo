-- name: Pontos
-- icon: ............/.rrrrr....../.rrrrr.aaaa./............/.bbbbb.a..a./.bbbbb.aaaa./............/.ooooo....../.ooooo.aaaa./............/.WWWWW....../.WWWWW......
-- layout: both
-- Pontos de vitória de 4 jogadores, com maior estrada e maior exército (+2 cada). 10 pontos vence.
local NAMES={"Vermelho","Azul","Laranja","Branco"}
local COLS={rgb(0xD6,0x45,0x45),rgb(0x3E,0x7A,0xA7),rgb(0xEC,0x66,0x3B),rgb(0xF4,0xEE,0xE4)}
local base={2,2,2,2}
local road,army=0,0
local sel=1
local won=0
local function tot(i) return base[i]+(road==i and 2 or 0)+(army==i and 2 or 0) end
local function chk()
  local w=0 for i=1,4 do if tot(i)>=10 then w=i end end
  if w~=0 and w~=won then sfx("win") end
  won=w
end
function on_enter()
  labels("@plus 1 ponto","@minus 1 ponto","Estrada +2","Exército +2","Próximo") repeat_pads("up down")
end
function on_pad(p)
  if p=="up" then base[sel]=math.min(12,base[sel]+1) sfx("tick")
  elseif p=="down" then base[sel]=math.max(0,base[sel]-1) sfx("back")
  elseif p=="left" then road=(road==sel) and 0 or sel sfx("confirm")
  elseif p=="right" then army=(army==sel) and 0 or sel sfx("confirm")
  elseif p=="ok" then sel=sel%4+1 sfx("tick") end
  chk()
end
local function cell(i,x,y,w,h)
  local fg=(i==4) and C.fg or rgb(255,255,255)
  rect(x,y,w,h,COLS[i],14)
  if i==sel then frame(x-3,y-3,w+6,h+6,C.fg,16,3) tri(x+8,y+h//2-8,x+8,y+h//2+8,x+18,y+h//2,fg) end
  text(NAMES[i],x+24,y+8,fg,15)
  text("base "..base[i],x+24,y+30,fg,11)
  local bx=x+24
  if road==i then rect(bx,y+h-16,52,12,fg,4) text("ESTRADA",bx+26,y+h-15,COLS[i],9,CENTER) bx=bx+56 end
  if army==i then rect(bx,y+h-16,56,12,fg,4) text("EXÉRCITO",bx+28,y+h-15,COLS[i],9,CENTER) end
  numtext(tot(i),x+w-34,y+h//2-2,fg,34)
  if tot(i)>=10 and won==i then text("VENCEU!",x+w-34,y+4,fg,10,CENTER) end
end
function draw()
  clear() decor()
  if portrait() then
    for i=1,4 do cell(i,X0,30+(i-1)*66,CW,60) end
  else
    local w,h=(CW-8)//2,(CH-8)//2
    for i=1,4 do cell(i,X0+((i-1)%2)*(w+8),Y0+((i-1)//2)*(h+8),w,h) end
  end
end
