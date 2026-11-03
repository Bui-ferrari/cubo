-- name: Timer
-- icon: ....ffff..../..ff....ff../.f...a....f./.f...a....f./f....a.....f/f....aaa...f/f..........f/.f........f./.f........f./..ff....ff../....ffff..../............
local MODES={"Timer","Timer + música","Pomodoro"}
local TENSE="a2:8 a2:8 e3:8 a2:8 a2:8 f3:8 e3:8 d3:8"
local ALARM="a5:16 r:16 a5:16 r:16 a5:16 r:16 a5:8 r:4"
local mode=1
local setsecs,focus=120,25*60
local remaining,total=120,120
local state="set"   -- set, run, pause, done
local phase="foco"
local acc=0
local flash=0
local function fmt(s) s=math.max(0,math.ceil(s)) return string.format("%02d:%02d",s//60,s%60) end
local function goto_set()
  state="set" stop_sound()
  if mode==3 then phase="foco" total=focus remaining=focus else total=setsecs remaining=setsecs end
  labels("Iniciar","+10s","Zerar","-10s","Modo","","") repeat_pads("ew")
end
function on_enter() goto_set() end
local function music() if mode==2 then play(TENSE,150,true,"triangle") end end
local function begin()
  state="run" labels("Pausar","+10s","Zerar","-10s","Pausar","","") sfx("confirm") music()
end
function on_pad(d,n)
  n=n or 1
  if state=="done" then goto_set() sfx("back") return end
  if d=="n" then
    if state=="set" then begin()
    elseif state=="run" then state="pause" stop_sound() labels("Seguir","+10s","Zerar","-10s","Seguir","","") sfx("tick")
    elseif state=="pause" then state="run" labels("Pausar","+10s","Zerar","-10s","Pausar","","") sfx("tick") music() end
  elseif d=="s" then
    goto_set() sfx("back")
  else
    local step=(n>12) and 60 or 10
    if mode==3 and state=="set" then step=60 end
    local delta=(d=="e") and step or -step
    if mode==3 and state=="set" then focus=clamp(focus+delta,60,90*60) total=focus remaining=focus
    elseif state=="set" then setsecs=clamp(setsecs+delta,10,99*60) total=setsecs remaining=setsecs
    else remaining=clamp(remaining+delta,1,99*60) total=math.max(total,remaining) end
    if n==1 then sfx("tick") end
  end
end
local function finish()
  stop_sound()
  if mode==3 and phase=="foco" then
    phase="pausa" total=300 remaining=300 sfx("win") play("c5:8 e5:8 g5:8",170,false)
  elseif mode==3 then
    phase="foco" total=focus remaining=focus sfx("confirm")
  else
    state="done" labels("OK","","","","OK") repeat_pads("") play(ALARM,170,true) flash=0
  end
end
function on_chord(c)
  if c=="ne" then if state=="set" then mode=mode%3+1 sfx("tick") goto_set() else on_pad("n") end end
end
function update(dt)
  if state=="run" then
    remaining=remaining-dt
    if remaining<=0 then finish() end
  elseif state=="done" then flash=flash+dt end
end
function draw()
  local bg=C.bg
  if state=="done" and math.floor(flash*3)%2==0 then bg=C.accent2 end
  clear(bg)
  if bg==C.bg then decor() end
  text(mode==3 and (phase=="foco" and "Pomodoro · foco" or "Pomodoro · pausa") or MODES[mode],W//2,34,C.mute,14,CENTER)
  local cx,cy,r=W//2,160,78
  ring(cx,cy,r,C.panel,10)
  local frac=total>0 and remaining/total or 0
  if state~="done" and frac>0 then arc(cx,cy,r,-90,-90+360*frac,(phase=="pausa") and C.ok or C.accent,10) end
  text(state=="done" and "00:00" or fmt(remaining),cx,cy-22,C.fg,44,CENTER)
  local msg={set="ajuste o tempo",run="correndo",pause="em pausa",done="acabou!"}
  text(msg[state],cx,cy+34,state=="done" and C.accent or C.mute,14,CENTER)
  if mode==2 and state~="done" then text("♪ música tensa",cx,276,C.mute,12,CENTER) end
end
