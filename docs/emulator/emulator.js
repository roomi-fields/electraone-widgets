// Electra One widget emulator — phase 1: xypad-class widgets
// Runs Lua via Fengari, stubs the Electra runtime (graphics, controls, events).
// Not a faithful emulator — covers what the curated widgets in this repo actually use.

const CONST = {
  WIDTH: 2, HEIGHT: 3,         // getBounds returns [x,y,w,h], Lua code reads b[WIDTH]/b[HEIGHT]
  LEFT: 0, RIGHT: 1, CENTER: 2,
  DOWN: 1, MOVE: 2, UP: 3, CLICK: 4, LONG_HOLD: 5, HOLD: 6,
  PT_CC7: 1, PT_VIRTUAL: 2, PT_NRPN: 3, PT_RPN: 4,
  PORT_1: 1, PORT_2: 2, PORT_CTRL: 3,
  MODEL_MK2: "mk2",
  // Colors Martin uses in his demos (Component(id, COLOR, ...))
  RED: 0xFF0000, GREEN: 0x00FF00, BLUE: 0x0000FF, YELLOW: 0xFFFF00,
  PURPLE: 0xB14AE0, ORANGE: 0xFF8A1F, WHITE: 0xFFFFFF, BLACK: 0x000000,
};

const STAGE_W = 1016, STAGE_H = 560;

function logMsg(s, err = false) {
  const log = document.getElementById("log");
  const line = document.createElement("div");
  if (err) line.className = "err";
  line.textContent = s;
  log.appendChild(line);
  log.scrollTop = log.scrollHeight;
}

// ============ Canvas drawing primitives ============

class Stage {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext("2d");
    this.controls = {};         // id → Control
    this.paintCbs = {};         // id → Lua function (paint)
    this.touchCbs = {};         // id → Lua function
    this.potCbs   = {};         // id → Lua function
    this.currentColor = 0xFFFFFF;
    this.currentControl = null;
    this.dirty = true;
  }

  hexColor(c) {
    return "#" + ("000000" + (c >>> 0).toString(16)).slice(-6);
  }

  paintAll() {
    this.ctx.fillStyle = "#000";
    this.ctx.fillRect(0, 0, STAGE_W, STAGE_H);
    for (const id of Object.keys(this.paintCbs)) {
      this.paintOne(id);
    }
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
    this.currentControl = ctrl;
    try {
      cb(ctrl);
    } catch (e) {
      logMsg("paint error: " + e.message, true);
    }
    this.ctx.restore();
  }
}

// ============ Control object (userdata) ============

class Control {
  constructor(id, stage, bounds) {
    this.id = id;
    this.stage = stage;
    this.bounds = bounds.slice(); // [x,y,w,h]
    this.value = 0;
  }
  getBounds() {
    // return a Lua-table-like object that, when indexed with WIDTH/HEIGHT, returns w/h
    const [x, y, w, h] = this.bounds;
    const arr = { 0: x, 1: y, 2: w, 3: h };
    // also support .width / .height access
    arr.width = w; arr.height = h;
    arr.x = x; arr.y = y;
    return arr;
  }
  setBounds(b) {
    // accept either {1:x,2:y,3:w,4:h} (lua table) or array [x,y,w,h]
    const x = b[0] ?? b[1] ?? b.x ?? this.bounds[0];
    const y = b[1] ?? b[2] ?? b.y ?? this.bounds[1];
    const w = b[2] ?? b[3] ?? b.width ?? this.bounds[2];
    const h = b[3] ?? b[4] ?? b.height ?? this.bounds[3];
    this.bounds = [x, y, w, h];
    this.stage.dirty = true;
  }
  setPaintCallback(fn) { this.stage.paintCbs[this.id] = fn; }
  setTouchCallback(fn) { this.stage.touchCbs[this.id] = fn; }
  setPotCallback(fn)   { this.stage.potCbs[this.id]   = fn; }
  setValue(v) { this.value = v; }
  getValue() { return { getDefault: () => 0 }; }
  setColor() {}
  setLabel() {}
  setName() {}
  setVisible() {}
  setSlot() {}
  getId() { return this.id; }
  repaint() { this.stage.paintOne(this.id); }
}

// ============ Lua environment setup ============

