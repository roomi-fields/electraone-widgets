// Electra One widget emulator — Fengari + canvas stubs
// Phase 1: render paint callbacks + touch events.

console.log("[emulator] script parsed. window.fengari =", typeof window.fengari);
document.addEventListener("DOMContentLoaded", () => {
  console.log("[emulator] DOMContentLoaded. fengari =", typeof window.fengari);
});

const RAW_BASE = "https://raw.githubusercontent.com/roomi-fields/electraone-widgets/main";

const CONST = {
  // Electra convention: bounds is a 1-based Lua array {1:x, 2:y, 3:w, 4:h}
  WIDTH: 3, HEIGHT: 4, X: 1, Y: 2,
  LEFT: 0, RIGHT: 1, CENTER: 2,
  DOWN: 1, MOVE: 2, UP: 3, CLICK: 4, LONG_HOLD: 5, HOLD: 6,
  PT_CC7: 1, PT_VIRTUAL: 2, PT_NRPN: 3, PT_RPN: 4,
  PORT_1: 1, PORT_2: 2, PORT_CTRL: 3,
  MODEL_MK2: "mk2",
  RED: 0xFF0000, GREEN: 0x00FF00, BLUE: 0x0000FF, YELLOW: 0xFFFF00,
  PURPLE: 0xB14AE0, ORANGE: 0xFF8A1F, WHITE: 0xFFFFFF, BLACK: 0x000000,
};
const STAGE_W = 1016, STAGE_H = 560;

function logMsg(s, cls = "") {
  const log = document.getElementById("log");
  const line = document.createElement("div");
  if (cls) line.className = cls;
  line.textContent = s;
  log.appendChild(line);
  log.scrollTop = log.scrollHeight;
}

class Stage {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext("2d");
    this.controls = {};
    this.paintCbs = {};
    this.touchCbs = {};
    this.potCbs = {};
    this.currentColor = 0xFFFFFF;
  }
  hexColor(c) { return "#" + ("000000" + (c >>> 0).toString(16)).slice(-6); }
  paintAll() {
    this.ctx.clearRect(0, 0, STAGE_W, STAGE_H);
    for (const id of Object.keys(this.paintCbs)) this.paintOne(id);
  }
  paintOne(id) {
    const ctrl = this.controls[id];
    const cb = this.paintCbs[id];
    if (!ctrl || !cb) return;
    const [x, y, w, h] = ctrl.bounds;
    this.ctx.save();
    this.ctx.translate(x, y);
    this.ctx.beginPath();
    this.ctx.rect(0, 0, w, h);
    this.ctx.clip();
    try { cb(ctrl); } catch (e) { logMsg("paint err: " + e.message, "err"); }
    this.ctx.restore();
  }
}

class ValueObject {
  constructor() { this._min = 0; this._max = 127; this._default = 0; this._value = 0; }
  setRange(min, max, def, _showNumbers) { this._min = min; this._max = max; if (def !== undefined) this._default = def; }
  getDefault() { return this._default; }
  getMin() { return this._min; }
  getMax() { return this._max; }
  setValue(v) { this._value = v; }
  getValue() { return this._value; }
  getMessage() {
    if (!this._message) this._message = new MessageObject(this._tile);
    return this._message;
  }
  getControl() { return null; }
  setDefault(v) { this._default = v; }
  setLabel() {}
  setOverlayId() {}
  setFormatter() {}
  setFunction() {}
  getId() { return 0; }
}
class MessageObject {
  constructor(tile) { this._tile = tile || null; }
  getValue() { return this._tile ? (this._tile._lastValue ?? 0) : 0; }
  setValue() {}
  getParameterNumber() { return this._tile ? (this._tile.msgParam ?? 0) : 0; }
  getDeviceId() { return 1; }
  getType() { return this._tile ? (this._tile.msgType ?? "cc7") : "cc7"; }
  getMin() { return this._tile ? (this._tile.msgMin ?? 0) : 0; }
  getMax() { return this._tile ? (this._tile.msgMax ?? 127) : 127; }
  getOnValue() { return this._tile ? (this._tile.msgOn ?? 127) : 127; }
  getOffValue() { return this._tile ? (this._tile.msgOff ?? 0) : 0; }
  setMin() {} setMax() {}
  setParameterNumber(cc) { if (this._tile) this._tile.msgParam = cc; }
  setDeviceId() {}
}

class Control {
  constructor(id, stage, bounds) {
    this.id = id;
    this.stage = stage;
    this.bounds = bounds.slice();
    this.value = 0;
    this.x = 0;
    this.y = 0;
    this._values = {}; // id → ValueObject
  }
  getBounds() {
    // Return a real JS Array (1-based in Lua via sparse indices) so pushObject
    // treats it as a native Lua table (iterable by lua_next, passable back through
    // luaToJS intact). WIDTH/HEIGHT constants (3, 4) index into it.
    const [x, y, w, h] = this.bounds;
    const a = [];
    a[1] = x; a[2] = y; a[3] = w; a[4] = h;
    return a;
  }
  setBounds(b) {
    let x, y, w, h;
    if (b[1] !== undefined || b[3] !== undefined) {
      x = b[1]; y = b[2]; w = b[3]; h = b[4];
    } else {
      x = b.x; y = b.y; w = b.width; h = b.height;
    }
    this.bounds = [x ?? this.bounds[0], y ?? this.bounds[1], w ?? this.bounds[2], h ?? this.bounds[3]];
  }
  setPaintCallback(fn) { this.stage.paintCbs[this.id] = fn; }
  setTouchCallback(fn) { this.stage.touchCbs[this.id] = fn; }
  setPotCallback(fn)   { this.stage.potCbs[this.id]   = fn; }
  setValue(v) { this.value = v; }
  getValue(id) {
    const key = id ?? "value";
    if (!this._values[key]) {
      const vo = new ValueObject();
      vo._tile = this.tile || null;  // link for message:setParameterNumber to write back
      this._values[key] = vo;
    }
    return this._values[key];
  }
  setColor() {} setLabel() {} setName() {} setVisible() {} setSlot() {}
  setRange() {} setDefaultValue() {} setMode() {}
  getId() { return this.id; }
  getName() { return "Control " + this.id; }
  getColor() { return 0xFFFFFF; }
  getValues() { return Object.values(this._values); }
  repaint() { this.stage.paintOne(this.id); }
}

