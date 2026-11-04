-- name: Pontos
-- icon: ............/.rrrrr....../.rrrrr.aaaa./............/.bbbbb.a..a./.bbbbb.aaaa./............/.ooooo....../.ooooo.aaaa./............/.WWWWW....../.WWWWW......
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
function draw()
  clear() decor()
  for i=1,4 do
    local y=30+(i-1)*66
    local fg=(i==4) and C.fg or rgb(255,255,255)
    rect(X0,y,CW,60,COLS[i],14)
    if i==sel then frame(X0-3,y-3,CW+6,66,C.fg,16,3) tri(X0+8,y+22,X0+8,y+38,X0+18,y+30,fg) end
    text(NAMES[i],X0+24,y+8,fg,15)
    text("base "..base[i],X0+24,y+30,fg,11)
    local bx=X0+24
    if road==i then rect(bx,y+44,52,12,fg,4) text("ESTRADA",bx+26,y+45,COLS[i],9,CENTER) bx=bx+56 end
    if army==i then rect(bx,y+44,56,12,fg,4) text("EXÉRCITO",bx+28,y+45,COLS[i],9,CENTER) end
    numtext(tot(i),X1-34,y+28,fg,34)
    if tot(i)>=10 and won==i then text("VENCEU!",X1-34,y+4,fg,10,CENTER) end
  end
end