async function loadLua(L, luaCode, stage) {
  const { lua, lauxlib, to_luastring } = window.__LUA__;

  // Push constants as globals
  for (const [k, v] of Object.entries(CONST)) {
    if (typeof v === "number") lua.lua_pushnumber(L, v);
    else lua.lua_pushstring(L, to_luastring(v));
    lua.lua_setglobal(L, to_luastring(k));
  }

  // graphics module
  const g = {
    setColor: (c) => { stage.currentColor = c; stage.ctx.fillStyle = stage.ctx.strokeStyle = stage.hexColor(c); },
    fillRect: (x, y, w, h) => stage.ctx.fillRect(x, y, w, h),
    drawRect: (x, y, w, h) => stage.ctx.strokeRect(x, y, w, h),
    fillCircle: (cx, cy, r) => { stage.ctx.beginPath(); stage.ctx.arc(cx, cy, r, 0, Math.PI * 2); stage.ctx.fill(); },
    drawCircle: (cx, cy, r) => { stage.ctx.beginPath(); stage.ctx.arc(cx, cy, r, 0, Math.PI * 2); stage.ctx.stroke(); },
    drawLine: (x1, y1, x2, y2) => { stage.ctx.beginPath(); stage.ctx.moveTo(x1, y1); stage.ctx.lineTo(x2, y2); stage.ctx.stroke(); },
    print: (x, y, text, size, _align) => {
      stage.ctx.font = `${size || 10}px 'Open Sans', sans-serif`;
      stage.ctx.textBaseline = "top";
      stage.ctx.fillText(String(text ?? ""), x, y);
    },
    setPixel: (x, y) => stage.ctx.fillRect(x, y, 1, 1),
    drawPixel: (x, y) => stage.ctx.fillRect(x, y, 1, 1),
  };
  pushJSObject(L, g);
  lua.lua_setglobal(L, to_luastring("graphics"));

  // controls module
  const controls = {
    get: (id) => {
      if (!stage.controls[id]) {
        // lazy create a full-stage control if not registered
        stage.controls[id] = new Control(id, stage, [0, 0, STAGE_W, STAGE_H]);
      }
      return stage.controls[id];
    },
  };
  pushJSObject(L, controls);
  lua.lua_setglobal(L, to_luastring("controls"));

  // devices module (stub)
  const devices = {
    get: () => ({
      getPort: () => CONST.PORT_1,
      getChannel: () => 1,
      getId: () => 1,
    }),
  };
  pushJSObject(L, devices);
  lua.lua_setglobal(L, to_luastring("devices"));

  // parameterMap (stub)
  const parameterMap = {
    get: () => 0, set: () => {}, send: () => {},
  };
  pushJSObject(L, parameterMap);
  lua.lua_setglobal(L, to_luastring("parameterMap"));

  // midi (stub)
  const midi = {
    sendControlChange: () => {}, sendNoteOn: () => {}, sendNoteOff: () => {},
    sendSysex: () => {}, sendProgramChange: () => {}, sendPitchBend: () => {},
    onControlChange: null, onNoteOn: null, onNoteOff: null,
  };
  pushJSObject(L, midi);
  lua.lua_setglobal(L, to_luastring("midi"));

  // timer (stub, no-op in phase 1)
  const timer = {
    enable: () => {}, disable: () => {}, setPeriod: () => {}, setBpm: () => {},
    onTick: null,
  };
  pushJSObject(L, timer);
  lua.lua_setglobal(L, to_luastring("timer"));

  // preset (table holding onLoad)
  lua.lua_createtable(L, 0, 1);
  lua.lua_setglobal(L, to_luastring("preset"));

  // window (Ephemera-style API)
  const win = {
    addAndMakeVisible: () => {}, repaint: () => stage.paintAll(),
  };
  pushJSObject(L, win);
  lua.lua_setglobal(L, to_luastring("window"));

  // print → log
  lua.lua_pushjsfunction(L, (L) => {
    const n = lua.lua_gettop(L);
    const parts = [];
    for (let i = 1; i <= n; i++) parts.push(luaToJS(L, i));
    logMsg("[lua] " + parts.join("\t"));
    return 0;
  });
  lua.lua_setglobal(L, to_luastring("print"));

  // controller.isRequired (xt-envelopes) — always pass
  lua.lua_createtable(L, 0, 1);
  lua.lua_pushjsfunction(L, (L) => { lua.lua_pushboolean(L, 1); return 1; });
  lua.lua_setfield(L, -2, to_luastring("isRequired"));
  lua.lua_setglobal(L, to_luastring("controller"));

  // info (stub)
  pushJSObject(L, { setText: () => {} });
  lua.lua_setglobal(L, to_luastring("info"));

  // Load + run Lua
  const luaBytes = to_luastring(luaCode);
  const status = lauxlib.luaL_loadbuffer(L, luaBytes, luaBytes.length, to_luastring("=widget"));
  if (status !== 0) {
    logMsg("load err: " + to_jsstring(lua.lua_tostring(L, -1)), true);
    return;
  }
  if (lua.lua_pcall(L, 0, 0, 0) !== 0) {
    logMsg("run err: " + to_jsstring(lua.lua_tostring(L, -1)), true);
    return;
  }

  // Call preset.onLoad if defined
  lua.lua_getglobal(L, to_luastring("preset"));
  lua.lua_getfield(L, -1, to_luastring("onLoad"));
  if (lua.lua_isfunction(L, -1)) {
    if (lua.lua_pcall(L, 0, 0, 0) !== 0) {
      logMsg("onLoad err: " + to_jsstring(lua.lua_tostring(L, -1)), true);
    }
  } else {
    lua.lua_pop(L, 1);
  }
  lua.lua_pop(L, 1);
}

