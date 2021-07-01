---
layout    : post
category  : テク
title     : 化整為零搞定超巨大commit
tags      : [git, gitlab]
date      : 2021-07-01 15:19:36 +8
published : true
image     : /assets/2021/2021-07-01-push-large-commit-thumb.jpg
has_thumb : true
excerpt   : <p>Git LFS是好東西，腦子也是好東西，但同時掌握兩者的人十分稀少🙄<br/>當不知道LFS存在的菜鳥打出一個無法在timeout之前push完成的超大commit時，我該如何拯救自己的腦細胞？</p>
lang      : zh-TW
---

```powershell
PS C:\workdata> git push origin main:refs/heads/main
Enumerating objects: 5973, done.
Counting objects: 100% (5973/5973), done.
Delta compression using up to 8 threads
Compressing objects: 100% (3984/3984), done.
Writing objects: 100% (5971/5971), 2.46 GiB | 1.96 MiB/s, done.
Total 5971 (delta 1451), reused 5968 (delta 1449), pack-reused 0
error: RPC failed; HTTP 502 curl 22 The requested URL returned error: 502
fatal: the remote end hung up unexpectedly
fatal: the remote end hung up unexpectedly
Everything up-to-date
```

## 序幕

你是否也曾在某處看過這樣的訊息？看完忍不住一陣咒罵、然而挖坑同事早已收拾閃人？

先前處理到一個git repository遷移任務，原主機位置不明、配置不明、管理員不明，不只頻繁卡頓還發生專案丟失的現象，時間緊湊只得用最土炮的方式直接clone到本機。複製完成後，因為操作最熟悉而選擇了GitLab做為新的存放位置。

本來平平都是git要遷移起來應該是沒難度的，然而原先的repo裡面從原始碼到IDE、從會議記錄到訪談錄音無所不包，前一手離職前還把git當網路硬碟將另一個專案也commit進來。多達4GB的repo在傳輸上隨便都用小時計算，就在這邊發生我始料未及的狀況: GitLab的執行時限太短。

網路上簡單搜索一下可以發現不少類似問題，雖然錯誤碼不一但共同點是每個repo都很大。多數人看到這邊的直覺反應應該是拆成多次push分批上傳，而我一開始也是這麼做。不過分批仍有極限，當單單一個commit的大小就有數GB的時候，即使一次只push一個commit也會落到逾時結果。

既然一個commit太大，那分成兩個不行嗎？普通情況下，這時候應該會開始動念修改commit，將一個commit切成多個之後再分批上傳。想法不錯，是我也會這樣做順便把過於巨大的檔案清一清，但是只要修改就會讓hash改變，在這個情境下很遺憾不可行。

WTF！水管就那麼大，這不是無理取鬧嗎？

## 推理

其實還真有可能。這邊先來回顧一下git的[基本概念](https://github.blog/2020-12-17-commits-are-snapshots-not-diffs/):

- **Object ID**: git使用hash來識別所有物件，包含blob、tree、hash
- **Blob**: 真正的檔案會被保存為一個個的blob，每個blob經過hash後歸檔
- **Tree**: blob只有檔案內容，而檔名和路徑則另外儲存，並透過參照blob或其他tree的hash來遞規組裝出目錄結構。透過這個方式，相同檔案只需要保留一份
- **Commit**: 將tree的原點、parent commit和作者資訊一起保存，如此一來便可將一堆互不相關的tree關聯出時間先後

也就是說git基本單位的commit裡面還有更多次級結構存在，而且這些結構是可以被重複使用的。

這給我一個想法，如果我可以把這些blob打散從水陸空分開送上去，最後再集結起來組成commit是否可行？原本卡關的單一commit，往下分析之後發現他只是blob特別多，但是每個blob都在可接受範圍內，這個賭注勝算很大。

## 實踐

設卡關commit的位置為`DEADBEEF~5`，我們要把它的內容分散成一堆小commit，而且必須確保這些blob沒有改變。

```powershell
git checkout -b CHIMAME DEADBEEF~5
git reset HEAD~1
```

如此一來便將該commit內容展開到worktree當中，準備好重新編組。接著我們進行幾次commit，每次commit要控制在幾百MB的大小。

當所有內容都commit完畢記得diff確認剛剛長出來的分支`CHIMAME`和目標的`DEADBEEF~5`狀態是否一樣。趁機上傳更多檔案不是不行，不過這會增加複雜度所以不討論。

```powershell
git add file01 file02 file03 ... file99
git commit -m ""

git diff CHIMAME DEADBEEF~5
```

應該比對不到差異才是，有東西自己檢討。commit完還要讓git在之後push `DEADBEEF`的時候能夠重複使用這些blob，為此我將`DEADBEEF~5`合併進剛剛建立的`CHIMAME`分支去。

```powershell
git merge DEADBEEF~5
```

這會讓`CHIMAME`領先`DEADBEEF~5`一個commit，而`DEADBEEF~5`因為被合併成為目前歷史的一部分也會順勢帶上去，大概是這種感覺:

```text
  *    CHIMAME (parent: CHIMAME~1, DEADBEEF~5)
 /|
* |  DEADBEEF~5
| |
| *    CHIMAME~1
...
| *    CHIMAME~15
| |
| *    CHIMAME~16
|/
*    DEADBEEF~6
```

全部準備完成之後就要開始分批上傳，這邊會需要點時間，開始執行後可以放著先去吃飯。

```powershell
for($i=16; $i -ge 0; $i--) {
  git push origin CHIMAME~$i`:CHIMAME
}
```

執行完畢以後，讓你牙癢癢的commit `DEADBEEF~5`已經乖乖躺在GitLab上面了，再來就按正常流程把剩下的正常commit也push上去。

```powershell
git push origin DEADBEEF
```

不改變hash的情況推送超大commit，任務完成😎

[基本概念]:https://github.blog/2020-12-17-commits-are-snapshots-not-diffs/
