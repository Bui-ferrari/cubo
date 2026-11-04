-- layout: both
-- Menu de um jogo instalado: mesmos gestos do Menu principal
local sel=1
local t=0
local function rows(i)
  local r={}
  for x in _pk_icon(i):gmatch("[^/]+") do r[#r+1]=x end
  return r
end
function on_enter() refresh_colors() labels("","","Anterior","Próximo","Abrir") repeat_pads("") end
function on_pad(d)
  local n=_pk_count()
  if d=="left" then sel=(sel-2)%n+1 sfx("tick")
  elseif d=="right" then sel=sel%n+1 sfx("tick")
  elseif d=="ok" then sfx("confirm") _pk_launch(sel) end
end
function update(dt) t=t+dt end
function draw()
  clear() decor()
  local land=landscape()
  text(_pk_title(),W//2,land and 30 or 38,C.fg,18,CENTER)
  text(_pk_desc(),W//2,land and 54 or 64,C.mute,11,CENTER)
  local n=_pk_count()
  local cx,cy=W//2,96
  if land then cx,cy=W//4+4,78 end
  rect(cx-48,cy+4,96,100,C.mute,18)
  rect(cx-48,cy,96,100,C.panel,18)
  frame(cx-48,cy,96,100,C.accent,18,3)
  pixels(cx-36,cy+12,6,rows(sel))
  if land then
    local nx=cx+66
    local lines=wrap(_pk_name(sel),18,X1-nx)
    for k,l in ipairs(lines) do if k<=3 then text(l,nx,cy+8+(k-1)*24,C.fg,18,LEFT) end end
    for i=1,n do circle(nx+4+(i-1)*14,cy+92,i==sel and 4 or 3,i==sel and C.accent or C.mute) end
    text("Voltar: Menu",W//2,196,C.mute,10,CENTER)
  else
    text(_pk_name(sel),W//2,212,C.fg,20,CENTER)
    for i=1,n do
      local x=W//2-(n*14)//2+(i-1)*14+7
      circle(x,254,i==sel and 4 or 3,i==sel and C.accent or C.mute)
    end
    text("Voltar: Menu",W//2,276,C.mute,10,CENTER)
  end
end
