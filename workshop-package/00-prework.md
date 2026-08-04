# 工作坊課前準備（約 15 分鐘）

**請在 【截止日】 前做完。** 當天不會有時間裝軟體。

90 分鐘的工作坊，你會親手做出一個網頁並放上網路，下課時有一個**手機打得開的網址**。

**不熟電腦沒關係。卡住就回信給我，附上整個畫面的截圖，不要自己亂試。**
不想自己弄的人：【安裝場時間】有 30 分鐘線上安裝場，我陪大家一步一步做 → 【安裝場連結】

---

## 1　開兩個帳號（10 分鐘，全程用滑鼠）

- **GitHub** <https://github.com/signup> → 開好後**記下你的使用者名稱**

  > **GitHub 強制要求二階段驗證（2FA）。** 請在手機上安裝 **GitHub Mobile**（iOS：App Store / Android：Google Play，搜尋「GitHub」）。安裝後用你的帳號登入，GitHub 要求設定 2FA 時選 **「GitHub Mobile」**，按照畫面完成。當天用筆電登入 GitHub 時，手機 app 會跳出確認通知，按一下就通過。
- **Netlify** <https://app.netlify.com/signup> → **請選「Sign up with GitHub」**，不要另外設密碼

註冊要收 email 驗證碼，**請務必先做這一步**。

## 2　安裝五個工具（約 5 分鐘）

桌面空白處右鍵 → 「在終端中開啟」（Win10 用 Shift+右鍵），然後依序貼這三行（一行貼完等它跑完再貼下一行）：

```powershell
winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
```

```powershell
winget install --id OpenJS.NodeJS.LTS -e --source winget --accept-package-agreements --accept-source-agreements
```

```powershell
winget install --id GitHub.cli -e --source winget --accept-package-agreements --accept-source-agreements
```

三行跑完後，**關掉視窗重新開一個**（新工具要重開才找得到），再貼這兩行：

```powershell
npm install -g netlify-cli
```

```powershell
irm 'https://cli.kiro.dev/install.ps1' | iex
```

| 狀況 | 解法 |
|---|---|
| `winget` 說找不到 | Windows 版本太舊，改用下面的一鍵包 |
| 跑完出現黃字說「已安裝」 | 正常，代表本來就有了，繼續往下 |
| `npm` 說找不到 | Node.js 剛裝好要重開視窗，關掉黑窗重來一次 |
| 公司電腦被擋住 | **回信告訴我**，不要自己亂試 |

> **來不及或 winget 不能用**：改用附件裡的 `install.bat`（整包解壓縮，雙擊它，跳出「是否允許…」按【是】，跑 5–15 分鐘不要關掉）。跑完後仍需單獨跑 Kiro CLI 那行（一鍵包沒有包含它）。

## 3　開終端機，完成登入

桌面按右鍵新增資料夾，命名 `my-first-page`，**雙擊進去**，在空白處：

- **Windows 11**：右鍵 → 「**在終端中開啟**」
- **Windows 10**：**Shift + 右鍵** → 「在此處開啟 PowerShell 視窗」
- 都找不到：檔案總管**網址欄**把路徑刪掉，打 `powershell` 按 Enter

> **不要從開始選單找 PowerShell**，那樣打開位置會錯，你會迷路。

黑窗打開後，**複製**下面兩行（名字和 email 換成你自己的），在黑窗**按滑鼠右鍵**貼上，按 Enter：

```powershell
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

> **貼上是按滑鼠右鍵，不是 Ctrl+V。**
> 成功的時候畫面**什麼都不會顯示**，那就是對的。email 請用註冊 GitHub 的那一個。

再貼這行，按 Enter：

```powershell
gh auth login
```

用**上下方向鍵**選、Enter 確認：`GitHub.com` → `HTTPS` → `Y` → `Login with a web browser`。
畫面會給一組 **8 碼**，**先記下來**，按 Enter 後瀏覽器會開，貼進去按 Authorize。

最後貼這行，按 Enter：

```powershell
netlify login
```

瀏覽器跳出後按 **Authorize**。
**它要等 10–30 秒。游標在閃就是在做事，不要一直按 Enter。**

再貼這行，按 Enter：

```powershell
kiro
```

瀏覽器會自動開啟，選一種你有的帳號登入：**Google**、**GitHub**（課前已申請）、或 **AWS Builder ID**（免費）。登入完成後回到黑窗按 Ctrl+C 退出。

## 4　雙擊 `check.bat` 確認

等約 1 分鐘，看畫面：

| 你看到 | 意思 |
|---|---|
| 綠色 **全部通過** | 完成了 → **截圖回信給我** |
| 紅色 `[缺少]` | 照它寫的那行指令做，再雙擊一次 |
| 黃色 `[逾時]` | **不算失敗**，忽略它 |
| 提到 **OneDrive** | 當天請把資料夾建在它指定的位置，**不要建在桌面** |

---

## 當天請帶

**筆電＋電源線**、**手機**（最後要用手機打開你做的網站）、**這張紙**

---

**幾件先講清楚的事：** 你不會弄壞電腦。出現紅字是正常的，那不是你的錯，是電腦在跟你講話。
打密碼時畫面不會動，那是安全設計，照打完按 Enter。打錯字按 <kbd>↑</kbd> 把指令叫回來改就好。

附件另有兩份**選讀**資料，不看不影響上課：
`terminal-card.md`（終端機怎麼用，建議印出來）、`cli-explained.md`（這些工具到底是什麼）。
