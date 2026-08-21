const { spawn } = require("child_process");
const fs = require("fs");
const path = require("path");

const root = process.cwd();
const apiDir = path.join(root, "artifacts", "api-server");
const frontDir = path.join(root, "artifacts", "firat-gida");

function run(name, cmd, cwd) {
  console.log(`\n[Arya Gross] ${name} başlıyor`);
  console.log(`[Arya Gross] ${cmd}`);
  const child = spawn(cmd, {
    cwd,
    shell: true,
    stdio: "inherit",
    env: {
      ...process.env,
      NODE_ENV: "development",
      PORT: process.env.PORT || "3001",
      HOST: "0.0.0.0",
      VITE_API_URL: process.env.VITE_API_URL || "http://localhost:3001"
    }
  });
  child.on("exit", (code) => console.log(`[Arya Gross] ${name} çıktı: ${code}`));
  return child;
}

if (!fs.existsSync(apiDir)) {
  console.error("HATA: Backend klasörü yok:", apiDir);
  process.exit(1);
}

if (!fs.existsSync(frontDir)) {
  console.error("HATA: Frontend klasörü yok:", frontDir);
  process.exit(1);
}

run("Backend API", "pnpm run build && pnpm run start", apiDir);

setTimeout(() => {
  run("Frontend Web", "pnpm run dev -- --host 0.0.0.0 --port 18733", frontDir);
}, 3000);
