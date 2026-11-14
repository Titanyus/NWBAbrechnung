/* Local, dependency-free import. Input is the rendered browser export, not an inferred redesign. */
figma.showUI(__html__, {width: 440, height: 330});
const fonts=new Map();let palette=[],styles={};
function color(value) {
  if(!value || value==='transparent')return null;
  let parts,alpha=1;
  if(value.startsWith('#')) {let v=value.slice(1);if(v.length===3)v=v.split('').map(x=>x+x).join('');parts=[0,2,4].map(i=>parseInt(v.slice(i,i+2),16)/255);}
  else {const m=value.match(/^rgba?\(([^)]+)\)/);if(!m)return null;const p=m[1].split(/[,\s/]+/).filter(Boolean).map(Number);parts=p.slice(0,3).map(x=>x/255);alpha=p[3]===undefined?1:p[3];}
  if(!parts.every(Number.isFinite)||!alpha)return null;return {color:{r:parts[0],g:parts[1],b:parts[2]},alpha};
}
function paint(value) {
  const c=color(value);if(!c)return [];
  let p={type:'SOLID',color:c.color,opacity:c.alpha};
  const binding=palette.find(v=>Math.abs(v.rgb.r-c.color.r)+Math.abs(v.rgb.g-c.color.g)+Math.abs(v.rgb.b-c.color.b)<0.003);
  if(binding)p=figma.variables.setBoundVariableForPaint(p,'color',binding.variable);
  return [p];
}
async function font(weight=400) {
  const bold=weight>=600,key=bold?'bold':'regular';
  if(!fonts.has(key))fonts.set(key,(async()=>{
    for(const family of ['Inter','Arial','Noto Sans'])for(const style of (bold?['Bold','Semi Bold','Regular']:['Regular']))try {const f={family,style};await figma.loadFontAsync(f);return f;}catch(_){}
    throw Error('Keine unterstützte Schrift (Inter, Arial, Noto Sans) verfügbar.');
  })());
  return fonts.get(key);
}
async function text(parent,source,origin) {
  const n=figma.createText();parent.appendChild(n);n.fontName=await font(source.font.weight);
  n.characters=source.text;n.fontSize=source.font.size;n.lineHeight={unit:'PIXELS',value:source.font.lineHeight};
  n.fills=paint(source.font.color);n.textAutoResize='WIDTH_AND_HEIGHT';
  n.x=source.x-origin.x;n.y=source.y-origin.y;n.name=source.name;
  // Keep browser lines separate; preserve editable characters without a raster image.
  if(source.width>0)n.resize(Math.max(source.width,n.width),n.height);
  const key=source.font.size===24?'Seitentitel':source.font.size===18?'Abschnitt':source.font.size===12?'Hinweis':'Grundschrift';
  n.setPluginData('nwb-text-style',key);return n;
}
async function render(parent,s,origin) {
  if(s.tag==='text')return text(parent,s,origin);
  if(s.svg) {try {const n=figma.createNodeFromSvg(s.svg.replace(/currentColor/g,s.color));parent.appendChild(n);n.name=s.name;n.x=s.x-origin.x;n.y=s.y-origin.y;n.resize(s.width,s.height);return n;}catch(_){} }
  const n=figma.createFrame();parent.appendChild(n);n.name=s.name;n.x=s.x-origin.x;n.y=s.y-origin.y;
  n.resize(Math.max(.01,s.width),Math.max(.01,s.height));n.fills=paint(s.fill);n.clipsContent=!!s.clip;n.opacity=s.opacity===undefined?1:s.opacity;n.cornerRadius=Math.min(s.radius||0,s.width/2,s.height/2);
  n.setPluginData('nwb-css',JSON.stringify(s.definition||{}));n.setPluginData('nwb-tag',s.tag);
  const edges=s.borders||[];
  if(edges.some(e=>e.width && color(e.color))) {
    if(edges.every(e=>e.width===edges[0].width && e.color===edges[0].color)) {n.strokes=paint(edges[0].color);n.strokeWeight=edges[0].width;n.strokeAlign='INSIDE';}
    else for(let i=0;i<edges.length;i++)if(edges[i].width && color(edges[i].color)) {const edge=figma.createRectangle();n.appendChild(edge);edge.name='Rahmen '+['oben','rechts','unten','links'][i];edge.fills=paint(edges[i].color);edge.resize(i%2?edges[i].width:s.width,i%2?s.height:edges[i].width);edge.x=i===1?s.width-edges[i].width:0;edge.y=i===2?s.height-edges[i].width:0;}
  }
  if(s.checked) {const t={tag:'text',name:'Ausgewählt',text:'✓',x:s.x+1,y:s.y,width:s.width,height:s.height,font:{size:12,weight:600,lineHeight:16,color:s.color}};await text(n,t,s);}
  for(const child of s.children||[])await render(n,child,s);
  if(s.tag==='select') {const arrow=figma.createPolygon();n.appendChild(arrow);arrow.name='Auswahlpfeil';arrow.pointCount=3;arrow.resize(8,5);arrow.rotation=180;arrow.x=s.width-12;arrow.y=s.height/2+2;arrow.fills=paint(s.color);}
  return n;
}
async function variables(themes) {
  for(const [name,tokens] of Object.entries(themes)) {
    // Separate collections work with single-mode Figma plans as well.
    const collection=figma.variables.createVariableCollection('NWB / '+name);
    collection.renameMode(collection.defaultModeId,'Standard');
    for(const [key,value] of Object.entries(tokens)) {
      const c=color(value),num=/^-?[\d.]+(?:px)?$/.test(value)?parseFloat(value):null;
      const type=c?'COLOR':num!==null?'FLOAT':'STRING';
      const v=figma.variables.createVariable(key,collection,type);
      v.setValueForMode(collection.defaultModeId,c?{...c.color,a:c.alpha}:num!==null?num:value);
      v.description='Aus berechneter CSS-Variable --'+key+' ('+name+')';
      if(name==='billenhausen/light' && c)palette.push({rgb:c.color,variable:v});
    }
  }
}
async function textStyles() {
  for(const [name,size,weight,line] of [['Seitentitel',24,650,30],['Abschnitt',18,650,24.3],['Grundschrift',14,400,20.3],['Hinweis',12,400,17.4]]) {
    const s=figma.createTextStyle();s.name='NWB / '+name;s.fontName=await font(weight);s.fontSize=size;s.lineHeight={unit:'PIXELS',value:line};styles[name]=s;
  }
}
async function label(parent,value,size=14,weight=400,fill='#182c21') {
  const n=figma.createText();parent.appendChild(n);n.fontName=await font(weight);n.characters=value;n.fontSize=size;n.lineHeight={unit:'PIXELS',value:size*1.45};n.fills=paint(fill);return n;
}
async function kit(tokens) {
  const page=figma.createPage();page.name='NWB / Komponenten und Definitionen';
  const specs=[['Button / Primär','Vertrag speichern',tokens.accent,tokens['accent-text'],36],['Button / Sekundär','Abbrechen',tokens.surface,tokens.link,36],['Button / Zeile','Bearbeiten',tokens.surface,tokens.link,32],['Feld / Eingabe','Straße und Hausnummer',tokens.surface,tokens.text,36],['Status / Aktiv','Aktiv',tokens.notice,tokens.text,24],['Kasten / Standard','16 px innen · Raster 12 px · Aktionen 12 px',tokens.surface,tokens.text,80]];
  let y=0;
  for(const [name,value,bg,fg,height] of specs) {
    const c=figma.createComponent();page.appendChild(c);c.name='NWB / '+name;c.x=0;c.y=y;
    c.layoutMode='HORIZONTAL';c.primaryAxisSizingMode='AUTO';c.counterAxisSizingMode='AUTO';c.counterAxisAlignItems='CENTER';c.itemSpacing=12;
    const panel=name.startsWith('Kasten');c.paddingLeft=c.paddingRight=panel?16:12;c.paddingTop=c.paddingBottom=panel?16:4;
    c.minHeight=height;c.fills=paint(bg);c.strokes=paint(tokens.border);c.strokeWeight=1;c.cornerRadius=4;
    const t=await label(c,value,14,name.startsWith('Button')?600:400,fg);
    c.description='Gemeinsamer NWB-Baustein; Auto Layout. Quelle: admin_contracts.css. Innenabstand '+(panel?'16':'4 / 12')+' px. Theme-Variablen NWB/Billenhausen hell.';
    c.setPluginData('nwb-source',name);y+=height+32;
  }
  const notes=await label(page,'NWB Desktop: Außen 12 / 16 px · Kästen 16 px · Bereiche 16 px\nFormularraster 12 × 12 px · Aktionen 12 px · Radius 4 px\nSchrift 14 / 12 / 18 / 24 px · Felder 36 px · Zeilenaktionen 32 px\nTabellenzeilen 40 px · Vertragsliste 52 px · Seitenleiste 184 px\nAnsichten sind editierbare Browser-Snapshots; Komponenten hier mit Auto Layout.\nInter/Arial ersetzt system-ui; Umbrüche anhand der PNG-Referenzen prüfen.',14,400,tokens.text);
  notes.x=480;notes.y=0;
  return page;
}
figma.ui.onmessage=async message=>{
  if(message.type!=='import')return;
  try {
    const data=message.data;if(data?.format!=='nwb-figma-import'||data.version!==1)throw Error('Unbekanntes Exportformat.');
    palette=[];await variables(data.themes);await textStyles();const library=await kit(data.themes['billenhausen/light']);
    const screens=data.screens.filter(s=>message.fullhd||s.width===1440);let page=null,col=0,row=0,width=null,first=null;
    for(let i=0;i<screens.length;i++) {
      const s=screens[i];figma.ui.postMessage({status:`Importiere Ansicht ${i+1} / ${screens.length}: ${s.name}`});
      if(width!==s.width) {page=figma.createPage();page.name='NWB / Ansichten '+s.width;width=s.width;col=0;row=0;}
      const frame=figma.createFrame();page.appendChild(frame);frame.name=s.name;frame.resize(s.width,s.height);frame.x=col*(s.width+120);frame.y=row*(s.height+160);frame.clipsContent=true;frame.fills=paint(s.tokens.page);
      frame.setPluginData('nwb-source-commit',data.sourceCommit);await render(frame,s.root,{x:0,y:0});
      if(!first)first=frame;if(++col===3){col=0;row++;}
    }
    figma.currentPage=first?first.parent:library;if(first){figma.currentPage.selection=[first];figma.viewport.scrollAndZoomIntoView([first]);}
    figma.ui.postMessage({status:`Fertig: ${screens.length} Ansichten, ${Object.keys(data.themes).length} Theme-Definitionen, 4 Textstile und 6 Komponenten.\nDie Datei kann jetzt regulär in Figma gespeichert und als .fig exportiert werden.`,done:true});
  }catch(error){figma.ui.postMessage({status:'Import abgebrochen: '+error.message+'\nBereits erstellte NWB-Seiten/Variablen bei Bedarf löschen; erneut importieren erzeugt neue Definitionen.',done:true});}
};
