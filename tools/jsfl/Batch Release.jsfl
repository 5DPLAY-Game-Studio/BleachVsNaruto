/*
 * Copyright (C) 2021-2025, 5DPLAY Game Studio
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

// 语言字典对象
// zh_CN 简体中文
// en_US 英语
// ja_JP 日语
// ko_KR 韩语
var langObj = {
	browse_for_folder_url: {
		zh_CN: "请选择 BleachVsNaruto_FlashSrc 目录位置",
		en_US: "Please select the BleachVsNaruto_FlashSrc directory location",
		ja_JP: "BleachVsNaruto_FlashSrc ディレクトリの場所を選択してください",
		ko_KR: "BleachVsNaruto_FlashSrc 디렉토리 위치를 선택하세요"
	},
	publish_end: {
		zh_CN: "发布完成：",
		en_US: "Publish completed: ",
		ja_JP: "公開終了：",
		ko_KR: "릴리스 완료: "
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
	}
};
// 默认语言
var defaultLang = "en_US";
// 跟踪函数
var trace = fl.trace;

// 执行主方法
main();
 
/**
 * 主方法
 */
function main() {
	// 选取 BleachVsNaruto_FlashSrc 目录位置
	var folderUrl = fl.browseForFolderURL(getLangText("browse_for_folder_url"));
	if (!FLfile.exists(folderUrl)) {
		return;
	}
	
	// 成功计数
	var count      = 0;
	// 成功发布的文件数组
	var successArr = [];
	
	// 获取指定目录下的全部可发布文件（fla/xfl）
	var files = getFilesByDir(folderUrl);
//	trace("全部文件: " + files);
//	return;
	
	// 遍历全部合法的可发布文件
	for each (var file in files) {
		// 将发布文件路径消除前缀以简化表示
		var smplUrl = file.replace(folderUrl, "");
		
		// 发布文件
		if (!publishFile(file)) {
			// 发布失败，跳到下个计次
			continue;
		}
		
		// 发布成功，计数 +1，发布成功文件数组添加简化路径
		count++;
		successArr.push(smplUrl);
	}
	
	// 遍历全部已发布成功的文件
	for each (var fileUrl in successArr) {
		trace(getLangText("publish_end") + fileUrl);
	}
	
	// 输出信息
	trace(getLangText("file_count") + files.length + "\t" + getLangText("success_count") + count);
 }

/**
 * 获取指定目录下的全部可发布文件（fla/xfl）
 * 
 * @return 指定目录下的全部可发布文件（fla/xfl）
 */
function getFilesByDir(dirUrl) {
//	trace("\n搜索目录：" + dirUrl);
	
	// 指定目录下的全部可发布文件（fla/xfl）组成的数组
	var files = [];
	
	// fla 后缀
	var flaMask = "*.fla";
	// xfl 后缀
	var xflSuf  = ".xfl";
	
	
	// 将当前目录下的所有 fla 文件加入文件列表
	var flaFileList = FLfile.listFolder(dirUrl + "/" + flaMask, "files");
	for each (var flaFile in flaFileList) {
		files.push(dirUrl + "/" + flaFile);
	}
//	trace("目录 " + dirUrl + " 的所有 fla 文件：" + files);
	
	
	
	// 将当前目录下符合 子目录名/子目录名.xfl 的 xfl 文件加入文件列表 
	var dirList = FLfile.listFolder(dirUrl, "directories");
	for each (var dir in dirList) {
		// 当前文件夹路径
		var curDir  = dirUrl + "/" + dir;
		// 当前可能存在的 xfl 文件名称
		var xflFile = curDir + "/" + dir + xflSuf;
		
		// 如果不存在 xfl 文件，将该子目录递归查找，并将子目录的结果链接
		if (!FLfile.exists(xflFile)) {
//			trace("xfl 文件 " + xflFile + " 不存在，将开始作为子目录递归查找");
			
			files = files.concat(getFilesByDir(curDir));
			continue;
		}
		
//		trace("目录 " + dirUrl + " 的 xfl 文件：" + xflFile);

		// 加入列表
		files.push(xflFile);
	}
	
//	trace("目录 " + dirUrl + " 的全部文件：" + files);
	return files;
}

/** 
 * 发布指定文件
 * 
 * @param file 要发布的文件
 */
function publishFile(file) {
	var doc = fl.openDocument(file);
	
	if (!doc) {
		return false;
	}
	
	// 发布文件
	doc.publish();
	// 关闭文件，并且不保存所作的修改
	doc.close(false);
	
	return true;
}

/**
 * 获取指定语言文本
 * 
 * @param node 语言节点
 * @return 指定语言文本
 */
function getLangText(node) {
	if (!langObj) {
		return "[N/A]";
	}
	
	// 获取当前语言代码
	var langCode = fl.languageCode;
	// 当前语言的文本
	var langText = langObj[node][langCode];
	
	// 如果当前语言的文本不存在，则获取默认语言的文本
	if (!langText) {
		langText = langObj[node][defaultLang];
	}
	
	return langText;
}