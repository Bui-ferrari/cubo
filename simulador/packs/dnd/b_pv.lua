-- name: Pontos de vida
-- icon: ............/..ff..ff..../.fWWffWWf.../.fWWWWWWf.../.fWWWWWWf.../..fWWWWf..../...fWWf...../....ff....../............/............/............/............
-- Conta os pontos de vida do herói. Dano e cura em passos de 1 e 5. Fica salvo.
local hp=tonumber(recall("pv",20)) or 20
local mx=tonumber(recall("pvmax",20)) or 20
local edit=false
local flash,fcol=0,nil
local function lab()
  if edit then labels("@plus Máx +5","@minus Máx -5","@minus Máx","@plus Máx","@ok Pronto") repeat_pads("left right")
  else labels("@plus Cura 5","@minus Dano 5","@minus Dano 1","@plus Cura 1","Máximo") repeat_pads("left right") end
end
function on_enter() lab() end
local function save_hp() save("pv",hp) save("pvmax",mx) end
local function change(k)
  local old=hp
  hp=clamp(hp+k,0,mx)
  if hp~=old then flash=0.4 fcol=(k<0) and C.bad or C.ok sfx(k<0 and "back" or "tick") if hp==0 then sfx("thunk") end else sfx("tick") end
  save_hp()
end
function on_pad(d)
  if edit then
    local k=(d=="up" and 5) or (d=="down" and -5) or (d=="right" and 1) or (d=="left" and -1) or 0
    if d=="ok" then edit=false hp=clamp(hp,0,mx) save_hp() sfx("confirm") lab() return end
    mx=clamp(mx+k,1,999) sfx("tick")
  else
    if d=="up" then change(5) elseif d=="down" then change(-5)
    elseif d=="left" then change(-1) elseif d=="right" then change(1)
    elseif d=="ok" then edit=true sfx("tick") lab() end
  end
end
function on_shake() end
function update(dt) if flash>0 then flash=flash-dt end end
function draw()
  clear() decor()
  local frac=mx>0 and hp/mx or 0
  local col=(hp==0) and C.bad or (frac>0.5 and C.ok or (frac>0.25 and C.warn or C.bad))
  text(edit and "Máximo de PV" or "Pontos de vida",W//2,34,C.mute,14,CENTER)
  local jit=flash>0 and math.random(-2,2) or 0
  numtext(edit and mx or hp,W//2+jit,128,flash>0 and fcol or ((hp==0 and not edit) and C.bad or C.fg),72)
  if not edit then
    text("de "..mx,W//2,178,C.mute,16,CENTER)
    local bw=CW-20
    rect(X0+10,206,bw,22,C.panel,10)
    if hp>0 then rect(X0+10,206,math.max(10,math.floor(bw*frac)),22,col,10) end
    frame(X0+10,206,bw,22,C.fg,10,2)
    local st=(hp==0) and "CAÍDO" or (frac<=0.5 and "ferido" or "em forma")
    text(st,W//2,244,col,16,CENTER)
  else
    text("pad cima/baixo: passos de 5",W//2,200,C.mute,11,CENTER)
    text("laterais: passos de 1",W//2,218,C.mute,11,CENTER)
  end
end
