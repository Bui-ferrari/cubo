-- name: Tempo de turno
-- icon: ....ffff..../..ff....ff../.f...a....f./.f...a....f./f....a.....f/f....aaa...f/f..........f/.f........f./.f........f./..ff....ff../....ffff..../............
-- Cronômetro de turno opcional, com a cor do jogador da vez e contagem de rodadas.
local NAMES={"Vermelho","Azul","Laranja","Branco"}
local COLS={rgb(0xD6,0x45,0x45),rgb(0x3E,0x7A,0xA7),rgb(0xEC,0x66,0x3B),rgb(0xF4,0xEE,0xE4)}
local dur=tonumber(recall("cat_dur",90)) or 90
local left=dur
local state="set"     -- set, run, pause, done
local cur,rnd=1,1
local fl,lt=0,0
local function lab()
  local okl=(state=="run") and "Pausar" or ((state=="pause") and "Continuar" or ((state=="done") and "" or "Iniciar"))
  if state=="set" then labels("Próximo jogador","@reset Zerar","@minus 15 s","@plus 15 s",okl) repeat_pads("left right")
  else labels("Próximo jogador","@reset Zerar","","",okl) repeat_pads("") end
end
function on_enter() lab() end
local function nextp()
  cur=cur%4+1 if cur==1 then rnd=rnd+1 end
  left=dur state="set" stop_sound() lab()
end
function on_pad(p)
  if p=="up" then nextp() sfx("tick")
  elseif p=="down" then left=dur state="set" stop_sound() lab() sfx("back")
  elseif p=="left" and state=="set" then dur=clamp(dur-15,15,600) left=dur save("cat_dur",dur) sfx("tick")
  elseif p=="right" and state=="set" then dur=clamp(dur+15,15,600) left=dur save("cat_dur",dur) sfx("tick")
  elseif p=="ok" then
    if state=="set" or state=="pause" then state="run" sfx("confirm")
    elseif state=="run" then state="pause" sfx("tick") end
    lab()
  end
end
function update(dt)
  if state=="run" then
    local b=math.ceil(left)
    left=left-dt
    if math.ceil(left)~=b and left<=10 and left>0 then sfx("tick") end
    if left<=0 then left=0 state="done" fl=0 play("a5:16 r:16 a5:16 r:16 a5:8",170,false) lab() end
  elseif state=="done" then fl=fl+dt end
end
local function fmt(s) s=math.max(0,math.ceil(s)) return string.format("%d:%02d",s//60,s%60) end
function draw()
  clear() decor()
  local fg=(cur==4) and C.fg or rgb(255,255,255)
  rect(X0,30,CW,40,COLS[cur],14)
  text(NAMES[cur],W//2,40,fg,20,CENTER)
  local cx,cy,r=W//2,176,78
  ring(cx,cy,r,C.panel,10)
  local frac=(dur>0) and (left/dur) or 0
  local urgent=(left<=10 and state~="set")
  local col=urgent and C.bad or COLS[cur]
  if cur==4 then col=urgent and C.bad or C.mute end
  if frac>0.005 then arc(cx,cy,r,-90,-90+360*frac,col,10) end
  local blink=(state=="done" and math.floor(fl*3)%2==0)
  text(fmt(left),cx,cy-22,blink and C.bad or C.fg,44,CENTER)
  local st=({set="toque em Iniciar",run="valendo",pause="em pausa",done="tempo!"})[state]
  text(st,cx,cy+30,urgent and C.bad or C.mute,12,CENTER)
  text("rodada "..rnd,W//2,cy+r+10,C.mute,11,CENTER)
end
