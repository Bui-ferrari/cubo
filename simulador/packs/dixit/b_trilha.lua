-- name: Trilha rápida
-- icon: ............/.ffffffffff./.f........f./.f.a......f./.f.a.b....f./.f..a.b...f./.f...a.b..f./.f....a.b.f./.f........f./.ffffffffff./............/............
-- layout: both
-- Placar manual: escolha o jogador e some pontos (DEMONSTRAÇÃO).
local COL={rgb(0xD6,0x45,0x45),rgb(0x3E,0x7A,0xA7),rgb(0x4F,0xA7,0x60),rgb(0xF2,0xC2,0x30),rgb(0xD9,0x6B,0xB0),rgb(0xEC,0x66,0x3B)}
local NAME={"Vermelho","Azul","Verde","Amarelo","Rosa","Laranja"}
local WHITE=rgb(255,255,255)
local META=30
local sc={0,0,0,0,0,0}
local sel=1
local fx=0
function on_enter() labels("@plus 1","@minus 1","Anterior","Próximo","@plus 3") repeat_pads("left right") end
local function win() for p=1,6 do if sc[p]>=META then return p end end end
function on_pad(d)
  if d=="left" then sel=(sel-2)%6+1 sfx("tick")
  elseif d=="right" then sel=sel%6+1 sfx("tick")
  elseif d=="up" then sc[sel]=math.min(99,sc[sel]+1) sfx("tick")
  elseif d=="down" then sc[sel]=math.max(0,sc[sel]-1) sfx("back")
  elseif d=="ok" then sc[sel]=math.min(99,sc[sel]+3) sfx("confirm") end
  if win()==sel and sc[sel]>=META then sfx("win") end
end
function update(dt) fx=fx+dt end
local function pl(p,x,y,w,h,P)
  local on=(p==sel)
  if on then rect(x,y,w,h,C.panel,10) frame(x,y,w,h,C.accent,10,2) end
  local nc=sc[p]>=META and C.accent or C.fg
  if P then
    circle(x+16,y+15,9,COL[p])
    text(NAME[p],x+32,y+9,C.fg,12)
    rect(x+104,y+11,44,8,C.bg,3)
    local f=math.floor(44*math.min(1,sc[p]/META))
    if f>0 then rect(x+104,y+11,f,8,COL[p],3) end
    numtext(sc[p],x+168,y+15,nc,18)
  else
    circle(x+14,y+13,8,COL[p])
    text(NAME[p],x+28,y+7,C.fg,12)
    numtext(sc[p],x+w-18,y+13,nc,18)
    rect(x+10,y+28,w-20,8,C.bg,3)
    local f=math.floor((w-20)*math.min(1,sc[p]/META))
    if f>0 then rect(x+10,y+28,f,8,COL[p],3) end
  end
end
function draw()
  clear() decor()
  local P=portrait()
  local cx=X0+CW//2
  text("Trilha até "..META,cx,P and 30 or Y0+2,C.mute,12,CENTER)
  if P then
    for p=1,6 do pl(p,X0,52+(p-1)*34,CW,30,true) end
  else
    local w=(CW-8)//2
    for p=1,6 do pl(p,X0+((p-1)//3)*(w+8),Y0+22+((p-1)%3)*48,w,44,false) end
  end
  local wn=win()
  if wn then text(NAME[wn].." chegou à meta!",cx,P and 262 or Y1-16,(math.floor(fx*3)%2==0) and C.accent or C.fg,13,CENTER) end
end