// Helper: convert a Lua value at stack index to a JS value
function luaToJS(L, i) {
  const { lua, to_jsstring } = window.__LUA__;
  const t = lua.lua_type(L, i);
  if (t === lua.LUA_TSTRING)  return to_jsstring(lua.lua_tostring(L, i));
  if (t === lua.LUA_TNUMBER)  return lua.lua_tonumber(L, i);
  if (t === lua.LUA_TBOOLEAN) return Boolean(lua.lua_toboolean(L, i));
  if (t === lua.LUA_TNIL)     return null;
  return "<" + lua.lua_typename(L, t) + ">";
}

// Helper: push a JS object as a Lua table (functions become Lua functions)
function pushJSObject(L, obj) {
  const { lua, to_luastring } = window.__LUA__;
  lua.lua_createtable(L, 0, Object.keys(obj).length);
  for (const [k, v] of Object.entries(obj)) {
    if (typeof v === "function") {
      lua.lua_pushjsfunction(L, (L) => {
        const n = lua.lua_gettop(L);
        const args = [];
        for (let i = 1; i <= n; i++) args.push(luaToJSAny(L, i));
        const ret = v.apply(null, args);
        if (ret === undefined || ret === null) return 0;
        pushJSValue(L, ret);
        return 1;
      });
    } else if (typeof v === "number") {
      lua.lua_pushnumber(L, v);
    } else if (typeof v === "string") {
      lua.lua_pushstring(L, to_luastring(v));
    } else if (typeof v === "boolean") {
      lua.lua_pushboolean(L, v ? 1 : 0);
    } else if (v && typeof v === "object") {
      pushJSObject(L, v);
    } else {
      lua.lua_pushnil(L);
    }
    lua.lua_setfield(L, -2, to_luastring(k));
  }
}

function pushJSValue(L, v) {
  const { lua, to_luastring } = window.__LUA__;
  if (typeof v === "number") lua.lua_pushnumber(L, v);
  else if (typeof v === "string") lua.lua_pushstring(L, to_luastring(v));
  else if (typeof v === "boolean") lua.lua_pushboolean(L, v ? 1 : 0);
  else if (v && typeof v === "object") pushUserdata(L, v);
  else lua.lua_pushnil(L);
}

// Wrap a JS object as Lua userdata with metatable providing method access
function pushUserdata(L, obj) {
  const { lua, to_luastring } = window.__LUA__;
  // Simple approach: push as a table with methods
  lua.lua_createtable(L, 0, 0);
  const tableIdx = lua.lua_gettop(L);

  // Metatable with __index that calls methods on the JS object
  lua.lua_createtable(L, 0, 1);
  lua.lua_pushjsfunction(L, (L) => {
    const key = to_jsstring(lua.lua_tostring(L, 2));
    if (typeof obj[key] === "function") {
      lua.lua_pushjsfunction(L, (L) => {
        const n = lua.lua_gettop(L);
        const args = [];
        for (let i = 2; i <= n; i++) args.push(luaToJSAny(L, i));   // skip `self` (arg 1)
        const ret = obj[key].apply(obj, args);
        if (ret === undefined || ret === null) return 0;
        pushJSValue(L, ret);
        return 1;
      });
      return 1;
    }
    if (key in obj) {
      pushJSValue(L, obj[key]);
      return 1;
    }
    lua.lua_pushnil(L);
    return 1;
  });
  lua.lua_setfield(L, -2, to_luastring("__index"));
  lua.lua_setmetatable(L, tableIdx);
}