// ============ Fengari helpers ============

let F, lua, lauxlib, lualib, to_luastring, to_jsstring;

function safeTostring(L, idx) {
  try {
    const t = lua.lua_type(L, idx);
    if (t === lua.LUA_TSTRING) return to_jsstring(lua.lua_tostring(L, idx));
    if (t === lua.LUA_TTABLE) {
      // Try extracting usual error-message fields
      const absIdx = lua.lua_absindex(L, idx);
      for (const key of ["message", "msg", "error"]) {
        lua.lua_getfield(L, absIdx, to_luastring(key));
        if (lua.lua_type(L, -1) === lua.LUA_TSTRING) {
          const s = to_jsstring(lua.lua_tostring(L, -1));
          lua.lua_pop(L, 1);
          return s;
        }
        lua.lua_pop(L, 1);
      }
      lua.lua_geti(L, absIdx, 1);
      if (lua.lua_type(L, -1) === lua.LUA_TSTRING) {
        const s = to_jsstring(lua.lua_tostring(L, -1));
        lua.lua_pop(L, 1);
        return s;
      }
      lua.lua_pop(L, 1);
      // Fall through to tostring
    }
    lua.lua_getglobal(L, to_luastring("tostring"));
    lua.lua_pushvalue(L, idx < 0 ? idx - 1 : idx);
    if (lua.lua_pcall(L, 1, 1, 0) !== 0) {
      lua.lua_pop(L, 1);
      return "(unknown lua error)";
    }
    const s = lua.lua_tostring(L, -1);
    lua.lua_pop(L, 1);
    if (!s) return "(nil error)";
    return to_jsstring(s);
  } catch (e) {
    return "(" + e.message + ")";
  }
}

function initFengari() {
  if (!window.fengari) throw new Error("Fengari not loaded (check network / CDN)");
  F = window.fengari;
  lua = F.lua; lauxlib = F.lauxlib; lualib = F.lualib;
  to_luastring = F.to_luastring; to_jsstring = F.to_jsstring;
}

function pushValue(L, v) {
  if (v === null || v === undefined) lua.lua_pushnil(L);
  else if (typeof v === "number") lua.lua_pushnumber(L, v);
  else if (typeof v === "string") lua.lua_pushstring(L, to_luastring(v));
  else if (typeof v === "boolean") lua.lua_pushboolean(L, v ? 1 : 0);
  else if (typeof v === "function") lua.lua_pushjsfunction(L, wrapFn(v));
  else if (typeof v === "object") {
    // Always use proxy for objects so mutations to nested fields persist.
    // Arrays stay arrays (we need raw Lua-table semantics for ipairs / #),
    // but class instances and plain objects both go through pushJSAsLua so
    // `obj.nested.x = v` writes back to the original JS object.
    if (Array.isArray(v)) {
      pushObject(L, v);
    } else {
      pushJSAsLua(L, v);
    }
  }
  else lua.lua_pushnil(L);
}

function wrapFn(fn) {
  return function (L) {
    try {
      const n = lua.lua_gettop(L);
      const args = [];
      for (let i = 1; i <= n; i++) args.push(luaToJS(L, i));
      let ret;
      try { ret = fn.apply(null, args); }
      catch (e) {
        console.error("[stub] JS err in", fn.name || "anon", e, e.stack);
        logMsg("stub err: " + e.message, "err");
        return 0;
      }
      if (ret === undefined || ret === null) return 0;
      pushValue(L, ret);
      return 1;
    } catch (e) {
      console.error("[wrapFn] outer err:", e, e.stack);
      return 0;
    }
  };
}

function pushObject(L, obj) {
  // Plain map/module as Lua table. Numeric-looking keys get integer indexing
  // so Lua can do `t[2]` and not `t["2"]`.
  lua.lua_createtable(L, 0, Object.keys(obj).length);
  for (const [k, v] of Object.entries(obj)) {
    pushValue(L, v);
    const num = Number(k);
    if (Number.isInteger(num) && num >= 0 && String(num) === k) {
      lua.lua_seti(L, -2, num);
    } else {
      lua.lua_setfield(L, -2, to_luastring(k));
    }
  }
}

