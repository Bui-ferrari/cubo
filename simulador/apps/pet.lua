-- name: Bichinho
-- icon: ............/....bbbb..../..bbbbbbbb../.bbbbbbbbbb./.bbfbbbbfbb./.bbfbbbbfbb./.bbbbbbbbbb./.bbbfbbfbbb./.bbbbffbbbb./..bbbbbbbb../...bb..bb.../............
-- layout: both
local food,joy,energy=70,70,70
local sleeping=false
local t=0
local act,actt="",0
local dizzy=0
local last=0
local PER_MIN=3
local function save_all() save("s",string.format("%d,%d,%d,%d",math.floor(food),math.floor(joy),math.floor(energy),now())) end
local function sleep_labels() labels("Comer",sleeping and "Acordar" or "Dormir","Carinho","Brincar","") end
function on_enter()
  local s=recall("s","")
  last=now()
  if s~="" then
    local a,b,c,tm=s:match("(%d+),(%d+),(%d+),(%d+)")
    if a then
      food,joy,energy=tonumber(a),tonumber(b),tonumber(c)
      local mins=math.min(600,(now()-tonumber(tm))/60)
      food=clamp(food-mins*PER_MIN,0,100) joy=clamp(joy-mins*PER_MIN*0.7,0,100) energy=clamp(energy-mins*PER_MIN*0.5,0,100)
    end
  end
  sleep_labels() repeat_pads("")
end
local function do_act(a) act=a actt=1.1 end
function on_pad(d)
  if d=="up" then food=clamp(food+25,0,100) do_act("eat") sfx("eat")
  elseif d=="right" then if energy>10 then joy=clamp(joy+22,0,100) energy=clamp(energy-12,0,100) do_act("play") sfx("happy") else do_act("tired") sfx("back") end
  elseif d=="down" then sleeping=not sleeping sleep_labels() sfx("tick")
  elseif d=="left" then joy=clamp(joy+10,0,100) do_act("love") sfx("happy") end
  save_all()
end
function on_shake() dizzy=1.5 sfx("shake") end
function update(dt)
  t=t+dt
  if actt>0 then actt=actt-dt end
  if dizzy>0 then dizzy=dizzy-dt end
  local m=dt/60
  if sleeping then energy=clamp(energy+m*PER_MIN*8,0,100) food=clamp(food-m*PER_MIN*0.3,0,100)
  else food=clamp(food-m*PER_MIN,0,100) joy=clamp(joy-m*PER_MIN*0.7,0,100) energy=clamp(energy-m*PER_MIN*0.5,0,100) end
end
local function bar(x,y,bw,label,v,c)
  text(label,x,y,C.mute,10,LEFT)
  rect(x+52,y+1,bw,10,C.panel,5)
  if v>2 then rect(x+52,y+1,math.floor(bw*v/100),10,c,5) end
end
function draw()
  clear(sleeping and C.panel or C.bg)
  decor()
  local mood=(food<25 or joy<25) and "sad" or "ok"
  local bob=math.floor(math.sin(t*3)*3)
  if act=="play" and actt>0 then bob=-math.floor(math.abs(math.sin(actt*9))*18) end
  local port=portrait()
  local px,py
  if port then px,py=W//2-64,86+bob else px,py=X0+8,Y0+34+bob end
  local s=8
  -- corpo 16x13 (pixel art)
  local body={
  "....bbbbbbbb....",
  "..bbbbbbbbbbbb..",
  ".bbbbbbbbbbbbbb.",
  "bbbbbbbbbbbbbbbb",
  "bbbbbbbbbbbbbbbb",
  "bbbbbbbbbbbbbbbb",
  "bbbbbbbbbbbbbbbb",
  "bbbbbbbbbbbbbbbb",
  "bbbbbbbbbbbbbbbb",
  ".bbbbbbbbbbbbbb.",
  "..bbbbbbbbbbbb..",
  "...bb......bb..."}
  pixels(px,py,s,body)
  -- olhos
  local blink=(math.floor(t*10)%38)==0
  if sleeping or blink then
    rect(px+24,py+36,16,4,C.fg,2) rect(px+88,py+36,16,4,C.fg,2)
  elseif dizzy>0 then
    line(px+22,py+28,px+40,py+46,C.fg,4) line(px+40,py+28,px+22,py+46,C.fg,4)
    line(px+86,py+28,px+104,py+46,C.fg,4) line(px+104,py+28,px+86,py+46,C.fg,4)
  elseif mood=="sad" then
    rect(px+24,py+34,16,14,C.fg,6) rect(px+88,py+34,16,14,C.fg,6)
    rect(px+22,py+28,22,6,C.accent2,2) rect(px+84,py+28,22,6,C.accent2,2)
  else
    rect(px+24,py+28,16,20,C.fg,7) rect(px+88,py+28,16,20,C.fg,7)
    rect(px+29,py+31,6,6,C.bg,3) rect(px+93,py+31,6,6,C.bg,3)
  end
  -- boca
  if act=="eat" and actt>0 then circle(px+64,py+62,7+math.floor(math.sin(actt*20)*3),C.fg)
  elseif mood=="sad" and not sleeping then arc(px+64,py+74,12,200,340,C.fg,4)
  else arc(px+64,py+56,12,20,160,C.fg,4) end
  if act=="love" and actt>0 then text("♥",px+112,py-10-math.floor((1.1-actt)*20),C.bad,24,CENTER) end
  if sleeping then text("z Z",px+120,py-14+math.floor(math.sin(t*2)*4),C.mute,20,CENTER) end
  local st=sleeping and "dormindo" or (mood=="sad" and "precisa de carinho" or "tudo bem")
  if port then
    if act=="tired" and actt>0 then text("cansado...",W//2,70,C.mute,12,CENTER) end
    bar(X0+2,210,130,"fome",food,C.warn) bar(X0+2,228,130,"alegria",joy,C.accent) bar(X0+2,246,130,"sono",energy,C.accent2)
    text(st,W//2,270,C.mute,12,CENTER)
  else
    local bx=X0+154
    if act=="tired" and actt>0 then text("cansado...",X0+72,Y0+8,C.mute,12,CENTER) end
    bar(bx,Y0+60,64,"fome",food,C.warn) bar(bx,Y0+84,64,"alegria",joy,C.accent) bar(bx,Y0+108,64,"sono",energy,C.accent2)
    text(st,bx+58,Y0+140,C.mute,12,CENTER)
  end
end
