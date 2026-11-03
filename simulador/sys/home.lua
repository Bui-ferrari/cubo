local sel=1
local t=0
local shake_t=0
local function icon_rows(i)
  local rows={}
  for r in _app_icon(i):gmatch("[^/]+") do rows[#rows+1]=r end
  return rows
end
function on_enter()
  refresh_colors()
  if sel>_app_count() then sel=1 end
  labels("Ajustes","Loja","Anterior","Próximo","Abrir") repeat_pads("")
end
function on_pad(d)
  local n=_app_count()
  if d=="left" then sel=(sel-2)%n+1 sfx("tick")
  elseif d=="right" then sel=sel%n+1 sfx("tick")
  elseif d=="ok" then sfx("confirm") _launch(sel)
  elseif d=="up" then sfx("tick") _launch_settings()
  elseif d=="down" then sfx("tick") _launch_store() end
end
function on_shake() shake_t=1.3 sfx("shake") end
function update(dt) t=t+dt if shake_t>0 then shake_t=shake_t-dt end end
function draw()
  clear()
  decor()
  -- rosto
  local look=math.floor(math.sin(t*0.9)*4)
  local blink=(math.floor(t*10)%36)==0
  if shake_t>0 then
    line(62,52,84,74,C.fg,5) line(84,52,62,74,C.fg,5)
    line(156,52,178,74,C.fg,5) line(178,52,156,74,C.fg,5)
    arc(120,100,10,0,360,C.fg,4)
  else
    if blink then rect(62,62,22,4,C.fg,2) rect(156,62,22,4,C.fg,2)
    else
      rect(62,46,22,30,C.fg,10) rect(156,46,22,30,C.fg,10)
      rect(68+look,52,8,8,C.bg,4) rect(162+look,52,8,8,C.bg,4)
    end
    arc(120,88,14,20,160,C.fg,5)
  end
  -- cartão do app
  local n=_app_count()
  rect(72,132,96,100,C.mute,18)
  rect(72,128,96,100,C.panel,18)
  frame(72,128,96,100,C.accent,18,3)
  pixels(84,140,6,icon_rows(sel))
  text(_app_name(sel),W//2,242,C.fg,20,CENTER)
  for i=1,n do
    local x=W//2-(n*14)//2+(i-1)*14+7
    circle(x,278,i==sel and 4 or 3,i==sel and C.accent or C.mute)
  end
end
