-- name: Relógio de turnos
-- icon: ....ffff..../..ff....ff../.f...a....f./.f...a....f./f....a.....f/f....aaa...f/f..........f/.f........f./.f........f./..ff....ff../....ffff..../............
-- Como relógio de xadrez: cada time tem o seu tempo. Toque no seu lado para passar a vez.
local total=180
local t={180,180}      -- 1 = lado de cima, 2 = lado de baixo
local active=0         -- 0 = parado
local over=0
local function lab()
  if active==0 then labels("Começa","+30s","Começa","-30s","Zerar","","")
  else labels("Passar","","Passar","","Pausar","Zerar","") end
  repeat_pads("")
end
function on_enter() lab() end
function on_pad(d)
  local side=(d=="n") and 1 or ((d=="s") and 2 or 0)
  if over>0 then return end
  if active==0 then
    if side>0 then active=side sfx("confirm") lab()
    elseif d=="e" then total=clamp(total+30,30,3600) t={total,total} sfx("tick")
    elseif d=="w" then total=clamp(total-30,30,3600) t={total,total} sfx("tick") end
  elseif side==active then active=3-active sfx("tick") end
end
function on_chord(c)
  if c=="ne" then if active==0 then t={total,total} sfx("back") else active=0 lab() sfx("tick") end
  elseif c=="se" then t={total,total} active=0 over=0 lab() sfx("back") end
end
function update(dt)
  if active>0 then
    t[active]=t[active]-dt
    if t[active]<=0 then t[active]=0 over=active active=0 play("a5:16 r:16 a5:16 r:16 a5:8",170,false) lab() end
  end
end
local function fmt(s) s=math.max(0,math.ceil(s)) return string.format("%d:%02d",s//60,s%60) end
function draw()
  clear() decor()
  for i=1,2 do
    local cy=(i==1) and 80 or 240
    local rot=(i==1) and 180 or 0
    local on=(active==i)
    local col=on and C.accent or C.fg
    if over==i then col=C.bad end
    rect(X0,cy-34,CW,68,on and C.panel or C.bg,14)
    if on then frame(X0,cy-34,CW,68,C.accent,14,3) end
    text(fmt(t[i]),W//2,cy,col,40,CENTER,rot)
  end
  text(over>0 and "tempo esgotado" or (active==0 and "toque no seu lado para começar" or ""),W//2,160,C.mute,11,CENTER)
end
