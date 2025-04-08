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
import mx.utils.StringUtil;

/**
 * Github 实用工具类
 */
public class GithubUtils {

    // 主分支名称
    public static const BRANCH_MASTER:String  = 'master';
    // 开发分支名称
    public static const BRANCH_DEVELOP:String = 'develop';

    // --------------------------------------------------
    // ★ 若属性 _masterCommitHash 或 _developCommitHash 的嵌
    //     入标签 Embed 标红，可以通过【文件(F)】->【设置(T)】->
    //     【编辑器】->【文件类型】->【忽略的文件和文件夹】选项卡中
    //     移除 【.git】 选项
    //
    //  ↓
    //  ↓
    // --------------------------------------------------

    /* 主分支提交哈希 */
    [Embed(source='/../../.git/refs/heads/master', mimeType='application/octet-stream')]
    private static const _masterCommitHash:Class;

    /* 开发分支提交哈希 */
    [Embed(source='/../../.git/refs/heads/develop', mimeType='application/octet-stream')]
    private static const _developCommitHash:Class;

    /**
     * 获取当前版本提交哈希
     *
     * @return 当前版本提交哈希
     */
    public static function getCommitsHash():String {
        var curCH:Class = IsDebugger() ? _developCommitHash : _masterCommitHash;
        var hash:String = String(new curCH());

        return StringUtil.trim(hash);
    }

    /**
     * 通过提交哈希前往提交地址
     * @param hash 提交哈希
     */
    public static function goCommitsByHash(hash:String):void {
        var branchUrl:String  = getBranchUrl();
        var commitsUrl:String = getCommitsUrlByHash(hash);

        URL.go(branchUrl, false);
        URL.go(commitsUrl, false);
    }

    /**
     * 获取分支地址
     *
     * @return 分支地址
     */
    public static function getBranchUrl():String {
        var branch:String = IsDebugger() ? BRANCH_DEVELOP : BRANCH_MASTER;
        return URL.GITHUB + '/commits/' + branch + '/';
    }

    /**
     * 通过提交哈希获取对应的GitHub地址
     *
     * @param hash 提交哈希
     *
     * @return 提交哈希对应的 GitHub 地址
     */
    public static function getCommitsUrlByHash(hash:String):String {
        return URL.GITHUB + '/commit/' + hash;
    }
}
}
