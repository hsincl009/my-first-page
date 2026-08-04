# ============================================================
#  90 分鐘工作坊 - 一鍵安裝
#  請不要直接執行本檔，改用「雙擊 install.bat」。
#  本檔會自動要求管理員權限，並安裝：
#    Git / Node.js LTS / GitHub CLI / netlify-cli
# ============================================================

# --- 若不是管理員，自動重新以管理員身分啟動自己 ---
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin  = (New-Object Security.Principal.WindowsPrincipal $identity).IsInRole(
                [Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "需要管理員權限，正在重新啟動…" -ForegroundColor Yellow
    Write-Host "接下來會跳出「是否允許此應用程式變更您的裝置」，請按【是】。" -ForegroundColor Yellow
    try {
        Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList @(
            "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$PSCommandPath`""
        )
    } catch {
        Write-Host ""
        Write-Host "你按了【否】，或這台電腦不允許提升權限。" -ForegroundColor Red
        Write-Host "請把這個畫面截圖傳給講者。" -ForegroundColor Red
        Read-Host "按 Enter 關閉"
    }
    exit
}

$ErrorActionPreference = 'Continue'

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  工作坊一鍵安裝" -ForegroundColor Cyan
Write-Host "  全程約 5-15 分鐘，請不要關閉這個視窗。" -ForegroundColor Cyan
Write-Host "  中途畫面會跑很多字，那是正常的。" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# --- 檢查 winget 是否存在 ---
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "這台電腦沒有 winget（Windows 版本較舊）。" -ForegroundColor Red
    Write-Host "請改用手動安裝，到下面兩個網址下載安裝檔，一路按下一步：" -ForegroundColor Yellow
    Write-Host "  Git      https://git-scm.com/download/win"
    Write-Host "  Node.js  https://nodejs.org  （選左邊的 LTS）"
    Write-Host "  GitHub CLI  https://cli.github.com"
    Write-Host "裝完後請把這個畫面截圖傳給講者。" -ForegroundColor Yellow
    Read-Host "按 Enter 關閉"
    exit
}

# --- 逐一安裝 ---
$packages = @(
    @{ Name = "Git";        Id = "Git.Git" },
    @{ Name = "Node.js LTS"; Id = "OpenJS.NodeJS.LTS" },
    @{ Name = "GitHub CLI";  Id = "GitHub.cli" }
)

foreach ($p in $packages) {
    Write-Host ("--- 正在安裝 {0} ---" -f $p.Name) -ForegroundColor Cyan
    winget install --id $p.Id -e --source winget `
        --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Host ("    {0} 安裝完成" -f $p.Name) -ForegroundColor Green
    } else {
        # winget 對「已安裝」也會回非 0，所以這裡不當成失敗
        Write-Host ("    {0}：winget 回報代碼 {1}（若原本就已安裝，這是正常的）" -f $p.Name, $LASTEXITCODE) -ForegroundColor Yellow
    }
    Write-Host ""
}

# --- 刷新 PATH，讓這個視窗馬上找得到剛裝好的 node / npm ---
Write-Host "--- 正在重新載入環境變數 ---" -ForegroundColor Cyan
$machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$userPath    = [Environment]::GetEnvironmentVariable('Path', 'User')
$env:Path    = "$machinePath;$userPath"
Write-Host ""

# --- 安裝 netlify-cli（需要 npm）---
Write-Host "--- 正在安裝 netlify-cli ---" -ForegroundColor Cyan
if (Get-Command npm -ErrorAction SilentlyContinue) {
    npm install -g netlify-cli
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    netlify-cli 安裝完成" -ForegroundColor Green
    } else {
        Write-Host "    netlify-cli 安裝失敗，請把畫面截圖傳給講者。" -ForegroundColor Red
    }
} else {
    Write-Host "    找不到 npm。請關閉本視窗，重新雙擊 install.bat 再跑一次。" -ForegroundColor Red
    Write-Host "    （Node.js 剛裝好，有時要重開才會生效。）" -ForegroundColor Yellow
}

Write-Host ""

# --- 安裝 Kiro CLI ---
Write-Host "--- 正在安裝 Kiro CLI ---" -ForegroundColor Cyan
try {
    Invoke-Expression (Invoke-RestMethod 'https://cli.kiro.dev/install.ps1')
    Write-Host "    Kiro CLI 安裝完成" -ForegroundColor Green
} catch {
    Write-Host "    Kiro CLI 安裝失敗（可能是網路問題），請把畫面截圖傳給講者。" -ForegroundColor Red
    Write-Host "    也可以之後手動執行：irm 'https://cli.kiro.dev/install.ps1' | iex" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  軟體安裝結束" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "還有四件事必須你自己做（安裝程式沒辦法幫你登入）：" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. 告訴 Git 你是誰 —— 開一個新的終端機，貼上這兩行（改成你自己的）："
Write-Host '       git config --global user.name  "Your Name"' -ForegroundColor White
Write-Host '       git config --global user.email "you@example.com"' -ForegroundColor White
Write-Host ""
Write-Host "  2. 登入 GitHub ——  打 " -NoNewline; Write-Host "gh auth login" -ForegroundColor White
Write-Host "       依序選 GitHub.com -> HTTPS -> Y -> Login with a web browser"
Write-Host ""
Write-Host "  3. 登入 Netlify ——  打 " -NoNewline; Write-Host "netlify login" -ForegroundColor White
Write-Host "       瀏覽器跳出後按 Authorize"
Write-Host ""
Write-Host "  4. 登入 Kiro ——  打 " -NoNewline; Write-Host "kiro" -ForegroundColor White
Write-Host "       瀏覽器跳出後選 Google、GitHub 或 Builder ID 任一登入"
Write-Host ""
Write-Host "全部做完，執行 check-env.ps1 確認全綠，然後截圖傳給講者。" -ForegroundColor Cyan
Write-Host "怎麼開終端機、怎麼貼上，請看【終端機生存卡】。" -ForegroundColor Cyan
Write-Host ""
Read-Host "按 Enter 關閉這個視窗"
