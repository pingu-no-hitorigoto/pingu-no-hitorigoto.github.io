---
layout    : post
category  : レコ
title     : eSIM.me實體eSIM開箱
tags      : []
date      : 2022-09-24 22:49:53 +8
published : true
lang      : zh-TW
---

原來升級eSIM也可以不用換手機

<!--more-->

## 什麼是eSIM？

每次講到這個話題我都一個頭兩個大，因為實在太難形容了。在討論eSIM之前，我們先來談談普通的SIM。

SIM的全稱是Subscriber Identity Module (使用者身分模組)，主要任務是提供必需的身分識別作業，讓用戶通過驗證並接入行動網路，外觀通常是一張裡面燒有身分驗證邏輯的IC卡。隨著手機越做越緊湊，這個SIM也持續被縮小，從信用卡大小(1FF)、Mini-SIM/2FF、Micro-SIM/3FF、Nano-SIM/4FF到直接嵌入裝置中的Embedded-SIM/MFF2，這也是eSIM最原始的定義。

單純將尺寸縮小做不到換網不換卡，畢竟一直以來的SIM卡都只能接入一個營運商––精確來說是驗證邏輯只支援特定營運商。為了讓同一張SIM卡可以按需變更驗證邏輯，這幫商人又創造了eUICC，把實體的卡片虛擬化，透過指令去將指定的"卡片"給載入進來。

寫到這邊我自己也看不懂了，虛擬化是什麼鬼？抽換是怎麼抽換？這邊我想的到的例子是在各路宗教常見的靈魂這一概念：我們可以把SIM比喻成"人"，人裡面有著"靈魂"。eSIM相對於SIM就像小孩相對於成人，即使身體縮小還是同一個靈魂。eUICC則是讓多個靈魂共用一具身體，並且可以隨時交換身體的主導權。

這個比喻還有很多不完備的地方，但是物理上的eSIM加上邏輯上的eUICC，兩個結合起來就差不多是我們從商人嘴裡聽到的eSIM了。

## eSIM只能內嵌嗎？

為了方便說明，接下來我會以eSIM泛指所有具備eUICC功能的SIM。如果你有看懂我前面在鬼扯什麼，你就應該有發現切換網路的關鍵在於eUICC技術，至於卡片尺寸只不過是皮囊，對切換網路來說是完全無關緊要的。在規範中也確實允許以1FF~4FF的物理形式實現eSIM，所以從規範上來說eSIM完全可以做成可移除的卡片形式，只要尺寸對了，我大可將eSIM插在一代神機的Nokia 3310裏頭使用。

## 開箱

TBD...

## eSIM.me的支援情況

台灣的eSIM換發簡直搶錢，底下簡單記述目前已經測試過的營運商支援情況。

### TStar 台灣之星 @ 20220707

| key | value |
| --- | --- |
| Data Plan | 4G入門6元288自由配吃到飽0分 |
| Apply Fee | 月租288 / 補卡300初次減免 |
| Network | 3G/4G |
| VoLTE | Yes |
| VoWifi | No |
| Device Name | Unihertz Jelly 2 Japan |
| OS Version | Android 11 / ver. 20220119 |
| App Version | 1.1.3.1 |
| Activate Result | Failed (8.2.5 4.3) |

### APTG 亞太電信 @ 20220814

| key | value |
| --- | --- |
| Data Plan | 4G手機資費398型(5M) |
| Apply Fee | 月租99 / 補卡300隨帳單收取 |
| Network | 3G/4G |
| VoLTE | Yes |
| VoWifi | Yes |
| Device Name | Unihertz Jelly 2 Japan |
| OS Version | Android 11 / ver. 20220119 |
| App Version | 1.1.3.1 |
| Activate Result | Success |

### TWM 台灣大哥大 @ 20220814

| key | value |
| --- | --- |
| Data Plan | 行動上網7日體驗方案 |
| Apply Fee | 0 |
| Network | 3G/4G/5G |
| VoLTE | No |
| VoWifi | No |
| Device Name | Unihertz Jelly 2 Japan |
| OS Version | Android 11 / ver. 20220119 |
| App Version | 1.1.3.1 |
| Activate Result | Success |

### Ubigi.me @ 20220924

Ubigi不是台灣的營運商，但因為可以免費申請eSIM所以也納入測試範圍。Ubigi的系統應該是持續有在更新，之前失敗了許多次，這是時隔兩個月後的第三個馬甲。

| key | value |
| --- | --- |
| Data Plan | Not activated |
| Apply Fee | 0 |
| Network | 3G/4G/5G |
| VoLTE | No |
| VoWifi | No |
| Device Name | Unihertz Jelly 2 Japan |
| OS Version | Android 11 / ver. 20220119 |
| App Version | 1.1.3.1 |
| Activate Result | Success |

## Appendix A - eSIM.me compatibility

| Feature | Statue |
| --- | --- |
| eSIM.me app |  |
| \|- Activate on eSIM.me | o |
| \|- Switch profile | o |
| \\- Switch profile offline | ! |
| Android Settings |  |
| \|- Activate on eSIM.me | x |
| \|- Switch profile | o [a1] |
| \\- Switch profile offline | o [a1] |

[a1]: ROM must have native eSIM support

## Appendix B - Device & MNO Compatibility

|    | Pixel 3 (G013B) [b1] | Jelly 2 (Japan) |
| --- | --- | --- |
| TStart 台灣之星 |  |  |
| \|- 3G | o | o |
| \|- LTE | o | o |
| \|- VoLTE | x | o |
| \\- VoWifi [b2] | x | x |
| APTG 亞太電信 |  |  |
| \|- 3G | o | o |
| \|- LTE | o | o |
| \|- VoLTE | x | o |
| \\- VoWifi | x | o |
| TWM 台灣大哥大 |  |  |
| \|- 3G | o | o |
| \|- LTE | o | o |
| \|- VoLTE | o | o |
| \\- VoWifi | x | o |
| FEnet 遠傳電信 |  |  |
| \|- 3G | o | o |
| \|- LTE | o | o |
| \|- VoLTE | o | - |
| \\- VoWifi | x | - |
| CHT 中華電信 |  |  |
| \|- 3G | - | - |
| \|- LTE | - | - |
| \|- VoLTE | - | - |
| \\- VoWifi | - | - |

[b1]: G013B has same VoLTE and VoWifi capability as G013A, but only sold in Japan.
[b2]: TStar doesn't provide VoWifi service