// Wrap a JS object with methods as Lua userdata (colon-call semantics).
// Reads AND writes proxy through to the JS object, so `ctrl.x = 100` works.
// User-added Lua methods (`function obj:m() end`) are stored as registry refs
// and returned raw, preserving proper self-passing semantics.
function pushJSAsLua(L, obj) {
  lua.lua_createtable(L, 0, 0);
  const tableIdx = lua.lua_gettop(L);
  lua.lua_createtable(L, 0, 2);

  // __index
  lua.lua_pushjsfunction(L, (L) => {
    let key;
    try {
      const kt = lua.lua_type(L, 2);
      if (kt === lua.LUA_TNUMBER) {
        key = lua.lua_tonumber(L, 2);
      } else {
        const s = lua.lua_tostring(L, 2);
        key = s ? to_jsstring(s) : null;
      }
    } catch (e) { console.error("[__index] key conv:", e); return 0; }
    if (key === null || key === undefined) { lua.lua_pushnil(L); return 1; }
    const v = obj[key];
    // User-added Lua function: push raw Lua function so colon-calls preserve self
    if (v && typeof v === "object" && v._luaRef !== undefined) {
      lua.lua_rawgeti(L, lua.LUA_REGISTRYINDEX, v._luaRef);
      return 1;
    }
    // Native JS method on the instance — wrap it
    if (typeof v === "function") {
      lua.lua_pushjsfunction(L, (L) => {
        const n = lua.lua_gettop(L);
        const args = [];
        for (let i = 2; i <= n; i++) args.push(luaToJS(L, i));  // skip self
        let ret;
        try { ret = v.apply(obj, args); }
        catch (e) { logMsg(`method err ${key}: ${e.message}`, "err"); return 0; }
        if (ret === undefined || ret === null) return 0;
        pushValue(L, ret);
        return 1;
      });
      return 1;
    }
    if (v !== undefined) { pushValue(L, v); return 1; }
    lua.lua_pushnil(L);
    return 1;
  });
  lua.lua_setfield(L, -2, to_luastring("__index"));

  // __newindex — obj.x = v (also handles `function obj:foo() end`)
  lua.lua_pushjsfunction(L, (L) => {
    try {
      const keyRaw = lua.lua_tostring(L, 2);
      const key = keyRaw ? to_jsstring(keyRaw) : String(lua.lua_tonumber(L, 2));
      const t = lua.lua_type(L, 3);
      if (t === lua.LUA_TFUNCTION) {
        lua.lua_pushvalue(L, 3);
        const ref = lauxlib.luaL_ref(L, lua.LUA_REGISTRYINDEX);
        obj[key] = { _luaRef: ref };
      } else {
        const val = luaToJS(L, 3);
        obj[key] = val;
        if (window.__DIAG_NEWINDEX) {
          const tag = obj.constructor && obj.constructor.name !== "Object" ? obj.constructor.name : "obj";
          const preview = typeof val === "object" && val ? `{${Object.keys(val).length}}` : JSON.stringify(val);
          console.log(`[__newindex ${tag}] ${key} = ${preview}`);
        }
      }
      return 0;
    } catch (e) {
      console.error("[__newindex] JS err:", e, e.stack);
      return 0;
    }
  });
  lua.lua_setfield(L, -2, to_luastring("__newindex"));

  lua.lua_setmetatable(L, tableIdx);
}

function luaToJS(L, i) {
  const t = lua.lua_type(L, i);
  if (t === lua.LUA_TSTRING)   return to_jsstring(lua.lua_tostring(L, i));
  if (t === lua.LUA_TNUMBER)   return lua.lua_tonumber(L, i);
  if (t === lua.LUA_TBOOLEAN)  return Boolean(lua.lua_toboolean(L, i));
  if (t === lua.LUA_TNIL)      return null;
  if (t === lua.LUA_TFUNCTION) {
    const ref = lauxlib.luaL_ref(L, lua.LUA_REGISTRYINDEX);
    return function (...args) {
      lua.lua_rawgeti(L, lua.LUA_REGISTRYINDEX, ref);
      for (const a of args) pushValue(L, a);
      if (lua.lua_pcall(L, args.length, 0, 0) !== 0) {
        logMsg("cb err: " + safeTostring(L, -1), "err");
        lua.lua_pop(L, 1);
      }
    };
  }
  if (t === lua.LUA_TTABLE) {
    // Resolve absolute index BEFORE pushing nil, otherwise negative indices
    // point at the newly pushed nil instead of the table.
    const abs = lua.lua_absindex(L, i);
    const obj = {};
    lua.lua_pushnil(L);
    while (lua.lua_next(L, abs) !== 0) {
      const k = luaToJS(L, -2);
      const v = luaToJS(L, -1);
      obj[k] = v;
      lua.lua_pop(L, 1);
    }
    return obj;
  }
  // userdata / other
  return null;
}

// ============ Environment ============