// Convert Lua value to any JS value (including tables as arrays/objects)
function luaToJSAny(L, i) {
  const { lua, to_jsstring } = window.__LUA__;
  const t = lua.lua_type(L, i);
  if (t === lua.LUA_TSTRING)  return to_jsstring(lua.lua_tostring(L, i));
  if (t === lua.LUA_TNUMBER)  return lua.lua_tonumber(L, i);
  if (t === lua.LUA_TBOOLEAN) return Boolean(lua.lua_toboolean(L, i));
  if (t === lua.LUA_TNIL)     return null;
  if (t === lua.LUA_TTABLE) {
    // Convert table to JS object, handling 1-based arrays
    const obj = {};
    lua.lua_pushnil(L);
    const abs = lua.lua_absindex(L, i);
    while (lua.lua_next(L, abs) !== 0) {
      const k = luaToJSAny(L, -2);
      const v = luaToJSAny(L, -1);
      obj[k] = v;
      lua.lua_pop(L, 1);
    }
    return obj;
  }
  if (t === lua.LUA_TFUNCTION) {
    // Return a JS callable that invokes the Lua function
    const ref = lauxlib.luaL_ref(L, lua.LUA_REGISTRYINDEX);
    return function (...args) {
      lua.lua_rawgeti(L, lua.LUA_REGISTRYINDEX, ref);
      for (const a of args) pushJSValue(L, a);
      if (lua.lua_pcall(L, args.length, 0, 0) !== 0) {
        logMsg("cb err: " + to_jsstring(lua.lua_tostring(L, -1)), true);
        lua.lua_pop(L, 1);
      }
    };
  }
  return null;
}

// ============ Widget loader ============

async function fetchText(url) {
  const r = await fetch(url);
  if (!r.ok) throw new Error(`${url}: ${r.status}`);
  return r.text();
}

async function loadWidget(slug) {
  const log = document.getElementById("log");
  log.innerHTML = "";
  logMsg(`Loading widget: ${slug}`);

  const canvas = document.getElementById("canvas");
  const stage = new Stage(canvas);

  // Register tile 1 at full screen by default (most custom widgets use ref=1 and setBounds)
  stage.controls[1] = new Control(1, stage, [0, 0, STAGE_W, STAGE_H]);
  stage.controls[4] = new Control(4, stage, [0, 0, STAGE_W, STAGE_H]);
  stage.controls[5] = new Control(5, stage, [0, 0, STAGE_W, STAGE_H]);

  const lua = await fetchText(`../../widgets/${slug}/widget.lua`);

  const L = lauxlib.luaL_newstate();
  lualib.luaL_openlibs(L);
  await loadLua(L, lua, stage);
  stage.paintAll();

  // Wire touch
  const toStage = (ev) => {
    const r = canvas.getBoundingClientRect();
    const sx = STAGE_W / r.width, sy = STAGE_H / r.height;
    return {
      x: Math.max(0, Math.min(STAGE_W, (ev.clientX - r.left) * sx)),
      y: Math.max(0, Math.min(STAGE_H, (ev.clientY - r.top) * sy)),
    };
  };
  const dispatchTouch = (type, pt) => {
    for (const [id, cb] of Object.entries(stage.touchCbs)) {
      const ctrl = stage.controls[id];
      if (!ctrl) continue;
      const [x, y, w, h] = ctrl.bounds;
      if (pt.x >= x && pt.x < x + w && pt.y >= y && pt.y < y + h) {
        try {
          cb(ctrl, { type, x: pt.x - x, y: pt.y - y });
        } catch (e) { logMsg("touch err: " + e.message, true); }
      }
    }
  };
  let dragging = false;
  canvas.addEventListener("pointerdown", (ev) => { dragging = true; dispatchTouch(CONST.DOWN, toStage(ev)); });
  canvas.addEventListener("pointermove", (ev) => { if (dragging) dispatchTouch(CONST.MOVE, toStage(ev)); });
  canvas.addEventListener("pointerup",   (ev) => { dragging = false; dispatchTouch(CONST.UP, toStage(ev)); });

  document.getElementById("status").textContent = "✓ running";
}

// ============ Boot ============

const { lua, lauxlib, lualib, to_luastring, to_jsstring } = {};

export async function boot() {
  // Populate widget dropdown from widgets.json
  const ws = await (await fetch("../widgets.json")).json();
  const sel = document.getElementById("widget-select");
  ws.forEach(w => {
    const o = document.createElement("option");
    o.value = w.slug;
    o.textContent = w.name;
    sel.appendChild(o);
  });
  const params = new URLSearchParams(location.search);
  if (params.get("w")) sel.value = params.get("w");
  sel.addEventListener("change", () => { location.search = "?w=" + sel.value; });
  document.getElementById("reload").addEventListener("click", () => location.reload());

  // Expose deps for emulator module
  Object.assign(window, window.__LUA__);

  await loadWidget(sel.value || "xypad");
}
