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
<a href = "https://bvn-sports.com/">웹사이트</a> |
<a href = "https://space.bilibili.com/1340107883">빌리빌리</a> |
<a href = "https://www.douyin.com/user/MS4wLjABAAAAJ2UeSAz7T6qx7XSSL70IgfuMsZZaxOIvPIL3Zdvmk8rSAoBfNfngGx7Zy2jFSnYj">틱톡</a> |
<a href = "https://x.com/5Dplay">X (트위터)</a>
</strong>
</p>

## ⭐ 스타 역사 <!-- omit in toc -->

[![Star History Chart](https://api.star-history.com/svg?repos=5DPLAY-Game-Studio/BleachVsNaruto,5DPLAY-Game-Studio/BleachVsNaruto_FlashSrc&type=Date)](https://www.star-history.com/#5DPLAY-Game-Studio/BleachVsNaruto&5DPLAY-Game-Studio/BleachVsNaruto_FlashSrc&Date)

# 블리치 vs 나루토 <!-- omit in toc -->

[简体中文](README.md) | [English](README_en.md) | [日本語](README_ja.md) | 한국인

**블리치 vs 나루토** 는 **剑jian** 과 제작팀 **5DPLAY Game Studio** 가 개발한 새로운 컨셉의 전략 격투 게임입니다.

여기에서는 자신의 운영과 반응의 한계에 도전할 수도 있고, 팀의 핵심 의사 결정자로서 전략을 세우는 즐거움을 경험할 수도 있습니다.

## 목록 <!-- omit in toc -->

- [프로젝트 상태](#프로젝트-상태)
- [바이너리 게임 다운로드](#바이너리-게임-다운로드)
- [변경 사항](#변경-사항)
- [소스에서 빌드하는 방법](#소스에서-빌드하는-방법)
- [엔지니어링 구조](#엔지니어링-구조)
- [특허](#특허)
- [기여하다](#기여하다)
- [번역하다](#번역하다)
- [우리를 따르세요](#우리를-따르세요)

## 프로젝트 상태

**블리치 vs 나루토** 는 ***ActionScript 3.0*** 스크립팅 언어를 사용하여 작성되었습니다.현재 지원되는 플랫폼은 다음과 같습니다:

- [x] Windows
- [ ] Mac OS
- [ ] Linux
- [ ] Harmony OS
- [x] Android
- [ ] iOS

현재 주요 버전은 3.7 이며, 업데이트 작업을 진행 중이지만 아직 완벽하지는 않습니다. 문제가 있으시면 이슈 트래커(또는 저희 팀에 연락할 수 있는 다른 연락 방법)를 통해 신고해 주세요.

이 프로젝트는 현재 **알파** 단계이며, 당분간 프로젝트 리더가 개발 작업을 직접 관리하고 추진할 예정입니다. 프로젝트 개발 진행 상황이 **베타** 단계에 도달하면 개발 워크플로는 **포크 - 브랜치 - 커밋 - 풀 - 풀 리퀘스트** 모드로 전환됩니다.

## 바이너리 게임 다운로드

이 프로젝트의 바이너리 파일만 보고 게임 프로젝트가 어떻게 만들어졌는지 신경 쓰지 않으신다면, 게임 공식 소셜 미디어 계정에서 정보를 얻으시기 바랍니다. 이 페이지는 개발자 전용입니다.

## 변경 사항

이 프로젝트의 자세한 변경 로그는 [CHANGELOG.md](CHANGELOG.md) 파일을 참조하세요.

## 소스에서 빌드하는 방법

소스에서 이 프로그램을 빌드하려면 [HOW2BUILD.md](HOW2BUILD.md) 파일을 가이드로 읽어야 합니다.

## 엔지니어링 구조

- `BleachVsNaruto_FlashSrc` - 필요한 바이너리 파일(확장자: swf)의 소스 파일(확장자: fla 또는 xfl)
- `CORE_Components` - 게임 상호작용 구성 요소
- `CORE_KernelLogic` - 게임 핵심 로직
- `CORE_Shared` - 게임 외부 공개 인터페이스
- `CORE_Utils` - 일부 게임에 사용되는 공통 유틸리티 모음
- `LIB_KyoLib` - 게임 작가 **剑jian** 이 작성한 개인 라이브러리
- `LIB_Other` - 기타 라이브러리
- `SHELL_Dev` - 개발자를 위한 기능적 셸
- `SHELL_Mob` - 모바일 기기에서 실행되는 기능적 셸
- `SHELL_Pc` - PC 에서 실행되는 기능적 셸
- `shared` - 게임 공유 리소스 라이브러리
- `tools` - 엔지니어링 툴셋

## 특허

**블리치 vs 나루토** 는 엔지니어링 개발 라이선스로 [GPL-3.0] 을 사용합니다. 라이선스 내용을 미리 숙지하고 이해해야 합니다.

- 이 프로그램은 무료 소프트웨어입니다. 자유 소프트웨어 재단에서 공표한 GNU 일반 공중 사용 허가서 버전 3 또는 (사용자의 선택에 따라) 이후 버전의 조건에 따라 재배포 및/또는 수정할 수 있습니다.
- 이 프로그램은 유용할 것이라는 희망 하에 배포되지만, 어떠한 보증도 제공하지 않습니다. 상품성이나 특정 목적에의 적합성에 대한 묵시적 보증도 제공하지 않습니다. 자세한 내용은 GNU General Public License 를 참조하십시오.
- 이 프로그램과 함께 GNU General Public License 사본을 받으셨을 것입니다. 받지 못하셨다면 <http://www.gnu.org/licenses> 를 참조하세요.

## 기여하다

**블리치 vs 나루토** 모든 분들의 제출과 기여를 환영합니다.

5DPLAY 커뮤니티 전체는 이 프로젝트에서 따르는 행동 강령을 준수해야 합니다.

다음의 훌륭한 사람들에게 감사드립니다. ([이모티콘 키](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/raionchanqwq"><img src="https://avatars.githubusercontent.com/u/214450127?v=4?s=100" width="100px;" alt="ライオンちゃん"/><br /><sub><b>ライオンちゃん</b></sub></a><br /><a href="https://github.com/5DPLAY-Game-Studio/BleachVsNaruto/commits?author=raionchanqwq" title="Documentation">📖</a> <a href="#translation-raionchanqwq" title="Translation">🌍</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

이 프로젝트는 [all-contributors](https://github.com/all-contributors/all-contributors) 사양을 따릅니다. 어떤 종류의 기여든 환영합니다!

## 번역하다

이 프로젝트의 설립은 모든 구성원의 노고에서 비롯됩니다. 해외 홍보 측면에서는 현지화 과정을 도와주신 해외 업체들이 꽤 많습니다. 이분들의 노고에 진심으로 감사드립니다.

다음은 번역에 참여한 번역자 목록입니다.

- `简体中文` - 5DPLAY
- `English` - MeleeWaluigi, Waffles.7z
- `日本語` - ライオンちゃん

## 우리를 따르세요

[![Twitter:5Dplay](https://img.shields.io/twitter/follow/5Dplay)](https://x.com/5DPLAY) [![BiliBili:死神VS火影吧](https://badgen.net/badge/BiliBili/死神VS火影吧/)](https://space.bilibili.com/1340107883)

[GPL-3.0]: https://www.gnu.org/licenses/gpl-3.0.html
