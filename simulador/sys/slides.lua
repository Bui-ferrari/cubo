-- layout: both
-- Regras em slides, passo a passo, com leitura em voz alta
local i=1
local reading=false
local function lab() labels("","Parar","Anterior","Próximo","Ler") end
function on_enter() refresh_colors() lab() repeat_pads("") end
local function read() reading=true speak(_sl_title(i)..". ".._sl_text(i)) sfx("tick") end
function on_pad(d)
  local n=_sl_count()
  if d=="right" then if i<n then i=i+1 reading=false speak_stop() sfx("tick") else sfx("back") end
  elseif d=="left" then if i>1 then i=i-1 reading=false speak_stop() sfx("tick") else sfx("back") end
  elseif d=="ok" then read()
  elseif d=="down" then reading=false speak_stop() end
end
function draw()
  clear() decor()
  local land=landscape()
  local n=_sl_count()
  local py,ph,ty,ly,lh,maxl
  if land then py,ph,ty,ly,lh,maxl=46,Y1-46,54,76,16,math.floor((Y1-46-30-6)/16)
  else py,ph,ty,ly,lh,maxl=52,220,64,96,17,10 end
  if land then
    text(i.." / "..n,X0,28,C.mute,12,LEFT)
    for k=1,n do circle(W//2-(n*10)//2+(k-1)*10+5,35,k==i and 3 or 2,k==i and C.accent or C.mute) end
  else
    text(i.." / "..n,W//2,34,C.mute,12,CENTER)
    for k=1,n do circle(W//2-(n*10)//2+(k-1)*10+5,284,k==i and 3 or 2,k==i and C.accent or C.mute) end
  end
  rect(X0,py,CW,ph,C.panel,14)
  text(_sl_title(i),W//2,ty,C.accent,land and 16 or 18,CENTER)
  local lines=wrap(_sl_text(i),13,CW-24)
  for k,l in ipairs(lines) do if k<=maxl then text(l,X0+12,ly+(k-1)*lh,C.fg,13,LEFT) end end
  if reading then text("lendo...",X1-6,land and 28 or 34,C.accent,11,RIGHT) end
end
