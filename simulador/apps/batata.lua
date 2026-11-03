-- name: Batata quente
-- icon: ............/............/....kkkkk...../...krrrrrk..../..krrrrrrrk.../..krrrrrrrk.../..krrrrrrrk.../...krrrrrk..../....kkkkk...../............/............/............
-- store: 1
-- Passe o cubo de mão em mão. Quem estiver com ele quando estourar, perde.
local state="idle"
local total,left=0,0
local nt=0
local boom=0
local function lab() if state=="run" then labels("Passar","Passar","Passar","Passar","") else labels("","","","","Iniciar") end end
function on_enter() repeat_pads("") lab() end
local function start() state="run" total=math.random(8,25) left=total nt=0 boom=0 sfx("confirm") lab() end
function on_pad(d) if state=="idle" or state=="done" then if d=="ok" then start() end elseif state=="run" then sfx("shake") end end
function on_shake() if state=="run" then sfx("shake") end end
function update(dt)
  if state=="run" then
    left=left-dt nt=nt-dt
    if nt<=0 then nt=math.max(0.1,0.7*left/total+0.1) sfx("tick") end
    if left<=0 then state="done" boom=0 sfx("thunk") play("c2:8 g1:4",120,false,"sawtooth") lab() end
  elseif state=="done" then boom=boom+dt end
end
function draw()
  local hot=state=="run" and 1-left/total or 0
  clear(state=="done" and (math.floor(boom*6)%2==0 and C.bad or C.bg) or C.bg)
  if state~="done" then decor() end
  text("Batata quente",W//2,34,C.fg,20,CENTER)
  local r=50+math.floor(hot*26)+((state=="run") and math.floor(math.sin(left*(6+hot*30))*3) or 0)
  circle(W//2,160,r,state=="done" and C.warn or (hot>0.66 and C.bad or (hot>0.33 and C.warn or C.accent)))
  ring(W//2,160,r,C.fg,3)
  if state=="idle" then text("toque em Iniciar",W//2,150,C.bg,14,CENTER)
  elseif state=="run" then text("passa!",W//2,148,C.bg,22,CENTER)
  else text("BUM!",W//2,140,C.fg,34,CENTER) end
  text(state=="done" and "quem estava com ele perdeu" or "tempo escondido",W//2,262,C.mute,12,CENTER)
end
