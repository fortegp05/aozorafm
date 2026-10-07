# new_post.ps1 に R2 アップロードを追加

## 目的
new_post.ps1 実行時、mp3 の情報読み込みと一緒に mp3 を R2 (バケット aozorafm-audio) にアップロードする。

## やること
- mp3 読み込み後に `npx wrangler r2 object put aozorafm-audio/aozorafm_<日付>_01.mp3 --file <path> --content-type audio/mpeg --remote` を実行(--remote 必須)
- 失敗しても記事作成は続行(スキップ)。結果に `Upload error: <理由>` の1行のみ出す
- 成功時は `Uploaded: https://aozorafm.win/aozorafm_<日付>_01.mp3` を1行出す
- バケット名は定数で1か所にまとめる

## やらないこと
- wrangler の永続インストール、キーのファイル保存、リトライ、進捗表示、new_post_range.ps1 の変更
- 同名オブジェクトは確認なしで上書き

## 完了条件
1. 未ログイン/バケット名違いで `Upload error: <理由>` が出て記事は作成される
2. wrangler login 後、ダミーmp3(aozorafm_20991231_01.mp3)でR2に上がり https://aozorafm.win/ で取得できる
3. テスト用のダミーmp3・記事・R2上のテストオブジェクトを削除(自作分のみ)

## 影響範囲とリスク
- 本番バケットへ一時的にテストオブジェクトを書き込む(削除する)。初回はnpxのダウンロードで時間がかかる。INDEX.md更新は不要。