function setupEnv(L, stage) {
  // constants
  for (const [k, v] of Object.entries(CONST)) {
    if (typeof v === "number") lua.lua_pushnumber(L, v);
    else lua.lua_pushstring(L, to_luastring(v));
    lua.lua_setglobal(L, to_luastring(k));
  }

  // graphics
  const roundRect = (ctx, x, y, w, h, r) => {
    r = Math.min(r, w/2, h/2);
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.arcTo(x + w, y, x + w, y + h, r);
    ctx.arcTo(x + w, y + h, x, y + h, r);
    ctx.arcTo(x, y + h, x, y, r);
    ctx.arcTo(x, y, x + w, y, r);
    ctx.closePath();
  };
  pushObject(L, {
    setColor: (c) => { stage.currentColor = c; const col = stage.hexColor(c); stage.ctx.fillStyle = col; stage.ctx.strokeStyle = col; },
    fillRect: (x, y, w, h) => stage.ctx.fillRect(x, y, w, h),
    drawRect: (x, y, w, h) => stage.ctx.strokeRect(x, y, w, h),
    fillRoundRect: (x, y, w, h, r) => { roundRect(stage.ctx, x, y, w, h, r); stage.ctx.fill(); },
    drawRoundRect: (x, y, w, h, r) => { roundRect(stage.ctx, x, y, w, h, r); stage.ctx.stroke(); },
    fillCircle: (cx, cy, r) => { stage.ctx.beginPath(); stage.ctx.arc(cx, cy, r, 0, Math.PI * 2); stage.ctx.fill(); },
    drawCircle: (cx, cy, r) => { stage.ctx.beginPath(); stage.ctx.arc(cx, cy, r, 0, Math.PI * 2); stage.ctx.stroke(); },
    fillEllipse: (cx, cy, rx, ry) => { stage.ctx.beginPath(); stage.ctx.ellipse(cx, cy, rx, ry, 0, 0, Math.PI * 2); stage.ctx.fill(); },
    drawEllipse: (cx, cy, rx, ry) => { stage.ctx.beginPath(); stage.ctx.ellipse(cx, cy, rx, ry, 0, 0, Math.PI * 2); stage.ctx.stroke(); },
    drawLine: (x1, y1, x2, y2) => { stage.ctx.beginPath(); stage.ctx.moveTo(x1, y1); stage.ctx.lineTo(x2, y2); stage.ctx.stroke(); },
    fillTriangle: (x1, y1, x2, y2, x3, y3) => { stage.ctx.beginPath(); stage.ctx.moveTo(x1, y1); stage.ctx.lineTo(x2, y2); stage.ctx.lineTo(x3, y3); stage.ctx.closePath(); stage.ctx.fill(); },
    drawTriangle: (x1, y1, x2, y2, x3, y3) => { stage.ctx.beginPath(); stage.ctx.moveTo(x1, y1); stage.ctx.lineTo(x2, y2); stage.ctx.lineTo(x3, y3); stage.ctx.closePath(); stage.ctx.stroke(); },
    print: (x, y, text, size) => {
      stage.ctx.font = `${size || 10}px 'Open Sans', sans-serif`;
      stage.ctx.textBaseline = "top";
      stage.ctx.fillText(String(text ?? ""), x, y);
    },
    drawText: (x, y, text, size) => {
      stage.ctx.font = `${size || 10}px 'Open Sans', sans-serif`;
      stage.ctx.textBaseline = "top";
      stage.ctx.fillText(String(text ?? ""), x, y);
    },
    setPixel: (x, y) => stage.ctx.fillRect(x, y, 1, 1),
    drawPixel: (x, y) => stage.ctx.fillRect(x, y, 1, 1),
    drawPixelLine: (x, y, x2, y2) => { stage.ctx.beginPath(); stage.ctx.moveTo(x, y); stage.ctx.lineTo(x2, y2); stage.ctx.stroke(); },
    setClippingRect: (x, y, w, h) => { stage.ctx.save(); stage.ctx.beginPath(); stage.ctx.rect(x, y, w, h); stage.ctx.clip(); },
    resetClipping: () => { try { stage.ctx.restore(); } catch(_){} },
  });
  lua.lua_setglobal(L, to_luastring("graphics"));

  // controls
  const controls = {
    get: (id) => {
      if (!stage.controls[id]) stage.controls[id] = new Control(id, stage, [0, 0, STAGE_W, STAGE_H]);
      return stage.controls[id];
    },
  };
  lua.lua_createtable(L, 0, 1);
  lua.lua_pushjsfunction(L, (L) => {
    const id = lua.lua_tonumber(L, 1);
    pushJSAsLua(L, controls.get(id));
    return 1;
  });
  lua.lua_setfield(L, -2, to_luastring("get"));
  lua.lua_setglobal(L, to_luastring("controls"));

  // devices
  const fakeDevice = { getPort: () => CONST.PORT_1, getChannel: () => 1, getId: () => 1 };
  lua.lua_createtable(L, 0, 1);
  lua.lua_pushjsfunction(L, (L) => { pushJSAsLua(L, fakeDevice); return 1; });
  lua.lua_setfield(L, -2, to_luastring("get"));
  lua.lua_setglobal(L, to_luastring("devices"));

  // parameterMap — routes set(deviceId, type, paramNum, value) to any tile
  // whose MIDI message matches, so values written by the widget's Lua logic
  // (e.g. cube-lfo's outbound CCs) are reflected visually on the native tiles.
  pushObject(L, {
    get: () => 0,
    set: (_deviceId, type, paramNum, value) => {
      if (!stage.nativeTiles) return;
      for (const tile of stage.nativeTiles) {
        if (tile.msgType === type && tile.msgParam === paramNum) {
          stage.tileValues[tile.ref] = value;
          updateTileVisual(tile, value);
        }
      }
    },
    send: () => {},
  });
  lua.lua_setglobal(L, to_luastring("parameterMap"));
  pushObject(L, {
    sendControlChange: () => {}, sendNoteOn: () => {}, sendNoteOff: () => {},
    sendSysex: () => {}, sendProgramChange: () => {}, sendPitchBend: () => {},
    sendControlChange14Bit: () => {}, sendNrpn: () => {}, sendRpn: () => {},
    sendAfterTouchChannel: () => {}, sendAfterTouchPoly: () => {},
    sendClock: () => {}, sendStart: () => {}, sendStop: () => {},
  });
  lua.lua_setglobal(L, to_luastring("midi"));
  // timer — provides actual tick loop so animated widgets run
  stage.timerState = { intervalId: null, periodMs: 20 };
  const doTick = () => {
    lua.lua_getglobal(L, to_luastring("timer"));
    lua.lua_getfield(L, -1, to_luastring("onTick"));
    if (lua.lua_isfunction(L, -1)) {
      if (lua.lua_pcall(L, 0, 0, 0) !== 0) {
        logMsg("timer.onTick err: " + safeTostring(L, -1), "err");
        lua.lua_pop(L, 1);
      }
    } else {
      lua.lua_pop(L, 1);
    }
    lua.lua_pop(L, 1);
    stage.paintAll();
  };
  const startTimer = () => {
    if (stage.timerState.intervalId) return;
    doTick();   // fire once immediately so first paint has valid state
    stage.timerState.intervalId = setInterval(doTick, stage.timerState.periodMs);
  };
  const stopTimer = () => {
    if (stage.timerState.intervalId) {
      clearInterval(stage.timerState.intervalId);
      stage.timerState.intervalId = null;
    }
  };
  // Keep a handle so loadWidget can stop previous timer on reload
  stage._stopTimer = stopTimer;

  pushObject(L, {
    enable: () => startTimer(),
    disable: () => stopTimer(),
    setPeriod: (ms) => { stage.timerState.periodMs = Math.max(10, ms|0); if (stage.timerState.intervalId) { stopTimer(); startTimer(); } },
    setBpm: (bpm) => { stage.timerState.periodMs = Math.max(10, Math.round(60000 / (bpm * 24))); },
  });
  lua.lua_setglobal(L, to_luastring("timer"));

  // preset table
  lua.lua_createtable(L, 0, 0);
  lua.lua_setglobal(L, to_luastring("preset"));

  // window (Ephemera-style) - re-paints the whole stage
  pushObject(L, { addAndMakeVisible: () => {}, repaint: () => stage.paintAll() });
  lua.lua_setglobal(L, to_luastring("window"));

  // Component constructor (Ephemera)
  lua.lua_pushjsfunction(L, (L) => {
    const id = lua.lua_tonumber(L, 1);
    // args: id, color, label, bounds{x,y,width,height}
    const bt = luaToJS(L, 4) || { x: 0, y: 0, width: 100, height: 100 };
    const ctrl = new Control(id, stage, [bt.x || 0, bt.y || 0, bt.width || 100, bt.height || 100]);
    stage.controls[id] = ctrl;
    pushJSAsLua(L, ctrl);
    return 1;
  });
  lua.lua_setglobal(L, to_luastring("Component"));

  // controller.isRequired
  lua.lua_createtable(L, 0, 1);
  lua.lua_pushjsfunction(L, (L) => { lua.lua_pushboolean(L, 1); return 1; });
  lua.lua_setfield(L, -2, to_luastring("isRequired"));
  lua.lua_setglobal(L, to_luastring("controller"));

  // info
  pushObject(L, { setText: () => {} });
  lua.lua_setglobal(L, to_luastring("info"));

  // print → log
  lua.lua_pushjsfunction(L, (L) => {
    const n = lua.lua_gettop(L);
    const parts = [];
    for (let i = 1; i <= n; i++) parts.push(luaToJS(L, i));
    logMsg("[lua] " + parts.join("\t"), "info");
    return 0;
  });
  lua.lua_setglobal(L, to_luastring("print"));
}

