-- name: Batata quente
-- icon: ............/............/....kkkkk...../...krrrrrk..../..krrrrrrrk.../..krrrrrrrk.../..krrrrrrrk.../...krrrrrk..../....kkkkk...../............/............/............
-- layout: both
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
  local port=portrait()
  local cx,cy
  if port then cx,cy=W//2,160 else cx,cy=X0+104,Y0+CH//2+4 end
  if port then text("Batata quente",W//2,34,C.fg,20,CENTER)
  else text("Batata quente",X1-66,Y0+4,C.fg,16,CENTER) end
  local r=50+math.floor(hot*26)+((state=="run") and math.floor(math.sin(left*(6+hot*30))*3) or 0)
  circle(cx,cy,r,state=="done" and C.warn or (hot>0.66 and C.bad or (hot>0.33 and C.warn or C.accent)))
  ring(cx,cy,r,C.fg,3)
  if state=="idle" then text("toque em Iniciar",cx,cy-10,C.bg,14,CENTER)
  elseif state=="run" then text("passa!",cx,cy-12,C.bg,22,CENTER)
  else text("BUM!",cx,cy-20,C.fg,34,CENTER) end
  local foot=state=="done" and "quem estava com ele perdeu" or "tempo escondido"
  if port then text(foot,W//2,262,C.mute,12,CENTER)
  else
    if state=="done" then text("quem estava com",X1-66,Y0+96,C.mute,12,CENTER) text("ele perdeu",X1-66,Y0+112,C.mute,12,CENTER)
    else text(foot,X1-66,Y0+104,C.mute,12,CENTER) end
  end
end
