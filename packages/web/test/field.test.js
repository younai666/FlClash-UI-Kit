import {test} from 'node:test';
import assert from 'node:assert/strict';
import {mountField} from '../index.js';

test('mount, pause, resume and dispose release RAF, observers and listeners', () => {
  const frames=new Map(), listeners=new Map(), observers=[];
  let id=0, draws=0;
  const add=(name,fn)=>listeners.set(name,fn), remove=(name,fn)=>{if(listeners.get(name)===fn)listeners.delete(name);};
  Object.assign(globalThis,{window:globalThis,scrollY:0,devicePixelRatio:1,
    document:{hidden:false,addEventListener:add,removeEventListener:remove},
    getComputedStyle:()=>({getPropertyValue:()=> '#999'}),addEventListener:add,removeEventListener:remove,
    requestAnimationFrame:fn=>{frames.set(++id,fn);return id;},cancelAnimationFrame:frame=>frames.delete(frame),
    ResizeObserver:class{constructor(){observers.push(this);}observe(){}disconnect(){this.disconnected=true;}},
    IntersectionObserver:class{constructor(){observers.push(this);}observe(){}disconnect(){this.disconnected=true;}},
  });
  const context={setTransform(){},clearRect(){draws++;},beginPath(){},moveTo(){},lineTo(){},stroke(){}};
  const canvas={getContext:()=>context,getBoundingClientRect:()=>({left:0,top:0,width:800,height:600})};
  let paused=false;
  const field=mountField(canvas,{still:()=>paused});
  assert.ok(field);
  assert.equal(frames.size,1);
  assert.equal(listeners.size,3);
  assert.equal(canvas.width,800);
  assert.ok(draws>0);
  paused=true;field.refresh();assert.equal(frames.size,0);
  paused=false;field.refresh();assert.equal(frames.size,1);
  field.dispose();
  assert.equal(frames.size,0);
  assert.equal(listeners.size,0);
  assert.equal(observers.length,2);
  assert.ok(observers.every(observer=>observer.disconnected));
  assert.equal(mountField({getContext:()=>null}),null);
});
