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

package net.play5d.game.bvn.utils {
import flash.utils.ByteArray;

import mx.utils.StringUtil;

/**
 * Github 实用工具类
 *
 * <p>在编译期通过 <code>[Embed]</code> 嵌入 <code>master</code> / <code>develop</code> 分支 tip 的提交哈希，
 * 运行时按 <code>IsDebugger()</code> 选择对应分支 hash 并拼接 GitHub 链接。</p>
 *
 * <p><b>注意：</b>此处 hash 为<b>编译时刻</b>分支 tip，并非当前 <code>HEAD</code> 或本次构建所在分支。</p>
 *
 * @see URL#GITHUB
 */
public class GithubUtils {

    /** Git 完整提交哈希格式（40 位十六进制） */
    private static const HASH_PATTERN:RegExp = /^[0-9a-f]{40}$/i;

    /** 短 hash 显示长度（与 Git 默认 abbreviated 一致） */
    private static const HASH_SHORT_LENGTH:uint = 7;

    /** 主分支名称 */
    public static const BRANCH_MASTER:String  = 'master';
    /** 开发分支名称 */
    public static const BRANCH_DEVELOP:String = 'develop';

    /** 缓存的主分支 tip 提交哈希；<code>null</code> 表示尚未读取 */
    private static var _cachedMasterHash:String;

    /** 缓存的开发分支 tip 提交哈希；<code>null</code> 表示尚未读取 */
    private static var _cachedDevelopHash:String;

    // --------------------------------------------------
    // ★ 若属性 _masterCommitHash 或 _developCommitHash 的嵌
    //     入标签 Embed 标红，可以通过【文件(F)】->【设置(T)】->
    //     【编辑器】->【文件类型】->【忽略的文件和文件夹】选项卡中
    //     移除 【.git】 选项
    //
    //  ↓
    //  ↓
    // --------------------------------------------------

    /** 主分支提交哈希 */
    [Embed(source='/../../.git/refs/heads/master', mimeType='application/octet-stream')]
    private static const _masterCommitHash:Class;

    /** 开发分支提交哈希 */
    [Embed(source='/../../.git/refs/heads/develop', mimeType='application/octet-stream')]
    private static const _developCommitHash:Class;

    /**
     * 获取编译期嵌入的分支 tip 提交哈希
     *
     * <p>调试版（<code>IsDebugger()</code> 为 <code>true</code>）返回 <code>develop</code> 分支 tip；
     * 否则返回 <code>master</code> 分支 tip。</p>
     *
     * @return 40 位提交哈希；读取或校验失败时返回空字符串
     */
    public static function getCommitsHash():String {
        return IsDebugger() ? getDevelopCommitHash() : getMasterCommitHash();
    }

    /**
     * 获取当前运行时对应分支的短提交哈希（前 7 位）
     *
     * @return 短 hash；完整 hash 无效时返回空字符串
     */
    public static function getCommitsHashShort():String {
        var hash:String = getCommitsHash();
        if (!isValidHash(hash)) {
            return '';
        }

        return hash.substr(0, HASH_SHORT_LENGTH);
    }

    /**
     * 获取当前运行时对应的分支名称
     *
     * <p>调试版（<code>IsDebugger()</code> 为 <code>true</code>）返回 <code>develop</code>；
     * 否则返回 <code>master</code>。</p>
     *
     * @return 分支名称
     */
    public static function getCommitBranch():String {
        return IsDebugger() ? BRANCH_DEVELOP : BRANCH_MASTER;
    }

    /**
     * 获取 Credits 等 UI 使用的提交展示文本
     *
     * <p>格式为 <code>分支@短hash</code>，例如 <code>develop@a8dbce1</code>。</p>
     *
     * @return 展示文本；hash 无效时返回空字符串
     */
    public static function getCommitsDisplayLabel():String {
        var hashShort:String = getCommitsHashShort();
        if (!hashShort) {
            return '';
        }

        return getCommitBranch() + '@' + hashShort;
    }

    /**
     * 通过提交哈希在浏览器中打开 GitHub 提交页
     *
     * @param hash 提交哈希
     */
    public static function goCommitsByHash(hash:String):void {
        URL.go(getCommitsUrlByHash(hash), false);
    }

    /**
     * 获取分支提交列表地址
     *
     * @return 分支提交列表 GitHub 地址
     */
    public static function getBranchUrl():String {
        return URL.GITHUB + '/commits/' + getCommitBranch() + '/';
    }

    /**
     * 通过提交哈希获取对应的 GitHub 地址
     *
     * @param hash 提交哈希
     *
     * @return 提交页地址；hash 无效时返回仓库首页地址
     */
    public static function getCommitsUrlByHash(hash:String):String {
        if (!isValidHash(hash)) {
            return URL.GITHUB;
        }

        return URL.GITHUB + '/commit/' + hash;
    }

    /**
     * 获取并缓存主分支 tip 提交哈希
     *
     * @return 40 位提交哈希；读取或校验失败时返回空字符串
     */
    private static function getMasterCommitHash():String {
        if (_cachedMasterHash == null) {
            _cachedMasterHash = readEmbeddedHash(_masterCommitHash);
        }

        return _cachedMasterHash;
    }

    /**
     * 获取并缓存开发分支 tip 提交哈希
     *
     * @return 40 位提交哈希；读取或校验失败时返回空字符串
     */
    private static function getDevelopCommitHash():String {
        if (_cachedDevelopHash == null) {
            _cachedDevelopHash = readEmbeddedHash(_developCommitHash);
        }

        return _cachedDevelopHash;
    }

    /**
     * 读取 Embed 嵌入的分支 ref 文件内容并校验为合法提交哈希
     *
     * @param embedClass Embed 生成的 <code>Class</code> 引用
     *
     * @return 40 位提交哈希；读取或校验失败时返回空字符串
     */
    private static function readEmbeddedHash(embedClass:Class):String {
        var bytes:ByteArray = new embedClass() as ByteArray;
        if (!bytes || bytes.length == 0) {
            return '';
        }

        bytes.position = 0;

        var hash:String = StringUtil.trim(bytes.readUTFBytes(bytes.length));
        return isValidHash(hash) ? hash : '';
    }

    /**
     * 校验是否为合法的 Git 完整提交哈希
     *
     * @param hash 待校验字符串
     *
     * @return 合法返回 <code>true</code>，否则返回 <code>false</code>
     */
    private static function isValidHash(hash:String):Boolean {
        return hash && HASH_PATTERN.test(hash);
    }
}
}
