-- name: Placar
-- icon: .....ff.....f/....f..f.../...f....f.../....f..f..../.....ff...../.ff.......ff./f..f.....f..f/f..f.....f..f/.ff.......ff./.....ff...../....f..f..../.....ff.....
-- orient: fixed
-- Um jogador por lado do cubo. Cada número fica virado para o seu jogador.
local sc={0,0,0,0}   -- up, right, down, left
local mode=1           -- 1 = +1, 2 = -1, 3 = zerar jogador
local SIDE={"up","right","down","left"}
local POS={{120,78,180},{192,160,-90},{120,250,0},{48,160,90}}
local COL={"accent","ok","warn","bad"}
local MN={"+1","-1","Zerar"}
local function lab() local m=MN[mode] labels(m,m,m,m,"Modo "..MN[mode%3+1]) end
function on_enter() local s=recall("p","") if s~="" then local i=1 for v in s:gmatch("-?%d+") do sc[i]=tonumber(v) i=i+1 end end repeat_pads("") lab() end
local function store() save("p",table.concat(sc,",")) end
function on_pad(d,n)
  if d=="ok" then mode=mode%3+1 sfx("tick") lab() return end
  for i,k in ipairs(SIDE) do
    if k==d then
      if mode==3 then sc[i]=0 sfx("back")
      else sc[i]=clamp(sc[i]+(mode==2 and -1 or 1),-99,999) sfx(mode==2 and "back" or "tick") end
      store()
    end
  end
end
function draw()
  clear() decor()
  for i,p in ipairs(POS) do
    text(sc[i],p[1],p[2],C[COL[i]],40,CENTER,p[3])
  end
  rect(W//2-26,H//2-13,52,26,C.panel,13)
  text(mode==1 and "+1" or (mode==2 and "−1" or "0"),W//2,H//2,mode==2 and C.bad or (mode==3 and C.warn or C.ok),16,CENTER,0)
end
