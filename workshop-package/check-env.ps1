# ============================================================
#  90 分鐘工作坊 - 課前環境自檢
#  用法：在 PowerShell 視窗中執行   .\check-env.ps1
#  全部顯示 [OK] 才算完成課前準備。
#
#  注意：本腳本對所有可能卡住的指令都設有逾時保護，
#        最久不會超過約 2 分鐘就一定會跑完。
# ============================================================

$ErrorActionPreference = 'SilentlyContinue'
$script:pass = $true

# --- 逾時保護：外部指令最多等 $Seconds 秒，逾時回傳 $null ---
#     刻意不使用 Start-Job／Wait-Job：那組指令在子行程卡死時，
#     連 Stop-Job 與 Remove-Job -Force 自己都會一起卡住。
function Invoke-WithTimeout {
    param([string]$Command, [int]$Seconds = 15)
    $tag     = [guid]::NewGuid().ToString('N')
    $outFile = Join-Path $env:TEMP ("chk_o_$tag.txt")
    $errFile = Join-Path $env:TEMP ("chk_e_$tag.txt")

    try {
        $proc = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $Command `
                    -NoNewWindow -PassThru `
                    -RedirectStandardOutput $outFile -RedirectStandardError $errFile
    } catch {
        return $null
    }

    if ($proc.WaitForExit($Seconds * 1000)) {
        $text = Get-Content $outFile -ErrorAction SilentlyContinue |
                    Where-Object { $_ -match '\S' } | Select-Object -First 1
        $code = $proc.ExitCode
        Remove-Item $outFile, $errFile -Force -ErrorAction SilentlyContinue
        return [PSCustomObject]@{ Text = $text; Code = $code }
    }

    # 逾時：連同子行程一併結束，不留下卡住的 node 行程
    # taskkill 的 SUCCESS 訊息一律導向暫存檔，避免嚇到學員
    $killFile = Join-Path $env:TEMP ("chk_k_$tag.txt")
    Start-Process -FilePath "taskkill.exe" -ArgumentList "/T", "/F", "/PID", $proc.Id `
        -NoNewWindow -Wait -ErrorAction SilentlyContinue `
        -RedirectStandardOutput $killFile -RedirectStandardError "$killFile.err"
    Remove-Item $outFile, $errFile, $killFile, "$killFile.err" -Force -ErrorAction SilentlyContinue
    return $null
}

# --- 快速工具檢查（git / node / gh 都是一般執行檔，不會卡住）---
function Test-Tool {
    param($Label, $Cmd, $Fix)
    if (Get-Command $Cmd -ErrorAction SilentlyContinue) {
        $ver = & $Cmd --version | Select-Object -First 1
        Write-Host ("  [OK]   {0,-9} {1}" -f $Label, $ver) -ForegroundColor Green
        return $true
    }
    Write-Host ("  [缺少] {0,-9} 修正指令：{1}" -f $Label, $Fix) -ForegroundColor Red
    $script:pass = $false
    return $false
}

Write-Host ""
Write-Host "== 1. 五項工具 ==" -ForegroundColor Cyan
Test-Tool "git"  "git"  "winget install --id Git.Git -e --source winget"        | Out-Null
Test-Tool "node" "node" "winget install --id OpenJS.NodeJS.LTS -e --source winget" | Out-Null
Test-Tool "gh"   "gh"   "winget install --id GitHub.cli -e --source winget"     | Out-Null

# netlify 由 npm 安裝，啟動較慢且可能等待輸入，因此加逾時保護
if (Get-Command netlify -ErrorAction SilentlyContinue) {
    Write-Host "         （正在檢查 netlify，約需 10 秒，請稍候…）" -ForegroundColor DarkGray
    $nv = Invoke-WithTimeout "netlify --version" 15
    if ($nv) {
        Write-Host ("  [OK]   {0,-9} {1}" -f "netlify", $nv.Text) -ForegroundColor Green
    } else {
        Write-Host ("  [逾時] {0,-9} 已安裝但無回應。請自己開一個 PowerShell 手動執行：netlify --version" -f "netlify") -ForegroundColor Yellow
        Write-Host  "           若手動執行正常就不用理會這一項。" -ForegroundColor Yellow
    }
} else {
    Write-Host ("  [缺少] {0,-9} 修正指令：npm install -g netlify-cli" -f "netlify") -ForegroundColor Red
    $script:pass = $false
}

