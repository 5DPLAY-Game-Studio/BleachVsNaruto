/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * BleachVsNaruto_FlashSrc 交互式批量发布脚本。
 * 在 Animate / Flash 中手动运行：弹出目录选择 → 递归发布 fla/xfl。
 *
 * 非交互批处理请用 publish_flashsrc.jsfl（由 publish.bat 调用）。
 */

/**
 * 多语言文案。
 * 键：zh_CN / en_US / ja_JP / ko_KR
 */
var langObj = {
	browse_for_folder_url: {
		zh_CN: "请选择 BleachVsNaruto_FlashSrc 目录位置",
		en_US: "Please select the BleachVsNaruto_FlashSrc directory location",
		ja_JP: "BleachVsNaruto_FlashSrc ディレクトリの場所を選択してください",
		ko_KR: "BleachVsNaruto_FlashSrc 디렉토리 위치를 선택하세요"
	},
	publish_ok: {
		zh_CN: "发布成功：",
		en_US: "Publish OK: ",
		ja_JP: "公開成功：",
		ko_KR: "릴리스 성공: "
	},
	publish_fail: {
		zh_CN: "发布失败：",
		en_US: "Publish FAIL: ",
		ja_JP: "公開失敗：",
		ko_KR: "릴리스 실패: "
	},
	file_count: {
		zh_CN: "文件计数：",
		en_US: "File Count: ",
		ja_JP: "ファイル数：",
		ko_KR: "파일 수: "
	},
	success_count: {
		zh_CN: "成功计数：",
		en_US: "Success Count: ",
		ja_JP: "成功回数：",
		ko_KR: "성공 횟수: "
	},
	fail_count: {
		zh_CN: "失败计数：",
		en_US: "Fail Count: ",
		ja_JP: "失敗回数：",
		ko_KR: "실패 횟수: "
	},
	no_files: {
		zh_CN: "未找到可发布的 fla/xfl。",
		en_US: "No publishable fla/xfl found.",
		ja_JP: "公開可能な fla/xfl が見つかりません。",
		ko_KR: "게시 가능한 fla/xfl 을(를) 찾지 못했습니다."
	}
};

/** 缺省语言（IDE 语言无对应文案时回退） */
var defaultLang = "en_US";

/** @type {Function} */
var trace = fl.trace;

main();

/**
 * 入口：选目录 → 收集 fla/xfl → 逐个发布 → 输出汇总。
 */
function main() {
	var folderUrl = fl.browseForFolderURL(getLangText("browse_for_folder_url"));
	if (!folderUrl || !FLfile.exists(folderUrl)) {
		return;
	}

	folderUrl = normalizeDirURI(folderUrl);

	var files = getFilesByDir(folderUrl);
	var ok    = 0;
	var fail  = 0;

	for (var i = 0; i < files.length; i++) {
		var file    = files[i];
		var relPath = toRelPath(file, folderUrl);

		if (!publishFile(file)) {
			fail++;
			trace(getLangText("publish_fail") + relPath);
			continue;
		}

		ok++;
		trace(getLangText("publish_ok") + relPath);
	}

	if (files.length === 0) {
		trace(getLangText("no_files"));
	}

	trace(
		getLangText("file_count") + files.length + "\t" +
		getLangText("success_count") + ok + "\t" +
		getLangText("fail_count") + fail
	);
}

/**
 * 去掉目录 URI 末尾的 / 或 \。
 * @param {string} uri 目录 URI
 * @return {string} 无尾部分隔符的 URI
 */
function normalizeDirURI(uri) {
	return String(uri).replace(/[\/\\]+$/, "");
}

/**
 * 得到相对根目录的简化路径（用于日志）。
 * @param {string} file      完整文件 URI
 * @param {string} folderUrl 根目录 URI（无尾部斜杠）
 * @return {string} 相对路径
 */
function toRelPath(file, folderUrl) {
	return String(file).split(folderUrl).join("");
}

/**
 * 递归收集可发布文件。
 * - 当前目录下的 *.fla
 * - 子目录名/子目录名.xfl（存在则整包加入，不再深入）
 * - 无同名 .xfl 的子目录继续递归
 * @param {string} dirUrl 搜索目录 URI
 * @return {string[]} 可发布文件 URI 列表
 */
function getFilesByDir(dirUrl) {
	var files   = [];
	var flaMask = "*.fla";
	var xflSuf  = ".xfl";

	// 当前目录下的全部 .fla
	var flaFileList = FLfile.listFolder(dirUrl + "/" + flaMask, "files");
	if (flaFileList) {
		for (var i = 0; i < flaFileList.length; i++) {
			files.push(dirUrl + "/" + flaFileList[i]);
		}
	}

	var dirList = FLfile.listFolder(dirUrl, "directories");
	if (!dirList) {
		return files;
	}

	for (var j = 0; j < dirList.length; j++) {
		var dir     = dirList[j];
		var curDir  = dirUrl + "/" + dir;
		var xflFile = curDir + "/" + dir + xflSuf;

		// 无同名 .xfl：当作普通子目录继续搜
		if (!FLfile.exists(xflFile)) {
			files = files.concat(getFilesByDir(curDir));
			continue;
		}

		files.push(xflFile);
	}

	return files;
}

/**
 * 打开并发布单个 fla/xfl，发布后不保存关闭。
 * @param {string} file 文件 URI
 * @return {boolean} 是否发布成功
 */
function publishFile(file) {
	var doc = null;

	try {
		doc = fl.openDocument(file);
	}
	catch (e) {
		trace("openDocument error: " + e);
		return false;
	}

	if (!doc) {
		return false;
	}

	var ok = false;
	try {
		doc.publish();
		ok = true;
	}
	catch (e) {
		trace("publish error: " + e);
	}

	// 无论成败都尝试关闭，避免文档残留影响后续发布
	try {
		doc.close(false);
	}
	catch (e) {
		// 关闭失败不影响成败判定
	}

	return ok;
}

/**
 * 取当前 IDE 语言对应文案，缺失则回退 defaultLang。
 * @param {string} node langObj 键名
 * @return {string} 文案；节点不存在时返回 "[N/A]"
 */
function getLangText(node) {
	if (!langObj || !langObj[node]) {
		return "[N/A]";
	}

	var entry = langObj[node];
	return entry[fl.languageCode] || entry[defaultLang] || "[N/A]";
}
