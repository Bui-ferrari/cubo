-- layout: both
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
  local land=landscape()
  -- rosto (centro do rosto em fx,fy; desenhado em torno de 120,~65 no formato vertical)
  local fx,fy=W//2,46
  if land then fx,fy=W//4+8,70 end
  local dx,dy=fx-120,fy-46
  local look=math.floor(math.sin(t*0.9)*4)
  local blink=(math.floor(t*10)%36)==0
  if shake_t>0 then
    line(62+dx,52+dy,84+dx,74+dy,C.fg,5) line(84+dx,52+dy,62+dx,74+dy,C.fg,5)
    line(156+dx,52+dy,178+dx,74+dy,C.fg,5) line(178+dx,52+dy,156+dx,74+dy,C.fg,5)
    arc(120+dx,100+dy,10,0,360,C.fg,4)
  else
    if blink then rect(62+dx,62+dy,22,4,C.fg,2) rect(156+dx,62+dy,22,4,C.fg,2)
    else
      rect(62+dx,46+dy,22,30,C.fg,10) rect(156+dx,46+dy,22,30,C.fg,10)
      rect(68+look+dx,52+dy,8,8,C.bg,4) rect(162+look+dx,52+dy,8,8,C.bg,4)
    end
    arc(120+dx,88+dy,14,20,160,C.fg,5)
  end
  -- cartão do app
  local n=_app_count()
  local cx,cy,ny,py=W//2,128,242,278
  if land then cx,cy,ny,py=W*3//4-8,56,162,206 end
  rect(cx-48,cy+4,96,100,C.mute,18)
  rect(cx-48,cy,96,100,C.panel,18)
  frame(cx-48,cy,96,100,C.accent,18,3)
  pixels(cx-36,cy+12,6,icon_rows(sel))
  if land then
    local ls=wrap(_app_name(sel),16,2*(X1-cx))
    for k,l in ipairs(ls) do if k<=2 then text(l,cx,ny+(k-1)*18,C.fg,16,CENTER) end end
  else text(_app_name(sel),cx,ny,C.fg,20,CENTER) end
  for i=1,n do
    local x=cx-(n*14)//2+(i-1)*14+7
    circle(x,py,i==sel and 4 or 3,i==sel and C.accent or C.mute)
  end
end
