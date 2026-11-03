-- name: Tempo de jogo
-- icon: ....ffff..../..ff....ff../.f...a....f./.f...a....f./f....a.....f/f....aaa...f/f..........f/.f........f./.f........f./..ff....ff../....ffff..../............
local DUR={20,30}
local di=1
local state="set"   -- set, run, pause, done
local left=20*60
local flash=0
local function fmt(s) s=math.max(0,math.ceil(s)) return string.format("%02d:%02d",s//60,s%60) end
local function set_labels()
  if state=="set" then labels("","","Tempo -","Tempo +","Iniciar")
  elseif state=="run" then labels("","Zerar","","","Pausar")
  elseif state=="pause" then labels("","Zerar","","","Seguir")
  else labels("","","","","OK") end
  repeat_pads("")
end
local function reset() state="set" left=DUR[di]*60 stop_sound() set_labels() end
function on_enter() reset() end
local function go() state="run" sfx("confirm") set_labels() end
function on_pad(d)
  if state=="done" then reset() sfx("back") return end
  if d=="ok" then
    if state=="set" then go() elseif state=="run" then state="pause" sfx("tick") set_labels() else state="run" sfx("tick") set_labels() end
  elseif d=="down" then if state~="set" then reset() sfx("back") end
  elseif state=="set" and (d=="right" or d=="left") then di=di%#DUR+1 left=DUR[di]*60 sfx("tick") end
end
function update(dt)
  if state=="run" then left=left-dt if left<=0 then state="done" flash=0 play("a5:16 r:16 a5:16 r:16 a5:16 r:16 a5:8",170,true) set_labels() end
  elseif state=="done" then flash=flash+dt end
end
function draw()
  local bg=C.bg
  if state=="done" and math.floor(flash*3)%2==0 then bg=C.accent end
  clear(bg) if bg==C.bg then decor() end
  text("Tempo de jogo",W//2,34,C.mute,14,CENTER)
  text(fmt(left),W//2,110,C.fg,56,CENTER)
  text(state=="set" and (DUR[di].." minutos") or (state=="run" and "valendo" or (state=="pause" and "em pausa" or "apito final!")),W//2,190,state=="done" and C.fg or C.accent,16,CENTER)
end
