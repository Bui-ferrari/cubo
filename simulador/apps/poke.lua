-- name: Dano Pokémon
-- icon: ...ffffff.../..frrrrrrf../.frrrrrrrrf./frrrrrrrrrrf/ffffffffffff/fWWWWffWWWWf/fWWWWWWWWWWf/.fWWWWWWWWf./..fWWWWWWf.../...ffffff.../............/............
-- 0 = ativo, 1..5 = banco (pirâmide 1-2-3)
local dmg={0,0,0,0,0,0}
local sel=1
local SL={
 {x=68,y=34,w=104,h=86,sz=40,name="ATIVO"},
 {x=28,y=128,w=88,h=62,sz=30,name="B1"},{x=124,y=128,w=88,h=62,sz=30,name="B2"},
 {x=28,y=198,w=56,h=56,sz=22,name="B3"},{x=92,y=198,w=56,h=56,sz=22,name="B4"},{x=156,y=198,w=56,h=56,sz=22,name="B5"}}
local function store() save("d",table.concat(dmg,",")) end
function on_enter()
  local s=recall("d","")
  if s~="" then local i=1 for v in s:gmatch("%d+") do dmg[i]=tonumber(v) i=i+1 end end
  labels("Anterior","+10","Próximo","-10","Zerar","","Zerar tudo") repeat_pads("ew")
end
function on_pad(d,n)
  n=n or 1
  if d=="n" then sel=(sel-2)%6+1 sfx("tick")
  elseif d=="s" then sel=sel%6+1 sfx("tick")
  else
    local step=(n>14) and 50 or 10
    dmg[sel]=clamp(dmg[sel]+(d=="e" and step or -step),0,990)
    if n==1 then sfx("tick") end
    store()
  end
end
function on_chord(c)
  if c=="ne" then dmg[sel]=0 store() sfx("back")
  elseif c=="sw" then for i=1,6 do dmg[i]=0 end store() sfx("back") end
end
function draw()
  clear()
  decor()
  for i,s in ipairs(SL) do
    rect(s.x,s.y+3,s.w,s.h,C.mute,12)
    rect(s.x,s.y,s.w,s.h,C.panel,12)
    if i==sel then frame(s.x,s.y,s.w,s.h,C.accent,12,4) end
    text(s.name,s.x+8,s.y+7,i==sel and C.accent or C.mute,10,LEFT)
    text(dmg[i],s.x+s.w//2,s.y+s.h//2-s.sz//2+4,dmg[i]>=100 and C.bad or C.fg,s.sz,CENTER)
  end
  text("dano",W//2,272,C.mute,12,CENTER)
  text("cantos zeram",W//2,284,C.mute,10,CENTER)
end
