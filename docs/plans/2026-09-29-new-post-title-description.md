# new_post.ps1 に title / description 指定を追加

## 目的
new_post.ps1 で記事の title と description を指定できるようにする。未指定なら何もしない。

## やること
- `-Title` `-Description` パラメータを追加(位置引数の4・5番目でも可)
- `-Title` 指定時: `title: 350. <title>` の `<title>` のみ置換(番号接頭辞は残す)
- `-Description` 指定時: `description: "値"` とする(YAML破損防止のためダブルクォートで囲み、`\` `"` をエスケープ)
- 未指定なら該当行は触らない

## やらないこと
- new_post_range.ps1、テンプレート、他フィールドの変更

## 完了条件
- 両方指定 / 未指定 / 片方のみ の3パターンでダミー記事を生成し、frontmatterを目視確認(確認後ダミーは削除)
- `:` `#` `"` `$1` を含む値でもYAMLが壊れない

## 影響範囲とリスク
- 既存呼び出しへの影響なし。置換時の `$` 特殊展開を避ける。
- INDEX.md 更新は不要。
