// Capture a PNG of a widget running in the browser emulator.
// Usage: node scripts/screenshot.mjs <slug> [--wait=ms] [--url=http://localhost:8765/emulator/]
import { chromium } from "playwright";
import { mkdirSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const args = process.argv.slice(2);
const slug = args.find(a => !a.startsWith("--")) || "cube-lfo";
const waitMs = Number((args.find(a => a.startsWith("--wait=")) || "--wait=1500").split("=")[1]);
const baseUrl = (args.find(a => a.startsWith("--url=")) || "--url=http://localhost:8765/emulator/").split("=")[1];

// Canonical preview lives with the widget source; build-index copies it to docs/previews/.
const outDir = resolve(__dirname, "..", "widgets", slug);
mkdirSync(outDir, { recursive: true });
const outPath = resolve(outDir, "preview.png");

const browser = await chromium.launch();
const context = await browser.newContext({ viewport: { width: 1060, height: 620 } });
// Bypass HTTP cache so freshly-pushed widget.lua / lib files are fetched.
await context.route("**/*", (route) => {
  const headers = { ...route.request().headers(), "cache-control": "no-cache", "pragma": "no-cache" };
  route.continue({ headers });
});
const page = await context.newPage();
page.on("pageerror", (e) => console.error("page err:", e.message));

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