// ============ Native tile interactivity ============

function fireParameterChange(stage, tile, midiValue) {
  const L = stage.L;
  if (!L) return;
  lua.lua_getglobal(L, to_luastring("parameterMap"));
  lua.lua_getfield(L, -1, to_luastring("onChange"));
  if (!lua.lua_isfunction(L, -1)) { lua.lua_pop(L, 2); return; }
  lua.lua_createtable(L, 1, 0);
  const mockControl = { getId: () => tile.ref, getName: () => tile.name || "", getColor: () => 0xFFFFFF };
  const mockMessage = {
    getValue: () => midiValue,
    getParameterNumber: () => tile.msgParam ?? tile.ref,
    getDeviceId: () => 1,
    getType: () => tile.msgType ?? CONST.PT_CC7,
    getMin: () => tile.msgMin ?? 0, getMax: () => tile.msgMax ?? 127,
    getOnValue: () => tile.msgOn ?? 127, getOffValue: () => tile.msgOff ?? 0,
  };
  const mockVO = {
    getControl: () => mockControl,
    getMessage: () => mockMessage,
    getValue: () => midiValue,
    setValue: () => {},
    getMin: () => tile.msgMin ?? 0, getMax: () => tile.msgMax ?? 127,
    getDefault: () => 64,
  };
  pushJSAsLua(L, mockVO);
  lua.lua_seti(L, -2, 1);
  lua.lua_pushnumber(L, 0);                  // origin (USER)
  lua.lua_pushnumber(L, midiValue);
  if (lua.lua_pcall(L, 3, 0, 0) !== 0) {
    logMsg("parameterMap.onChange err: " + safeTostring(L, -1), "err");
    lua.lua_pop(L, 1);
  }
  lua.lua_pop(L, 1); // parameterMap
  // Also invoke per-value callback (e.g. xCcChanged) if the preset defined one
  if (tile.fnName) {
    lua.lua_getglobal(L, to_luastring(tile.fnName));
    if (lua.lua_isfunction(L, -1)) {
      pushJSAsLua(L, mockVO);
      lua.lua_pushnumber(L, midiValue);
      if (lua.lua_pcall(L, 2, 0, 0) !== 0) {
        logMsg(`${tile.fnName} err: ${safeTostring(L, -1)}`, "err");
        lua.lua_pop(L, 1);
      }
    } else {
      lua.lua_pop(L, 1);
    }
  }
  lua.lua_pop(L, 1);
}

