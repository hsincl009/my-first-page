# 一頁小抄（建議雙面列印，每人一張）

## 正面：今天會用到的全部指令

### 開場：進到工作資料夾

```powershell
cd $env:USERPROFILE\Desktop\my-first-page
```

### 存檔三件事（每次改完都做）

```powershell
git add .
git commit -m "說明我改了什麼"
git push
```

> 比喻：`add` = 把改動放進紙箱；`commit` = 封箱貼標籤（存檔點）；`push` = 寄到 GitHub。

### 第一次上 GitHub（只做一次）

```powershell
git init
git add .
git commit -m "我的第一個網頁"
gh repo create my-first-page --public --source=. --push
gh repo view --web
```

### 第一次上 Netlify（只做一次）

```powershell
netlify init
```

回答順序：

| 問題 | 你要選 |
|---|---|
| What would you like to do? | **Create & configure a new project** |
| Team | 直接 Enter |
| Project name | 直接 Enter（自動取名） |
| Your build command | **直接 Enter，留空** |
| Directory to deploy | 輸入 `.` 再 Enter |
| Netlify functions folder | 直接 Enter |
| Create netlify.toml? | `y` |

完成後看網址：

```powershell
netlify open:site
```

### 之後每次更新網站

```powershell
git add .
git commit -m "改了什麼"
git push
```

推上去約 30 秒後網站自動更新。**不需要再跑 netlify 指令。**

---

## 背面：出事的時候

### 改壞了，還沒 commit → 全部丟掉，回到上一個存檔點

```powershell
git restore .
```

### 想看做過哪些存檔點

```powershell
git log --oneline
```

### 已經 push 上去才發現壞了 → 做一個「反向存檔點」

```powershell
git log --oneline          # 找到壞掉那次的代號，例如 a1b2c3d
git revert a1b2c3d
git push
```

### 常見錯誤訊息

| 訊息 | 意思 | 解法 |
|---|---|---|
| `not a git repository` | 你不在專案資料夾裡 | `cd` 到正確資料夾 |
| `nothing to commit` | 檔案沒存檔 | 回編輯器按 Ctrl+S |
| `Author identity unknown` | Git 不知道你是誰 | 執行課前準備第三節那兩行 |
| `failed to push` / `rejected` | GitHub 上有你沒有的東西 | 先 `git pull`，再 `git push` |
| 網頁打開一片空白 | HTML 打錯字 | 按 F12 看紅色錯誤，或用追進度包覆蓋 |
| 改了但網頁沒變 | 瀏覽器快取 | 按 **Ctrl + F5** 強制重新整理 |

### 最後手段：追進度包

打不完、改壞了、跟不上，直接用講者提供的 `steps/` 資料夾中對應檔案，
複製全部內容覆蓋你的 `index.html`，存檔，立刻跟上進度。**不要留在原地卡著。**

---

## 帶回家的三句話

1. 網站上線＝把資料夾放到別人的電腦上，如此而已。
2. `add` / `commit` / `push` 三個字，就是你以後所有專案的日常。
3. Git 的價值不是備份，是**讓你敢亂改**。
