// Capture a PNG of a widget running in the browser emulator.
// Usage: node scripts/screenshot.mjs <slug> [--wait=ms] [--url=http://localhost:8765/emulator/] [--remote]
//
// By default, fetches for raw.githubusercontent.com/roomi-fields/electraone-widgets/main/*
// are intercepted and served from the local working copy — so you can preview
// un-pushed edits without waiting for a commit. Pass --remote to fetch from
// the actual GitHub raw origin (what users see online).
import { chromium } from "playwright";
import { mkdirSync, existsSync } from "node:fs";
import { readFile } from "node:fs/promises";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, "..");
const args = process.argv.slice(2);
const slug = args.find(a => !a.startsWith("--")) || "cube-lfo";
const waitMs = Number((args.find(a => a.startsWith("--wait=")) || "--wait=1500").split("=")[1]);
const baseUrl = (args.find(a => a.startsWith("--url=")) || "--url=http://localhost:8765/emulator/").split("=")[1];
const useRemote = args.includes("--remote");

// Canonical preview lives with the widget source; build-index copies it to docs/previews/.
const outDir = resolve(__dirname, "..", "widgets", slug);
mkdirSync(outDir, { recursive: true });
const outPath = resolve(outDir, "preview.png");

const browser = await chromium.launch();
const context = await browser.newContext({ viewport: { width: 1060, height: 620 } });
const page = await context.newPage();
// Disable the browser cache entirely via CDP so every widget.lua /
// lib/*.lua fetch hits the origin — GitHub raw (Fastly) sends max-age=300
// and route.continue doesn't bypass the disk cache on its own.
const cdp = await context.newCDPSession(page);
await cdp.send("Network.setCacheDisabled", { cacheDisabled: true });
page.on("pageerror", (e) => console.error("page err:", e.message));

// Intercept raw.githubusercontent requests and serve from the local working
// copy (unless --remote was passed). Lets us iterate without commit/push.
if (!useRemote) {
  const REPO_URL_PREFIX = "/roomi-fields/electraone-widgets/main/";
  await context.route("https://raw.githubusercontent.com/**", async (route) => {
    const url = new URL(route.request().url());
    if (!url.pathname.startsWith(REPO_URL_PREFIX)) return route.continue();
    const relPath = url.pathname.slice(REPO_URL_PREFIX.length);
    const localPath = resolve(REPO_ROOT, relPath);
    if (!existsSync(localPath)) return route.fulfill({ status: 404 });
    const body = await readFile(localPath);
    const contentType = relPath.endsWith(".json") ? "application/json"
      : relPath.endsWith(".lua") ? "text/plain"
      : "application/octet-stream";
    return route.fulfill({ status: 200, contentType, body });
  });
  console.log("local-first mode: serving raw.github requests from", REPO_ROOT);
}

await page.goto(`${baseUrl}?w=${slug}&t=${Date.now()}`, { waitUntil: "networkidle" });
// Give the Lua timer a beat so animations (cube-lfo) leave their t=0 pose.
// cube-lfo needs angular speed > 0 to spin — drive virtual params 11/12 via a
// synthetic onChange so the shot shows the cube mid-rotation.
await page.evaluate(() => {
  const stage = window.__stage;
  if (!stage || !stage.L) return;
  // Poke stepX / stepY on cubeControl directly so the cube tilts visibly
  const ctrl = stage.controls && stage.controls[1];
  if (ctrl) { ctrl.stepX = 0.04; ctrl.stepY = 0.025; ctrl.angleX = 0.6; ctrl.angleY = 0.9; }
});
await page.waitForTimeout(waitMs);
await page.locator("#stage").screenshot({ path: outPath });
await browser.close();
console.log("wrote", outPath);