function createNativeTileOverlays(stage) {
  const stageEl = document.getElementById("stage");
  for (const tile of stage.nativeTiles) {
    if (!tile.ref || !tile.el) continue;
    if (tile.type !== "fader" && tile.type !== "pad" && tile.type !== "list") continue;
    const [x, y, w, h] = tile.bounds;

    tile.valueEl = findValueElement(tile);

    // Derive initial value from the SVG's current visual state (so drag from
    // initial position grows/shrinks the actual bar consistently).
    if (stage.tileValues[tile.ref] === undefined) {
      if (tile.type === "fader" && tile.valueEl) {
        const curW = parseFloat(tile.valueEl.getAttribute("width") || 0);
        const maxW = parseFloat(tile.valueEl.dataset.maxW || curW);
        stage.tileValues[tile.ref] = maxW > 0 ? Math.round(127 * curW / maxW) : 64;
      } else if (tile.type === "pad") {
        stage.tileValues[tile.ref] = 0;
      } else if (tile.type === "list") {
        stage.tileValues[tile.ref] = tile.defaultValue ?? 0;
      } else {
        stage.tileValues[tile.ref] = 0;
      }
    }
    updateTileVisual(tile, stage.tileValues[tile.ref]);

    // Create an invisible interaction overlay (positioned over the tile)
    const el = document.createElement("div");
    el.className = "native-overlay";
    el.title = `${tile.type} ref=${tile.ref} ${tile.name || ""}`;
    Object.assign(el.style, {
      position: "absolute",
      left:   (x / 1016 * 100) + "%",
      top:    (y / 560  * 100) + "%",
      width:  (w / 1016 * 100) + "%",
      height: (h / 560  * 100) + "%",
      cursor: tile.type === "fader" ? "ns-resize" : "pointer",
      zIndex: "2",
      background: "transparent",
    });
    stageEl.appendChild(el);

    if (tile.type === "fader") {
      // Horizontal drag (matches MK2 fader orientation: bar fills L→R)
      let startX = 0, startVal = 0, dragging = false;
      el.style.cursor = "ew-resize";
      el.addEventListener("pointerdown", (ev) => {
        ev.preventDefault(); el.setPointerCapture(ev.pointerId);
        dragging = true; startX = ev.clientX; startVal = stage.tileValues[tile.ref] || 0;
      });
      el.addEventListener("pointermove", (ev) => {
        if (!dragging) return;
        const dx = ev.clientX - startX;
        const sensitivity = 1.5;
        let v = startVal + Math.round(dx / sensitivity);
        v = Math.max(0, Math.min(127, v));
        if (v !== stage.tileValues[tile.ref]) {
          stage.tileValues[tile.ref] = v;
          updateTileVisual(tile, v);
          fireParameterChange(stage, tile, v);
        }
      });
      el.addEventListener("pointerup", () => { dragging = false; });
    } else if (tile.type === "pad") {
      el.addEventListener("click", () => {
        const v = stage.tileValues[tile.ref] ? 0 : 127;
        stage.tileValues[tile.ref] = v;
        updateTileVisual(tile, v);
        fireParameterChange(stage, tile, v);
      });
    } else if (tile.type === "list") {
      // Cycle through textValues on click (shift-click = previous)
      el.addEventListener("click", (ev) => {
        const tv = Array.isArray(tile.textValues) ? tile.textValues : null;
        if (!tv || tv.length === 0) return;
        const cur = stage.tileValues[tile.ref];
        const curIdx = tv.findIndex(t => t.value === cur);
        const dir = ev.shiftKey ? -1 : 1;
        const nextIdx = ((curIdx < 0 ? 0 : curIdx + dir) + tv.length) % tv.length;
        const next = tv[nextIdx].value;
        stage.tileValues[tile.ref] = next;
        updateTileVisual(tile, next);
        fireParameterChange(stage, tile, next);
      });
    }
  }
}

// Find the element inside the tile that represents the value (the part to animate)
function findValueElement(tile) {
  if (tile.type === "fader") {
    // Exclude rects inside <defs> / <clipPath> (those aren't the value bar).
    // Track rect has fill-opacity="0.2"; value bar has no fill-opacity + a real fill.
    const rects = Array.from(tile.el.querySelectorAll("rect"))
      .filter(r => !r.closest("defs") && !r.closest("clipPath"));
    const valueBar = rects.find(r =>
      !r.getAttribute("fill-opacity") &&
      (r.getAttribute("fill") || "").toLowerCase() !== "none" &&
      r.getAttribute("fill"));
    const track = rects.find(r => r.getAttribute("fill-opacity"));
    if (valueBar && track && !valueBar.dataset.maxW) {
      valueBar.dataset.maxW = track.getAttribute("width");
    }
    return valueBar || null;
  }
  if (tile.type === "pad") {
    // Use the first or second large rect as the toggled element
    const rects = tile.el.querySelectorAll("rect");
    return rects[0] || null;
  }
  if (tile.type === "list") {
    return tile.el.querySelector("text") || null;
  }
  return null;
}

function updateTileVisual(tile, value) {
  if (!tile.valueEl) return;
  if (tile.type === "fader") {
    const maxW = parseFloat(tile.valueEl.dataset.maxW || tile.valueEl.getAttribute("width") || 0);
    tile.valueEl.setAttribute("width", (maxW * value / 127).toFixed(1));
  } else if (tile.type === "pad") {
    tile.valueEl.setAttribute("fill-opacity", value ? "0.8" : "0.2");
  } else if (tile.type === "list") {
    // Map value to textValue label when available, else show the raw number
    let label = String(value);
    if (Array.isArray(tile.textValues)) {
      const tv = tile.textValues.find(t => t.value === value);
      if (tv) label = tv.label;
    }
    try { tile.valueEl.textContent = label; } catch (_) {}
  }
}