# kiro-cli 檢查
if (Get-Command kiro -ErrorAction SilentlyContinue) {
    $kv = Invoke-WithTimeout "kiro --version" 10
    if ($kv) {
        Write-Host ("  [OK]   {0,-9} {1}" -f "kiro", $kv.Text) -ForegroundColor Green
    } else {
        Write-Host ("  [逾時] {0,-9} 已安裝但無回應，忽略即可。" -f "kiro") -ForegroundColor Yellow
    }
} else {
    Write-Host ("  [缺少] {0,-9} 修正指令：irm 'https://cli.kiro.dev/install.ps1' | iex" -f "kiro") -ForegroundColor Red
    $script:pass = $false
}

Write-Host ""
Write-Host "== 2. Git 知道你是誰 ==" -ForegroundColor Cyan
$gitName  = git config --global user.name
$gitEmail = git config --global user.email
if ($gitName -and $gitEmail) {
    Write-Host ("  [OK]   {0} <{1}>" -f $gitName, $gitEmail) -ForegroundColor Green
} else {
    Write-Host "  [缺少] 請執行下面兩行（換成你自己的名字與 email）：" -ForegroundColor Red
    Write-Host '           git config --global user.name  "Your Name"'
    Write-Host '           git config --global user.email "you@example.com"'
    $script:pass = $false
}

Write-Host ""
Write-Host "== 3. GitHub 已登入 ==" -ForegroundColor Cyan
if (Get-Command gh -ErrorAction SilentlyContinue) {
    $null = gh auth token
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK]   gh 已完成登入" -ForegroundColor Green
    } else {
        Write-Host "  [缺少] 請執行：gh auth login" -ForegroundColor Red
        Write-Host "           依序選 GitHub.com -> HTTPS -> Y -> Login with a web browser"
        $script:pass = $false
    }
} else {
    Write-Host "  [跳過] gh 尚未安裝" -ForegroundColor Red
}

Write-Host ""
Write-Host "== 4. Netlify 已登入 ==" -ForegroundColor Cyan
if (Get-Command netlify -ErrorAction SilentlyContinue) {
    Write-Host "  （正在檢查登入狀態，約需 10 秒，請稍候…）" -ForegroundColor DarkGray
    $ns = Invoke-WithTimeout "netlify status" 15
    if ($null -eq $ns) {
        Write-Host "  [逾時] 無法確認。請自己開一個 PowerShell 手動執行：netlify status" -ForegroundColor Yellow
    } elseif ($ns.Code -eq 0) {
        Write-Host "  [OK]   netlify 已完成登入" -ForegroundColor Green
    } else {
        Write-Host "  [缺少] 請執行：netlify login （會跳出瀏覽器按 Authorize）" -ForegroundColor Red
        $script:pass = $false
    }
} else {
    Write-Host "  [跳過] netlify 尚未安裝" -ForegroundColor Red
}

Write-Host ""
Write-Host "== 5. 當天工作資料夾要建在哪 ==" -ForegroundColor Cyan
# 不要檢查 $PWD——那只反映這支腳本被誰呼叫，不代表學員會在哪裡工作。
# 真正會出問題的是「桌面被 OneDrive 接管」：Git 在同步資料夾內常發生檔案鎖定。
$desktop = [Environment]::GetFolderPath('Desktop')
if ($desktop -like "*OneDrive*") {
    Write-Host "  [注意] 你的桌面被 OneDrive 同步了。" -ForegroundColor Yellow
    Write-Host "         Git 在同步資料夾裡容易檔案鎖定，當天可能會出現奇怪的錯誤。" -ForegroundColor Yellow
    Write-Host "         請把 my-first-page 建在下面這個位置，不要建在桌面：" -ForegroundColor Yellow
    Write-Host ("           {0}" -f $env:USERPROFILE) -ForegroundColor White
} else {
    Write-Host "  [OK]   你的桌面沒有被 OneDrive 同步，當天直接在桌面建資料夾即可。" -ForegroundColor Green
    Write-Host ("         桌面位置：{0}" -f $desktop) -ForegroundColor DarkGray
}

Write-Host ""
if ($script:pass) {
    Write-Host "  全部通過，課前準備完成，工作坊當天直接開始寫程式。" -ForegroundColor Green
} else {
    Write-Host "  尚有項目未完成。修正後請重新執行本腳本。" -ForegroundColor Red
    Write-Host "  安裝完新工具後，務必關閉並重新開啟 PowerShell 再測一次。" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "  （黃色 [逾時] 不算失敗，只是本腳本問不到，手動確認即可。）" -ForegroundColor DarkGray
Write-Host ""
