-- name: Narrador
-- icon: ............/....ffff..../..ff....ff../.f..aa....f./.f.aaaa...f./f..aaaa....f/f...aa.....f/.f........f./.f........f./..ff....ff../....ffff..../............
-- layout: both
-- Sorteia quem narra e conta o tempo para pensar na pista (DEMONSTRAÇÃO).
local COL={rgb(0xD6,0x45,0x45),rgb(0x3E,0x7A,0xA7),rgb(0x4F,0xA7,0x60),rgb(0xF2,0xC2,0x30),rgb(0xD9,0x6B,0xB0),rgb(0xEC,0x66,0x3B)}
local NAME={"Vermelho","Azul","Verde","Amarelo","Rosa","Laranja"}
local WHITE=rgb(255,255,255)
local n=4
local phase="setup"   -- setup, spin, picked, timing, done
local cur,target,steps,stepi,wait,acc=1,1,0,0,0.05,0
local tlen,tleft=60,60
local flash=0
local function lab()
  if phase=="setup" then labels("","","@minus Jogadores","@plus Jogadores","Sortear")
  elseif phase=="picked" then labels("@plus 15 s","@minus 15 s","@reset Sortear","","@play Iniciar tempo")
  elseif phase=="timing" then labels("","","Parar","","Pausar")
  elseif phase=="paused" then labels("","","Parar","","Seguir")
  elseif phase=="done" then labels("","","","","@reset Novo")
  else labels("","","","","") end
  repeat_pads("")
end
function on_enter() lab() end
local function spin()
  target=math.random(1,n)
  steps=n*3+((target-cur)%n)
  stepi=0 wait=0.05 acc=0 phase="spin" sfx("roll") lab()
end
function on_pad(d)
  if phase=="setup" then
    if d=="left" then n=math.max(3,n-1) sfx("tick") elseif d=="right" then n=math.min(6,n+1) sfx("tick") elseif d=="ok" then spin() end
  elseif phase=="picked" then
    if d=="up" then tlen=math.min(180,tlen+15) tleft=tlen sfx("tick")
    elseif d=="down" then tlen=math.max(15,tlen-15) tleft=tlen sfx("tick")
    elseif d=="left" then spin()
    elseif d=="ok" then tleft=tlen phase="timing" sfx("confirm") lab() end
  elseif phase=="timing" then
    if d=="ok" then phase="paused" sfx("tick") lab() elseif d=="left" then phase="picked" tleft=tlen sfx("back") lab() end
  elseif phase=="paused" then
    if d=="ok" then phase="timing" sfx("tick") lab() elseif d=="left" then phase="picked" tleft=tlen sfx("back") lab() end
  elseif phase=="done" then
    if d=="ok" then stop_sound() phase="setup" sfx("back") lab() end
  end
end
function on_shake() if phase=="setup" then spin() end end
function update(dt)
  if phase=="spin" then
    acc=acc+dt
    if acc>=wait then
      acc=0 stepi=stepi+1 cur=cur%n+1 sfx("tick")
      wait=0.05+0.28*(stepi/steps)^3
      if stepi>=steps then cur=target phase="picked" tleft=tlen sfx("win") lab() end
    end
  elseif phase=="timing" then
    tleft=tleft-dt
    if tleft<=0 then tleft=0 phase="done" flash=0 play("a5:16 r:16 a5:16 r:16 a5:16 r:16 a5:8",170,true) lab() end
  elseif phase=="done" then flash=flash+dt end
end
local function fmt(s) s=math.max(0,math.ceil(s)) return string.format("%d:%02d",s//60,s%60) end
function draw()
  clear() decor()
  local P=portrait()
  local cx,cy,R,rx
  if P then
    text("Quem narra?",W//2,32,C.mute,14,CENTER)
    cx,cy,R=W//2,130,58
  else
    text("Quem narra?",X0+CW//2,Y0+2,C.mute,14,CENTER)
    cx,cy,R,rx=X0+72,Y0+100,50,X0+209
  end
  for p=1,n do
    local a=math.rad(-90+(p-1)*360/n)
    local x,y=cx+math.cos(a)*R,cy+math.sin(a)*R
    local on=(p==cur) and phase~="setup"
    if on then circle(x,y,20,C.fg) end
    circle(x,y,on and 16 or 12,COL[p])
  end
  local late=(phase=="done") and (math.floor(flash*3)%2==0)
  if P then
    if phase=="setup" then
      numtext(n,cx,cy,C.fg,36)
      text("jogadores · OK sorteia",W//2,222,C.mute,12,CENTER)
    elseif phase=="spin" then
      text("sorteando...",W//2,222,C.mute,14,CENTER)
    else
      rect(X0,208,CW,54,COL[cur],14)
      text("narrador",W//2,214,WHITE,10,CENTER)
      text(NAME[cur],W//2,228,WHITE,22,CENTER)
      text(phase=="done" and "hora de escolher a carta!" or (fmt(tleft).."  para a pista"),W//2,274,late and C.bad or C.accent,phase=="done" and 12 or 16,CENTER)
    end
  else
    if phase=="setup" then
      numtext(n,cx,cy,C.fg,36)
      text("jogadores",rx,Y0+70,C.mute,12,CENTER)
      text("OK sorteia",rx,Y0+90,C.mute,12,CENTER)
    elseif phase=="spin" then
      text("sorteando...",rx,Y0+80,C.mute,14,CENTER)
    else
      rect(rx-59,Y0+30,118,54,COL[cur],14)
      text("narrador",rx,Y0+36,WHITE,10,CENTER)
      text(NAME[cur],rx,Y0+50,WHITE,20,CENTER)
      if phase=="done" then
        text("hora de escolher",rx,Y0+104,late and C.bad or C.accent,12,CENTER)
        text("a carta!",rx,Y0+120,late and C.bad or C.accent,12,CENTER)
      else
        text(fmt(tleft),rx,Y0+102,C.accent,24,CENTER)
        text("para a pista",rx,Y0+130,C.mute,11,CENTER)
      end
    end
  end
end