async function runLua(L, code) {
  const buf = to_luastring(code);
  console.log("[runLua] loadbuffer", buf.length, "bytes");
  const loadRC = lauxlib.luaL_loadbuffer(L, buf, buf.length, to_luastring("=widget"));
  if (loadRC !== 0) {
    console.error("[runLua] load failed rc=", loadRC, "stack top type=", lua.lua_type(L, -1));
    logMsg("load err: " + safeTostring(L, -1), "err");
    lua.lua_pop(L, 1);
    return;
  }
  console.log("[runLua] loaded, calling pcall");
  let pcallRC;
  try {
    pcallRC = lua.lua_pcall(L, 0, 0, 0);
  } catch (e) {
    console.error("[runLua] pcall threw JS:", e, e.stack);
    logMsg("pcall threw: " + e.message, "err");
    return;
  }
  console.log("[runLua] pcall returned rc=", pcallRC, "stack top type=", lua.lua_type(L, -1));
  if (pcallRC !== 0) {
    const errType = lua.lua_type(L, -1);
    console.error("[runLua] error on stack, type=", errType);
    logMsg(`run err (type ${errType}): ` + safeTostring(L, -1), "err");
    lua.lua_pop(L, 1);
    return;
  }
  // Call preset.onLoad
  lua.lua_getglobal(L, to_luastring("preset"));
  lua.lua_getfield(L, -1, to_luastring("onLoad"));
  if (lua.lua_isfunction(L, -1)) {
    if (lua.lua_pcall(L, 0, 0, 0) !== 0) {
      logMsg("onLoad err: " + safeTostring(L, -1), "err");
      lua.lua_pop(L, 1);
    }
  } else {
    lua.lua_pop(L, 1);
  }
  lua.lua_pop(L, 1);
}

