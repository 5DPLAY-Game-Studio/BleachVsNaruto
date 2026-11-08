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
 * BleachVsNaruto_FlashSrc 非交互批量发布脚本。
 * 由 tools/script/publish.bat 调用（勿使用 browseForFolderURL）。
 *
 * 根路径：tools/script/log/_publish_root.txt（由 publish.bat 以 UTF-8 写入）。
 * FLfile.read 按 UTF-8 解码；GBK 文件会在第一个中文字节处截成 D:\，
 * 该 URI 指向盘符且 exists 为真，会递归发布该盘上的其他 fla。
 * 若不存在则回退为 fl.scriptURI 相对路径 ../../BleachVsNaruto_FlashSrc。
 * 路径中的空格与 & 会百分号编码后再交给 FLfile。
 * 解析结果不是以 BleachVsNaruto_FlashSrc 结尾则拒绝发布。
 *
 * 结果：tools/script/log/_publish_result.txt（首行：0=成功，1=失败）。
 */

/** 日志前缀 */
var LOG_TAG = "[publish_flashsrc]";

/** @type {Function} */
var trace = fl.trace;

/** @type {string[]} */
var logLines = [];

main();

/**
 * 入口：读根目录 → 收集 fla/xfl → 逐个发布 → 写结果并退出。
 */
function main() {
	var scriptDir  = escapeFileURI(dirnameURI(fl.scriptURI));
	var rootFile   = scriptDir + "/../script/log/_publish_root.txt";
	var resultFile = scriptDir + "/../script/log/_publish_result.txt";

	// 先写失败码，避免 Animate 异常退出时 bat 误判成功
	writeResult(resultFile, "1");

	var folderUrl = readRootURI(rootFile) || escapeFileURI(scriptDir + "/../../BleachVsNaruto_FlashSrc");
	folderUrl = normalizeDirURI(folderUrl);

	// 截断成盘符时 exists 仍为真，会把 D 盘其他目录的 fla 一并发布
	if (!isFlashSrcRoot(folderUrl)) {
		log("Refuse publish, root is not BleachVsNaruto_FlashSrc: " + folderUrl);
		writeResult(resultFile, "1");
		tryQuit();
		return;
	}

	if (!FLfile.exists(folderUrl)) {
		log("FlashSrc root not found: " + folderUrl);
		writeResult(resultFile, "1");
		tryQuit();
		return;
	}

	log("Root: " + folderUrl);

	var files = getFilesByDir(folderUrl);
	var ok    = 0;
	var fail  = 0;

	for (var i = 0; i < files.length; i++) {
		var file    = files[i];
		var relPath = toRelPath(file, folderUrl);

		if (!publishFile(file)) {
			fail++;
			log("FAIL: " + relPath);
			continue;
		}

		ok++;
		log("OK: " + relPath);
	}

	log("file_count=" + files.length + " success=" + ok + " fail=" + fail);

	// 至少有一个文件且全部成功才写 0
	if (files.length > 0 && fail === 0) {
		writeResult(resultFile, "0");
	}
	else {
		if (files.length === 0) {
			log("No fla/xfl found.");
		}
		writeResult(resultFile, "1");
	}

	tryQuit();
}

/**
 * 带前缀输出日志，并记入结果文件。
 * @param {string} msg 日志内容
 */
function log(msg) {
	var line = LOG_TAG + " " + msg;
	trace(line);
	logLines.push(line);
}

/**
 * 从 _publish_root.txt 读取 FlashSrc 根 URI。
 * 支持 file:// URI 或 Windows 路径。
 * @param {string} rootFile 根路径文件 URI
 * @return {string|null} 规范化前的根 URI；文件不存在或为空时返回 null
 */
function readRootURI(rootFile) {
	if (!FLfile.exists(rootFile)) {
		return null;
	}

	var raw = trimString(FLfile.read(rootFile));
	if (raw.charAt(0) === "\uFEFF") {
		raw = raw.substring(1);
	}
	if (!raw) {
		return null;
	}

	if (raw.indexOf("file://") === 0) {
		return escapeFileURI(raw);
	}

	return winPathToURI(raw);
}

/**
 * 将 Windows 路径转为 JSFL file URI，并对每一段做百分号编码。
 * 例：D:/a b/c&d → file:///D|/a%20b/c%26d
 * @param {string} path Windows 或 POSIX 路径
 * @return {string} file URI 或原样返回
 */
