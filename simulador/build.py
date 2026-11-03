#!/usr/bin/env python3
"""Monta o simulador: shell.html + sys/*.lua + apps/*.lua -> arquivo único.
uso: python3 build.py <url-ou-caminho-do-fengari> <saida.html>"""
import sys,glob,os,re,html
fen,out=sys.argv[1],sys.argv[2]
d=os.path.dirname(os.path.abspath(__file__))
blocks=[]
for f in sorted(glob.glob(d+'/sys/*.lua')):
    n=os.path.basename(f)[:-4]
    blocks.append(f'<script type="text/x-lua" id="sys-{n}">\n{open(f).read()}</script>')
order=['dice','bandeja','timer','cronometro','poke','placar','quem','pet','batata','reflexo']
files={os.path.basename(f)[:-4]:f for f in glob.glob(d+'/apps/*.lua')}
for n in order+[k for k in files if k not in order]:
    if n not in files: continue
    src=open(files[n]).read()
    meta=dict(re.findall(r'^-- (\w+): (.*)$',src,re.M))
    a=f'data-name="{html.escape(meta["name"])}" data-icon="{meta["icon"]}"'
    if meta.get('store'): a+=' data-store="1"'
    if meta.get('desc'): a+=f' data-desc="{html.escape(meta["desc"])}"'
    blocks.append(f'<script type="text/x-lua" id="app-{n}" {a}>\n{src}</script>')
import json
for pd in sorted(glob.glob(d+'/packs/*/'),key=lambda x:(['futebol','debater','double'].index(os.path.basename(x.rstrip('/'))) if os.path.basename(x.rstrip('/')) in ['futebol','debater','double'] else 99)):
    pid=os.path.basename(pd.rstrip('/'))
    meta=dict(re.findall(r'^(\w+): (.*)$',open(pd+'pack.txt').read(),re.M))
    p={'name':meta['name'],'icon':meta['icon'],'desc':meta.get('desc',''),'uses':[u.strip() for u in meta.get('uses','').split(',') if u.strip()],'micros':[],'slides':''}
    if 'skin' in meta: p['skin']=int(meta['skin'])
    for f in sorted(glob.glob(pd+'*.lua')):
        src=open(f).read(); m=dict(re.findall(r'^-- (\w+): (.*)$',src,re.M))
        p['micros'].append({'name':m['name'],'icon':m['icon'],'src':src})
    if os.path.exists(pd+'regras.txt'): p['slides']=open(pd+'regras.txt').read()
    js=json.dumps(p,ensure_ascii=False).replace('</','<\\/')
    blocks.append(f'<script type="application/json" id="pack-{pid}">{js}</script>')
s=open(d+'/shell.html').read().replace('<!--LUA-->','\n'.join(blocks))
if os.path.isfile(fen) and out.endswith('standalone.html'):
    js=open(fen).read(); assert '</script' not in js
    s=s.replace('<script src="__FENGARI__"></script>','<script>'+js+'</script>')
else:
    s=s.replace('__FENGARI__',fen)
open(out,'w').write(s)
print('ok',len(s),'bytes',len(blocks),'blocos')