async function loadWidget(slug) {
  document.getElementById("log").innerHTML = "";
  logMsg(`Loading widget: ${slug}`, "info");
  document.getElementById("status").textContent = "…";

  // Stop previous timer if any
  if (window.__currentStage && window.__currentStage._stopTimer) {
    window.__currentStage._stopTimer();
  }
  // Clear previous interactive overlays
  document.querySelectorAll(".native-overlay").forEach(n => n.remove());

  const canvas = document.getElementById("canvas");
  const stage = new Stage(canvas);
  window.__currentStage = stage;
  stage.tileValues = {};  // ref → 0..127 current value
  stage.nativeTiles = []; // {type, bounds, ref, name}
  stage.L = null;         // set after Lua state created below

  // Pre-seed a few common control refs full-screen
  for (const id of [1, 4, 5]) stage.controls[id] = new Control(id, stage, [0, 0, STAGE_W, STAGE_H]);

  // Load SVG (visual background) + preset JSON (for tile references)
  let preset = null;
  try {
    const presetText = await (await fetch(`${RAW_BASE}/widgets/${slug}/demo.preset.json`)).text();
    preset = JSON.parse(presetText);
  } catch (e) { logMsg("no demo.preset.json: " + e.message, "info"); }

  try {
    const svgText = await (await fetch(`../previews/${slug}.svg`)).text();
    // Inline the SVG into the DOM so we can manipulate fader bars, pad fills etc.
    const svgLayer = document.getElementById("svg-layer");
    svgLayer.innerHTML = svgText;
    const svgEl = svgLayer.querySelector("svg");
    if (svgEl) {
      svgEl.setAttribute("preserveAspectRatio", "xMidYMid meet");
    }
    // Strip rounded corners off all rects — match the physical MK2 screen style
    svgLayer.querySelectorAll("rect[rx], rect[ry]").forEach(r => {
      r.removeAttribute("rx"); r.removeAttribute("ry");
    });

    // Walk the DOM now — find every <g type="..." bounds="..."> element
    const tiles = [];
    svgLayer.querySelectorAll("g[type][bounds]").forEach(g => {
      const [x, y, w, h] = g.getAttribute("bounds").split(",").map(Number);
      const type = g.getAttribute("type");
      tiles.push({ type, bounds: [x, y, w, h], el: g });
    });

    // Match SVG tiles to preset tiles. For each SVG tile, consume the next
    // unused preset tile of the same type (the preset may interleave types
    // differently from the SVG, so a single linear cursor doesn't work).
    if (preset && preset.tiles) {
      const TYPE_MAP = { cc7: CONST.PT_CC7, virtual: CONST.PT_VIRTUAL, nrpn: CONST.PT_NRPN, rpn: CONST.PT_RPN };
      const used = new Set();
      for (const st of tiles) {
        let pt = null;
        for (let k = 0; k < preset.tiles.length; k++) {
          if (used.has(k)) continue;
          if (preset.tiles[k].type !== st.type) continue;
          pt = preset.tiles[k];
          used.add(k);
          break;
        }
        if (!pt) continue;
        st.ref = pt.reference;
        st.name = pt.name;
        st.mode = pt.mode;
        // First value's message — type + parameterNumber are what the Lua compares
        const msg = pt.values && pt.values[0] && pt.values[0].message;
        if (msg) {
          st.msgType = TYPE_MAP[msg.type] ?? CONST.PT_CC7;
          st.msgParam = msg.parameterNumber ?? 0;
          st.msgMin = msg.min ?? 0;
          st.msgMax = msg.max ?? 127;
          st.msgOn  = msg.onValue  ?? 127;
          st.msgOff = msg.offValue ?? 0;
        }
        const vo = pt.values && pt.values[0];
        // Per-value Lua callback name (e.g. "xCcChanged")
        if (vo && typeof vo.function === "string") st.fnName = vo.function;
        // For list tiles, update the displayed value text to match defaultValue's label
        if (st.type === "list" && vo && Array.isArray(vo.textValues)) {
          st.textValues = vo.textValues;
          st.defaultValue = vo.defaultValue ?? vo.textValues[0]?.value;
        }
        // Link tile ↔ Control so widget code like `control:getValue():getMessage():setParameterNumber(cc)`
        // writes back to tile.msgParam (keeps parameterMap.set routing in sync).
        if (st.ref && !stage.controls[st.ref]) {
          const [x, y, w, h] = st.bounds;
          stage.controls[st.ref] = new Control(st.ref, stage, [x, y, w, h]);
        }
        if (st.ref && stage.controls[st.ref]) stage.controls[st.ref].tile = st;
      }
    }
    stage.nativeTiles = tiles;

    // For the custom tile, seed control bounds
    const custom = tiles.find(t => t.type === "custom");
    if (custom) {
      const [x, y, w, h] = custom.bounds;
      for (const id of [1, 4, 5, custom.ref].filter(Boolean)) {
        stage.controls[id] = new Control(id, stage, [x, y, w, h]);
      }
      logMsg(`Custom tile: ref=${custom.ref ?? "?"} bounds=${custom.bounds.join(",")}`, "info");
    }
  } catch (e) {
    logMsg("no preview.svg for background (ok for pure-Lua widgets): " + e.message, "info");
    document.getElementById("stage").style.backgroundImage = "none";
  }

  let code;
  try {
    code = await (await fetch(`${RAW_BASE}/widgets/${slug}/widget.lua`)).text();
  } catch (e) {
    logMsg("fetch lua err: " + e.message, "err");
    return;
  }
  // Strip attribution header comments (purely cosmetic)
  // (Lua handles -- comments natively, no need to strip)

  const L = lauxlib.luaL_newstate();
  lualib.luaL_openlibs(L);
  stage.L = L;
  setupEnv(L, stage);
  await runLua(L, code);

  // Build interactive overlays for native tiles
  createNativeTileOverlays(stage);

  // Initial sync: fire per-value callbacks for tiles with their default value,
  // so widgets that route CCs (cube-lfo's xCcChanged/yCcChanged) align fader
  // parameterNumbers with the list defaults before the first tick.
  for (const tile of stage.nativeTiles) {
    if (tile.fnName) {
      const v = stage.tileValues[tile.ref] ?? tile.defaultValue ?? 0;
      try { fireParameterChange(stage, tile, v); } catch (_) {}
    }
  }
  stage.paintAll();

  // Pointer → touch
  const toStage = (ev) => {
    const r = canvas.getBoundingClientRect();
    const sx = STAGE_W / r.width, sy = STAGE_H / r.height;
    return {
      x: Math.max(0, Math.min(STAGE_W, (ev.clientX - r.left) * sx)),
      y: Math.max(0, Math.min(STAGE_H, (ev.clientY - r.top) * sy)),
    };
  };
  const dispatch = (type, pt) => {
    for (const [id, cb] of Object.entries(stage.touchCbs)) {
      const ctrl = stage.controls[id];
      if (!ctrl) continue;
      const [x, y, w, h] = ctrl.bounds;
      if (pt.x >= x && pt.x < x + w && pt.y >= y && pt.y < y + h) {
        try { cb(ctrl, { id: 1, type, x: pt.x - x, y: pt.y - y }); }
        catch (e) { logMsg("touch err: " + e.message, "err"); }
      }
    }
  };
  let dragging = false;
  canvas.addEventListener("pointerdown", (ev) => { ev.preventDefault(); dragging = true; dispatch(CONST.DOWN, toStage(ev)); });
  canvas.addEventListener("pointermove", (ev) => { if (dragging) dispatch(CONST.MOVE, toStage(ev)); });
  canvas.addEventListener("pointerup",   (ev) => { dragging = false; dispatch(CONST.UP, toStage(ev)); });
  canvas.addEventListener("pointerleave",(ev) => { if (dragging) { dragging = false; dispatch(CONST.UP, toStage(ev)); } });

  document.getElementById("status").textContent = "✓ running";
}

async function boot() {
  console.log("[emulator] boot() starting");
  logMsg("boot() starting…", "info");
  try { initFengari(); }
  catch (e) {
    console.error("[emulator] initFengari failed", e);
    logMsg("initFengari failed: " + e.message, "err");
    return;
  }
  logMsg("Fengari loaded.", "info");

  // populate widgets
  let ws = [];
  try {
    ws = await (await fetch("../widgets.json")).json();
  } catch (e) {
    logMsg("widgets.json fetch err: " + e.message, "err");
  }
  const sel = document.getElementById("widget-select");
  sel.innerHTML = "";
  ws.forEach(w => {
    const o = document.createElement("option");
    o.value = w.slug;
    o.textContent = w.name;
    sel.appendChild(o);
  });
  const params = new URLSearchParams(location.search);
  const wanted = params.get("w") || "xypad";           // xypad = known-working default
  if ([...sel.options].some(o => o.value === wanted)) sel.value = wanted;
  sel.addEventListener("change", () => { location.search = "?w=" + sel.value; });
  document.getElementById("reload").addEventListener("click", () => location.reload());

  await loadWidget(sel.value);
}

// Boot when both Fengari UMD and this file are ready
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", boot);
} else {
  boot();
}
