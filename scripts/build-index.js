#!/usr/bin/env node
// Scan widgets/* folders, extract name + first-line description from README.md,
// copy preview.png to docs/previews/, and emit docs/widgets.json.

const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const WIDGETS = path.join(ROOT, "widgets");
const DOCS = path.join(ROOT, "docs");
const PREVIEWS = path.join(DOCS, "previews");

fs.mkdirSync(PREVIEWS, { recursive: true });

const entries = fs.readdirSync(WIDGETS, { withFileTypes: true })
  .filter(d => d.isDirectory() && !d.name.startsWith("_"))
  .map(d => {
    const slug = d.name;
    const dir = path.join(WIDGETS, slug);
    const readme = path.join(dir, "README.md");
    let name = slug, description = "";
    if (fs.existsSync(readme)) {
      const lines = fs.readFileSync(readme, "utf8").split("\n");
      const h1 = lines.find(l => l.startsWith("# "));
      if (h1) name = h1.slice(2).trim();
      const firstPara = lines.find(l => l.trim() && !l.startsWith("#") && !l.startsWith("!"));
      if (firstPara) description = firstPara.trim();
    }
    const preview = path.join(dir, "preview.png");
    if (fs.existsSync(preview)) {
      fs.copyFileSync(preview, path.join(PREVIEWS, `${slug}.png`));
    }
    return { slug, name, description };
  });

fs.writeFileSync(
  path.join(DOCS, "widgets.json"),
  JSON.stringify(entries, null, 2) + "\n"
);
console.log(`Indexed ${entries.length} widget(s).`);
