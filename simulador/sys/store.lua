-- layout: both
-- Wi-Fi e Loja de apps (simulados no navegador)
local sel=1
local t=0
function on_enter() refresh_colors() t=0 end
local function lab()
  local w=_wifi()
  if w=="off" or w=="fail" then labels("","","","","Conectar")
  elseif w=="ready" then labels("Acima","Abaixo","Remover","Instalar","Atualizar")
  else labels("","","","","") end
  repeat_pads("")
end
local last=""
local function toggle() if _store_count()>0 then _store_toggle(sel) sfx(_store_has(sel)==1 and "win" or "back") end end
function on_pad(d)
  local w=_wifi()
  if w=="off" or w=="fail" then if d=="ok" then _wifi_go() sfx("confirm") end return end
  if w~="ready" then return end
  local n=_store_count()
  if d=="up" then sel=(sel-2)%n+1 sfx("tick")
  elseif d=="down" then sel=sel%n+1 sfx("tick")
  elseif d=="right" then if _store_has(sel)==0 then toggle() end
  elseif d=="left" then if _store_has(sel)==1 then toggle() end
  elseif d=="ok" then _wifi_off() _wifi_go() sfx("tick") end
end
function update(dt) t=t+dt local w=_wifi() if w~=last then last=w lab() end end
function draw()
  clear() decor()
  local land=landscape()
  if land then text("Loja",X0,26,C.fg,20,LEFT) else text("Loja",W//2,34,C.fg,24,CENTER) end
  local w=_wifi()
  local mid=H//2
  if w=="off" or w=="fail" then
    text("Wi-Fi desligado",W//2,mid-30,C.fg,18,CENTER)
    text("aperte OK para conectar",W//2,mid,C.mute,12,CENTER)
  elseif w=="scan" or w=="on" or w=="check" then
    local dots=string.rep(".",1+math.floor(t*3)%3)
    local dy=land and -20 or 0
    text(w=="scan" and "Procurando redes" or (w=="on" and "Conectado a Casa-Maker" or "Buscando atualizações"),W//2,mid-40+dy,C.fg,14,CENTER)
    text(dots,W//2,mid-14+dy,C.accent,28,CENTER)
    arc(W//2,mid+50+dy,land and 18 or 22,t*360,t*360+110,C.accent,6)
  else
    if land then text("Casa-Maker · sistema 0.3 em dia",X1,32,C.ok,11,RIGHT)
    else text("Casa-Maker · sistema 0.3 em dia",W//2,58,C.ok,11,CENTER) end
    local n=_store_count()
    local rh=land and 36 or 44
    local top=land and 54 or 76
    local nv=math.floor((Y1-top+(rh-40))/rh)
    nv=math.min(nv,n)
    local first=math.max(1,math.min(sel-nv//2,n-nv+1))
    for k=0,nv-1 do
      local i=first+k
      local y=top+k*rh
      local has=_store_has(i)==1
      rect(X0,y,CW,rh-4,C.panel,10)
      if i==sel then frame(X0,y,CW,rh-4,C.accent,10,3) end
      if land then
        text(_store_name(i),X0+10,y+9,C.fg,14,LEFT)
        text(_store_kind(i)..string.format(" · %.1f KB",_store_size(i)),X0+CW//2+10,y+4,C.mute,10,LEFT)
        text(has and "instalado" or "disponível",X1-10,y+16,has and C.ok or C.accent,10,RIGHT)
      else
        text(_store_name(i),X0+10,y+5,C.fg,14,LEFT)
        text(_store_kind(i)..string.format(" · %.1f KB",_store_size(i)),X0+10,y+24,C.mute,10,LEFT)
        text(has and "instalado" or "disponível",X1-10,y+24,has and C.ok or C.accent,10,RIGHT)
      end
    end
  end
end
function _app_name_store(i) return _store_name(i) end
