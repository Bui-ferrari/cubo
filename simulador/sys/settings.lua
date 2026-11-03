local ITEMS={"Skin","Rótulos","Inclinar","Volume","Brilho","Wi-Fi","Voltar"}
local sel=1
local SKINS={"Cubo","Criya","PokePlace","Obirô"}
local LAB={"de frente","por jogador"}
function on_enter() refresh_colors() labels("Acima","Mais","Abaixo","Menos","OK") repeat_pads("") end
local function change(dir)
  local k=ITEMS[sel]
  if k=="Skin" then _set("theme",(_get("theme")+dir)%4) refresh_colors() sfx("tick")
  elseif k=="Rótulos" then _set("label",(_get("label")+dir)%2) sfx("tick")
  elseif k=="Inclinar" then _set("tilt",dir>0 and 1 or 0) sfx("tick")
  elseif k=="Volume" then _set("vol",clamp(_get("vol")+dir,0,5)) sfx("confirm")
  elseif k=="Brilho" then _set("bright",clamp(_get("bright")+dir,1,5)) sfx("tick")
  elseif k=="Wi-Fi" and dir>0 then sfx("confirm") _launch_store()
  elseif k=="Voltar" and dir>0 then home()
  else sfx("back") end
end
function on_pad(d)
  if d=="n" then sel=(sel-2)%#ITEMS+1 sfx("tick")
  elseif d=="s" then sel=sel%#ITEMS+1 sfx("tick")
  elseif d=="e" then change(1)
  elseif d=="w" then change(-1) end
end
function on_chord(c) if c=="ne" then change(1) end end
local function value(k)
  if k=="Skin" then return SKINS[_get("theme")+1]
  elseif k=="Rótulos" then return LAB[_get("label")+1]
  elseif k=="Inclinar" then return _get("tilt")==1 and "ligado" or "desligado"
  elseif k=="Volume" then return string.rep("|",_get("vol")).." "..(_get("vol"))
  elseif k=="Brilho" then return string.rep("|",_get("bright")).." "..(_get("bright"))
  elseif k=="Wi-Fi" then local w=_wifi() return (w=="off" or w=="fail") and "desligado" or (w=="ready" and "conectado" or "...")
  else return "" end
end
function draw()
  clear()
  decor()
  text("Ajustes",W//2,34,C.fg,24,CENTER)
  for i,k in ipairs(ITEMS) do
    local y=66+(i-1)*30
    if i==sel then rect(X0,y-4,CW,27,C.panel,10) frame(X0,y-4,CW,27,C.accent,10,3) end
    text(k,X0+10,y+2,C.fg,16,LEFT)
    text(value(k),X1-10,y+4,i==sel and C.accent or C.mute,12,RIGHT)
  end
  
end