function winPathToURI(path) {
	path = String(path).replace(/\\/g, "/");

	// D:/... → file:///D|/...
	if (path.charAt(1) === ":") {
		return "file:///" + path.charAt(0) + "|" + encodePathTail(path.substring(2));
	}

	// /... → file:///...
	if (path.charAt(0) === "/") {
		return "file://" + encodePathTail(path);
	}

	return escapeFileURI(path);
}

/**
 * 编码路径中 / 以外的各段。空段跳过，避免出现双斜杠。
 * @param {string} path 使用 / 的路径
 * @return {string} 以 / 连接的编码结果
 */
function encodePathTail(path) {
	var parts = String(path).split("/");
	var encoded = "";
	for (var i = 0; i < parts.length; i++) {
		if (!parts[i]) {
			continue;
		}
		encoded += "/" + encodePathSegment(parts[i]);
	}
	return encoded;
}

/**
 * 编码单个路径段。只转义空格与 &（及 #），中文保持原样。
 * encodeURIComponent 会把中文变成 %E4%BB%A3 这类序列，FLfile 无法打开。
 * @param {string} seg 原始路径段
 * @return {string} 编码后的路径段
 */
function encodePathSegment(seg) {
	return escapeFileURI(seg);
}

/**
 * 转义 URI 里未编码的空格与 &，避免 FLfile 把路径截成盘符。
 * @param {string} uri 可能含空格或 & 的 URI
 * @return {string} 替换后的 URI
 */
function escapeFileURI(uri) {
	return String(uri).replace(/ /g, "%20").replace(/&/g, "%26").replace(/#/g, "%23");
}

/**
 * 仅允许发布 BleachVsNaruto_FlashSrc 目录本身。
 * @param {string} uri 规范化后的目录 URI
 * @return {boolean} 是否以 FlashSrc 目录名结尾
 */
function isFlashSrcRoot(uri) {
	var tail = "BleachVsNaruto_FlashSrc";
	uri = String(uri);
	if (uri.length < tail.length) {
		return false;
	}
	return uri.substring(uri.length - tail.length) === tail;
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
 * 取 URI 的父目录部分。
 * @param {string} uri 文件或目录 URI
 * @return {string} 父目录 URI
 */
function dirnameURI(uri) {
	uri = String(uri);
	var idx = uri.lastIndexOf("/");
	if (idx < 0) {
		return uri;
	}
	return uri.substring(0, idx);
}

/**
 * 得到相对根目录的简化路径（用于日志）。
 * @param {string} file     完整文件 URI
 * @param {string} folderUrl 根目录 URI（无尾部斜杠）
 * @return {string} 相对路径
 */
function toRelPath(file, folderUrl) {
	return String(file).split(folderUrl).join("");
}

/**
 * 去除首尾空白。
 * @param {*} value 任意值
 * @return {string} 去空白后的字符串；空输入返回 ""
 */
function trimString(value) {
	if (value == null) {
		return "";
	}
	return String(value).replace(/^\s+|\s+$/g, "");
}

/**
 * 写入发布结果码供 publish.bat 读取。
 * @param {string} resultFile 结果文件 URI
 * @param {string} code       "0"=成功，"1"=失败
 */
function writeResult(resultFile, code) {
	var body = String(code);
	if (logLines.length > 0) {
		body += "\n" + logLines.join("\n");
	}
	body += "\n";
	try {
		FLfile.write(resultFile, body);
	}
	catch (e) {
		trace(LOG_TAG + " Cannot write result: " + e);
	}
}

/**
 * 尝试退出 Animate（命令行 -run-jsfl 场景）。
 * IDE 内手动运行时可能不可用，仅打日志。
 */
function tryQuit() {
	try {
		fl.quit();
	}
	catch (e) {
		log("fl.quit() not available: " + e);
	}
}

/**
 * 递归收集可发布文件（规则同 Batch Release.jsfl）。
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
			files.push(dirUrl + "/" + encodePathSegment(flaFileList[i]));
		}
	}

	var dirList = FLfile.listFolder(dirUrl, "directories");
	if (!dirList) {
		return files;
	}

	for (var j = 0; j < dirList.length; j++) {
		var dir     = dirList[j];
		var encDir  = encodePathSegment(dir);
		var curDir  = dirUrl + "/" + encDir;
		var xflFile = curDir + "/" + encDir + xflSuf;

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
		log("openDocument error: " + e);
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
		log("publish error: " + e);
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
