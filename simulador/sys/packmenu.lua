-- Menu de um jogo instalado: mesmos gestos do Menu principal
local sel=1
local t=0
local function rows(i)
  local r={}
  for x in _pk_icon(i):gmatch("[^/]+") do r[#r+1]=x end
  return r
end
function on_enter() refresh_colors() labels("Abrir","Próximo","","Anterior","OK") repeat_pads("") end
function on_pad(d)
  local n=_pk_count()
  if d=="w" then sel=(sel-2)%n+1 sfx("tick")
  elseif d=="e" then sel=sel%n+1 sfx("tick")
  elseif d=="n" then sfx("confirm") _pk_launch(sel) end
end
function on_chord(c) if c=="ne" then sfx("confirm") _pk_launch(sel) end end
function update(dt) t=t+dt end
function draw()
  clear() decor()
  text(_pk_title(),W//2,38,C.fg,18,CENTER)
  text(_pk_desc(),W//2,64,C.mute,11,CENTER)
  local n=_pk_count()
  rect(72,100,96,100,C.mute,18)
  rect(72,96,96,100,C.panel,18)
  frame(72,96,96,100,C.accent,18,3)
  pixels(84,108,6,rows(sel))
  text(_pk_name(sel),W//2,212,C.fg,20,CENTER)
  for i=1,n do
    local x=W//2-(n*14)//2+(i-1)*14+7
    circle(x,254,i==sel and 4 or 3,i==sel and C.accent or C.mute)
  end
  text("canto NO volta",W//2,276,C.mute,10,CENTER)
end
