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
 * Non-interactive batch publish for BleachVsNaruto_FlashSrc.
 * Invoked by tools/script/publish.bat (do not use browseForFolderURL).
 *
 * Root path: tools/jsfl/_publish_root.txt (written by publish.bat),
 * or fallback from fl.scriptURI -> ../../BleachVsNaruto_FlashSrc.
 *
 * Result: tools/script/_publish_result.txt  (first line: 0=ok, 1=fail)
 */

var trace = fl.trace;

main();

function main() {
	var scriptDir = dirnameURI(fl.scriptURI);
	var rootFile = scriptDir + "/_publish_root.txt";
	var resultFile = scriptDir + "/../script/_publish_result.txt";

	writeResult(resultFile, "1");

	var folderUrl = readRootURI(rootFile);
	if (!folderUrl) {
		folderUrl = scriptDir + "/../../BleachVsNaruto_FlashSrc";
	}
	folderUrl = normalizeDirURI(folderUrl);

	if (!FLfile.exists(folderUrl)) {
		trace("[publish_flashsrc] FlashSrc root not found: " + folderUrl);
		writeResult(resultFile, "1");
		tryQuit();
		return;
	}

	trace("[publish_flashsrc] Root: " + folderUrl);

	var files = getFilesByDir(folderUrl);
	var count = 0;
	var fail = 0;
	var successArr = [];

	for (var i = 0; i < files.length; i++) {
		var file = files[i];
		var smplUrl = file.split(folderUrl).join("");
		if (!publishFile(file)) {
			fail++;
			trace("[publish_flashsrc] FAIL: " + smplUrl);
			continue;
		}
		count++;
		successArr.push(smplUrl);
		trace("[publish_flashsrc] OK: " + smplUrl);
	}

	trace("[publish_flashsrc] file_count=" + files.length + " success=" + count + " fail=" + fail);

	if (files.length > 0 && fail === 0) {
		writeResult(resultFile, "0");
	} else if (files.length === 0) {
		trace("[publish_flashsrc] No fla/xfl found.");
		writeResult(resultFile, "1");
	} else {
		writeResult(resultFile, "1");
	}

	tryQuit();
}

function readRootURI(rootFile) {
	if (!FLfile.exists(rootFile)) {
		return null;
	}
	var raw = FLfile.read(rootFile);
	if (!raw) {
		return null;
	}
	raw = String(raw).replace(/^\s+|\s+$/g, "");
	if (!raw) {
		return null;
	}
	if (raw.indexOf("file://") === 0) {
		return raw;
	}
	return winPathToURI(raw);
}

function winPathToURI(path) {
	path = String(path).replace(/\\/g, "/");
	if (path.charAt(1) === ":") {
		return "file:///" + path.charAt(0) + "|" + path.substring(2);
	}
	if (path.charAt(0) === "/") {
		return "file://" + path;
	}
	return path;
}

function normalizeDirURI(uri) {
	uri = String(uri);
	while (uri.length > 0 && (uri.charAt(uri.length - 1) === "/" || uri.charAt(uri.length - 1) === "\\")) {
		uri = uri.substring(0, uri.length - 1);
	}
	return uri;
}

function dirnameURI(uri) {
	uri = String(uri);
	var idx = uri.lastIndexOf("/");
	if (idx < 0) {
		return uri;
	}
	return uri.substring(0, idx);
}

function writeResult(resultFile, code) {
	try {
		FLfile.write(resultFile, String(code) + "\n");
	} catch (e) {
		trace("[publish_flashsrc] Cannot write result: " + e);
	}
}

function tryQuit() {
	try {
		fl.quit();
	} catch (e) {
		trace("[publish_flashsrc] fl.quit() not available: " + e);
	}
}

/**
 * Collect publishable fla / dir/dir.xfl under dirUrl (same rules as Batch Release.jsfl).
 */
function getFilesByDir(dirUrl) {
	var files = [];
	var flaMask = "*.fla";
	var xflSuf = ".xfl";

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
		var dir = dirList[j];
		var curDir = dirUrl + "/" + dir;
		var xflFile = curDir + "/" + dir + xflSuf;

		if (!FLfile.exists(xflFile)) {
			files = files.concat(getFilesByDir(curDir));
			continue;
		}
		files.push(xflFile);
	}

	return files;
}

function publishFile(file) {
	var doc = null;
	try {
		doc = fl.openDocument(file);
	} catch (e) {
		trace("[publish_flashsrc] openDocument error: " + e);
		return false;
	}

	if (!doc) {
		return false;
	}

	try {
		doc.publish();
	} catch (e2) {
		trace("[publish_flashsrc] publish error: " + e2);
		try {
			doc.close(false);
		} catch (e3) {}
		return false;
	}

	try {
		doc.close(false);
	} catch (e4) {}

	return true;
}
