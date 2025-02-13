# Bleach vs Naruto <!-- omit in toc -->

![bvn](title.png "bvn")

[中文版](README.md) | [English](README_en.md)

**Bleach vs Naruto** is a new concept strategy fighting game developed by **剑jian** and its production team **5DPLAY Game Studio**.

Here, you can challenge the limits of your own operation and reaction, or you can experience the pleasure of strategizing as the core decision-maker of the team.

## Catalog <!-- omit in toc -->

- [Project Status](#project-status)
- [Download Binary Game](#download-binary-game)
- [Changelog](#changelog)
- [How to build from source](#how-to-build-from-source)
- [Engineering Structure](#engineering-structure)
- [License](#license)
- [Contribute](#contribute)
- [Translate](#translate)
- [Follow us](#follow-us)

## Project Status

![Star:Latest](https://img.shields.io/github/stars/5DPLAY-Game-Studio/BleachVsNaruto)
![Fork:Latest](https://img.shields.io/github/forks/5DPLAY-Game-Studio/BleachVsNaruto)
![Follower:Latest](https://img.shields.io/github/followers/5DPLAY-Game-Studio)

![Contributors:Latest](https://img.shields.io/github/contributors/5DPLAY-Game-Studio/BleachVsNaruto)
![Created:Latest](https://img.shields.io/github/created-at/5DPLAY-Game-Studio/BleachVsNaruto)
![License:Latest](https://img.shields.io/github/license/5DPLAY-Game-Studio/BleachVsNaruto)

![TopLanguage:Latest](https://img.shields.io/github/languages/top/5DPLAY-Game-Studio/BleachVsNaruto)
![Tag:Latest](https://img.shields.io/github/v/tag/5DPLAY-Game-Studio/BleachVsNaruto)

**Bleach vs Naruto** is written in ***ActionScript 3.0*** scripting language and its main supported platforms include **Windows, MacOS, Android** .

The current major version is 3.7, and we are working on updating it, but it is not yet ideal. If you have any issues, please report them in the issue tracker (or any other contact method that can reach our team).

## Download Binary Game

If you only care about the binary files of this project and don't care how the game project is built, you should go to the official social media account of the game to get it. This page is only for developers.

## Changelog

For a detailed change log of this project, see the [CHANGELOG.md](CHANGELOG.md) file.

## How to build from source

To build this program from source, you should read the [HOW2BUILD.md](HOW2BUILD.md) file as a guide.

## Engineering Structure

- `BleachVsNaruto_FlashSrc` - Source files (extension: fla or xfl) of the required binary files (extension: swf)
- `CORE_Components` - Game interactive components
- `CORE_KernelLogic` - Game core logic
- `CORE_Shared` - Game external public interface
- `CORE_Utils` - A collection of common utilities for some games
- `LIB_KyoLib` - Personal library written by game author **剑jian**
- `LIB_Other` - Other libraries
- `SHELL_Dev` - Functional shell for developers
- `SHELL_Mob` - Functional shell running on mobile devices
- `SHELL_Pc` - Functional shell running on PC
- `shared` - Game Shared Resource Library
- `tools` - Engineering toolset

## License

**Bleach vs Naruto** uses [GPL-3.0] as the engineering development license. You should know and fully understand the license content in advance:

- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
- You should have received a copy of the GNU General Public License along with this program.  If not, see  <http://www.gnu.org/licenses> 。

## Contribute

**Bleach vs Naruto** Submissions and contributions from everyone are welcome.

The entire 5DPLAY community should abide by the code of conduct followed by this project itself.

## Translate

The establishment of the project is inseparable from the hard work of every member. In terms of international promotion, there are quite a few foreign players helping us with the localization process. I would like to sincerely thank these people for their efforts.

The following is a list of translators who contributed:

- `简体中文` - 5DPLAY
- `English` - MeleeWaluigi, Waffles.7z

## Follow us

[![Twitter:5Dplay](https://img.shields.io/twitter/follow/5Dplay)](https://x.com/5DPLAY)

[GPL-3.0]: https://www.gnu.org/licenses/gpl-3.0.html
