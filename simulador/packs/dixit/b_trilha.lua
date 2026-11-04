-- name: Trilha rápida
-- icon: ............/.ffffffffff./.f........f./.f.a......f./.f.a.b....f./.f..a.b...f./.f...a.b..f./.f....a.b.f./.f........f./.ffffffffff./............/............
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
function draw()
  clear() decor()
  text("Trilha até "..META,W//2,30,C.mute,12,CENTER)
  for p=1,6 do
    local y=52+(p-1)*34
    local on=(p==sel)
    if on then rect(X0,y,CW,30,C.panel,10) frame(X0,y,CW,30,C.accent,10,2) end
    circle(X0+16,y+15,9,COL[p])
    text(NAME[p],X0+32,y+9,C.fg,12)
    rect(X0+104,y+11,44,8,C.bg,3)
    local w=math.floor(44*math.min(1,sc[p]/META))
    if w>0 then rect(X0+104,y+11,w,8,COL[p],3) end
    numtext(sc[p],X0+168,y+15,sc[p]>=META and C.accent or C.fg,18)
  end
  local w=win()
  if w then text(NAME[w].." chegou à meta!",W//2,262,(math.floor(fx*3)%2==0) and C.accent or C.fg,13,CENTER) end
end
