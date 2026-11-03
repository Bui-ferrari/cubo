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
  local n=_sl_count()
  text(i.." / "..n,W//2,34,C.mute,12,CENTER)
  rect(X0,52,CW,220,C.panel,14)
  text(_sl_title(i),W//2,64,C.accent,18,CENTER)
  local lines=wrap(_sl_text(i),13,CW-24)
  for k,l in ipairs(lines) do if k<=10 then text(l,X0+12,96+(k-1)*17,C.fg,13,LEFT) end end
  for k=1,n do
    local x=W//2-(n*10)//2+(k-1)*10+5
    circle(x,284,k==i and 3 or 2,k==i and C.accent or C.mute)
  end
  if reading then text("lendo...",X1-6,34,C.accent,11,RIGHT) end
end
