<p align = "center">
<a href  = "https://bvn-sports.com/"><img src = "title.png" /></a>
</p>

<p align = "center">
<img src = "https://img.shields.io/github/stars/5DPLAY-Game-Studio/BleachVsNaruto" />
<img src = "https://img.shields.io/github/forks/5DPLAY-Game-Studio/BleachVsNaruto" />
<img src = "https://img.shields.io/github/followers/5DPLAY-Game-Studio" />
<br />
<img src = "https://img.shields.io/github/contributors/5DPLAY-Game-Studio/BleachVsNaruto" />
<img src = "https://img.shields.io/github/created-at/5DPLAY-Game-Studio/BleachVsNaruto" />
<img src = "https://img.shields.io/github/license/5DPLAY-Game-Studio/BleachVsNaruto" />
<br />
<img src = "https://img.shields.io/github/languages/top/5DPLAY-Game-Studio/BleachVsNaruto" />
<img src = "https://img.shields.io/github/v/tag/5DPLAY-Game-Studio/BleachVsNaruto" />
<br />
<strong>
<a href = "https://bvn-sports.com/">ウェブサイト</a> |
<a href = "https://space.bilibili.com/1340107883">ビリービリー</a> |
<a href = "https://www.douyin.com/user/MS4wLjABAAAAJ2UeSAz7T6qx7XSSL70IgfuMsZZaxOIvPIL3Zdvmk8rSAoBfNfngGx7Zy2jFSnYj">ティックトック</a> |
<a href = "https://x.com/5Dplay">X (ツイッター)</a>
</strong>
</p>

# ブリーチ vs ナルト <!-- omit in toc -->

[中文版](README.md) | [English](README_en.md) | 日本語

**ブリーチ vs ナルト** は、**剑jian** とその制作チーム **5DPLAY Game Studio** によって開発された新しいコンセプトの戦略格闘ゲームです。

ここでは、自身の操作と対応の限界に挑戦したり、チームの中核意思決定者として戦略を練る喜びを体験したりできます。

## カタログ <!-- omit in toc -->

- [プロジェクトのステータス](#プロジェクトのステータス)
- [バイナリゲームをダウンロード](#バイナリゲームをダウンロード)
- [変更履歴](#変更履歴)
- [ソースからビルドする方法](#ソースからビルドする方法)
- [エンジニアリング構造](#エンジニアリング構造)
- [ライセンス](#ライセンス)
- [貢献する](#貢献する)
- [翻訳する](#翻訳する)
- [フォローする](#フォローする)

## プロジェクトのステータス

**ブリーチ vs ナルト** は ***ActionScript 3.0*** スクリプト言語で記述されており、サポートされている主なプラットフォームには **Windows、MacOS、Android** が含まれます。

現在のメジャーバージョンは3.7です。現在アップデートに取り組んでいますが、まだ理想的な状態ではありません。何か問題がございましたら、問題追跡システム（またはチームに連絡可能なその他の連絡方法）にご報告ください。

プロジェクトは現在 **アルファ** 段階にあり、当面はプロジェクトリーダーが直接開発を管理・推進します。プロジェクトの開発進捗が **ベータ** 段階に達すると、開発ワークフローは **フォーク - ブランチ - コミット - プル - プルリクエスト** モードに移行します。

## バイナリゲームをダウンロード

このプロジェクトのバイナリファイルのみに興味があり、ゲームプロジェクトのビルド方法には関心がない場合は、ゲームの公式ソーシャルメディアアカウントにアクセスして入手してください。このページは開発者専用です。

## 変更履歴

このプロジェクトの詳細な変更ログについては、[CHANGELOG.md](CHANGELOG.md) ファイルを参照してください。

## ソースからビルドする方法

このプログラムをソースからビルドするには、[HOW2BUILD.md](HOW2BUILD.md) ファイルをガイドとして読む必要があります。

## エンジニアリング構造

- `BleachVsNaruto_FlashSrc` - 必要なバイナリ ファイル (拡張子: swf) のソース ファイル (拡張子: fla または xfl)
- `CORE_Components` - ゲームインタラクティブコンポーネント
- `CORE_KernelLogic` - ゲームコアロジック
- `CORE_Shared` - ゲーム外部公開インターフェース
- `CORE_Utils` - いくつかのゲームでよく使われるユーティリティのコレクション
- `LIB_KyoLib` - ゲーム作者 **剑jian** が書いた個人ライブラリ
- `LIB_Other` - その他のライブラリ
- `SHELL_Dev` - 開発者向けの機能シェル
- `SHELL_Mob` - モバイルデバイス上で動作する機能シェル
- `SHELL_Pc` - PC上で動作する機能シェル
- `shared` - ゲーム共有リソースライブラリ
- `tools` - エンジニアリングツールセット

## ライセンス

**ブリーチ vs ナルト** はエンジニアリング開発ライセンスとして [GPL-3.0] を使用しています。事前にライセンスの内容を十分理解しておく必要があります。

- このプログラムはフリーソフトウェアです。フリーソフトウェア財団が発行した GNU 一般公衆利用許諾書のバージョン 3、または (選択により) それ以降のバージョンの規約に従って、このプログラムを再配布および/または改変することができます。
- このプログラムは有用であることを期待して配布されていますが、いかなる保証も行いません。商品性や特定目的への適合性に関する暗黙の保証さえも行いません。詳細については、GNU General Public License を参照してください。
- このプログラムにはGNU一般公衆利用許諾書のコピーが付属しているはずです。そうでない場合は、<http://www.gnu.org/licenses> をご覧ください。

## 貢献する

**ブリーチ vs ナルト** 皆様からの投稿や貢献を歓迎します。

5DPLAY コミュニティ全体が、このプロジェクト自体が遵守する行動規範を遵守する必要があります。

## 翻訳する

プロジェクトの立ち上げは、メンバー全員の努力と切り離せないものです。国際プロモーションにおいては、ローカライズ作業において多くの海外プレイヤーの皆様にご協力をいただいています。皆様のご尽力に心より感謝申し上げます。

ご協力いただいた翻訳者の皆様は以下の通りです。

- `简体中文` - 5DPLAY
- `English` - MeleeWaluigi, Waffles.7z
- `日本語` - ライオンちゃん

## フォローする

[![Twitter:5Dplay](https://img.shields.io/twitter/follow/5Dplay)](https://x.com/5DPLAY)

[GPL-3.0]: https://www.gnu.org/licenses/gpl-3.0.html
