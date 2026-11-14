() => {
  const rect = r => ({x:r.x,y:r.y,width:r.width,height:r.height});
  const visible = el => { const s=getComputedStyle(el); return s.display!=='none' && s.visibility!=='hidden' && +s.opacity!==0; };
  function textLines(node) {
    const lines=[]; let line=null;
    for(let i=0;i<node.textContent.length;i++) {
      const range=document.createRange();range.setStart(node,i);range.setEnd(node,i+1);
      const r=range.getBoundingClientRect();if(!r.width || !r.height)continue;
      if(!line || Math.abs(line.y-r.y)>1) {line={...rect(r),text:''};lines.push(line);}
      line.text+=node.textContent[i];line.width=Math.max(line.width,r.right-line.x);
    }
    return lines.filter(l=>l.text.trim());
  }
  function capture(el) {
    if(!visible(el))return null;
    const r=el.getBoundingClientRect(),s=getComputedStyle(el);
    if(r.width<=0 || r.height<=0)return null;
    const info={tag:el.tagName.toLowerCase(),name:el.getAttribute('aria-label') || el.id || (typeof el.className==='string'?el.className:'') || el.tagName.toLowerCase(),...rect(r),
      fill:s.backgroundColor,color:s.color,opacity:+s.opacity,radius:parseFloat(s.borderTopLeftRadius)||0,
      borders:['Top','Right','Bottom','Left'].map(side=>({width:parseFloat(s['border'+side+'Width'])||0,color:s['border'+side+'Color']})),
      clip:['auto','scroll','hidden','clip'].includes(s.overflowX)||['auto','scroll','hidden','clip'].includes(s.overflowY),
      definition:{display:s.display,gap:s.gap,padding:s.padding,gridTemplateColumns:s.gridTemplateColumns,fontFamily:s.fontFamily,fontSize:s.fontSize,fontWeight:s.fontWeight,lineHeight:s.lineHeight},children:[]};
    if(el.tagName.toLowerCase()==='svg') {info.svg=new XMLSerializer().serializeToString(el);return info;}
    const font={size:parseFloat(s.fontSize),weight:parseInt(s.fontWeight)||400,family:s.fontFamily,lineHeight:parseFloat(s.lineHeight)||parseFloat(s.fontSize)*1.45,color:s.color};
    if(el.matches('input,textarea,select')) {
      if(el.matches('[type=hidden]'))return null;
      if(el.matches('[type=checkbox],[type=radio]')) {info.checked=el.checked;return info;}
      const value=el.tagName==='SELECT'?el.selectedOptions[0]?.textContent:el.value||el.placeholder;
      if(value)info.children.push({tag:'text',name:el.tagName==='SELECT'?'Auswahl':'Feldwert',text:value,x:r.x+parseFloat(s.paddingLeft)+1,y:r.y+(r.height-font.size*1.2)/2,width:Math.max(1,r.width-parseFloat(s.paddingLeft)-parseFloat(s.paddingRight)-2),height:font.size*1.2,font});
      return info;
    }
    for(const child of el.childNodes) {
      if(child.nodeType===Node.TEXT_NODE) for(const line of textLines(child))info.children.push({tag:'text',name:line.text.slice(0,60),...line,font});
      else if(child.nodeType===Node.ELEMENT_NODE && !child.matches('script,style,link,meta,template')) {const c=capture(child);if(c)info.children.push(c);}
    }
    return info;
  }
  const root=capture(document.body);
  const css=getComputedStyle(document.body),tokens={};
  const names=['page','surface','text','muted','border','header','header-text','accent','accent-text','link','focus','notice','alert','space-1','space-2','space-3','space-4','space-6','space-8','font-body','font-small','font-title','font-section','line-body','row-height','control-height','action-height','radius','content-inset-block','content-inset-inline','page-heading-gap','panel-inset','field-gap-block','field-gap-inline','action-gap','sidebar-width','selection-row-height'];
  for(const name of names)tokens[name]=css.getPropertyValue('--'+name).trim();
  return {width:innerWidth,height:innerHeight,root,tokens};
}
