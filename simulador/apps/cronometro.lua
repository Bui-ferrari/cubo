-- name: Cronômetro
-- icon: ....ffff..../...f..f..../..ffffffff../.ff...a..ff./.f....a...f./.f....a...f./.f....aaa.f./.f.........f./.ff.......ff./..ffffffff../............/............
-- layout: both
local t=0
local run=false
local laps={}
local function fmt(x) local m=math.floor(x/60) local s=math.floor(x%60) local c=math.floor((x*100)%100) return string.format("%02d:%02d.%02d",m,s,c) end
local function lab()
  labels("",run and "" or "Zerar","","Volta",run and "Pausar" or "Iniciar")
end
function on_enter() repeat_pads("") lab() end
function on_pad(d)
  if d=="ok" then run=not run sfx(run and "confirm" or "tick") lab()
  elseif d=="right" then if run then table.insert(laps,1,t) if #laps>4 then laps[5]=nil end sfx("tick") end
  elseif d=="down" then if not run then t=0 laps={} sfx("back") end end
end
function on_shake() if run then table.insert(laps,1,t) if #laps>4 then laps[5]=nil end sfx("tick") end end
function update(dt) if run then t=t+dt end end
function draw()
  clear() decor()
  if portrait() then
    text("Cronômetro",W//2,34,C.mute,14,CENTER)
    text(fmt(t),W//2,76,run and C.accent or C.fg,38,CENTER)
    for i,l in ipairs(laps) do
      local y=130+(i-1)*28
      rect(X0,y,CW,24,C.panel,8)
      text("volta "..(#laps-i+1),X0+10,y+5,C.mute,12,LEFT)
      text(fmt(l),X1-10,y+4,C.fg,14,RIGHT)
    end
    if #laps==0 then text(run and "correndo" or "pronto",W//2,170,C.mute,14,CENTER) end
    text("Volta = pad da direita",W//2,276,C.mute,10,CENTER)
  else
    text(fmt(t),W//2,Y0+4,run and C.accent or C.fg,44,CENTER)
    local cw=(CW-8)//2
    for i,l in ipairs(laps) do
      local c,r=(i-1)%2,(i-1)//2
      local x,y=X0+c*(cw+8),Y0+68+r*32
      rect(x,y,cw,28,C.panel,8)
      text("volta "..(#laps-i+1),x+8,y+8,C.mute,11,LEFT)
      text(fmt(l),x+cw-8,y+7,C.fg,12,RIGHT)
    end
    if #laps==0 then text(run and "correndo" or "pronto",W//2,Y0+90,C.mute,14,CENTER) end
    text("Volta = pad da direita",W//2,Y1-14,C.mute,10,CENTER)
  end
end
