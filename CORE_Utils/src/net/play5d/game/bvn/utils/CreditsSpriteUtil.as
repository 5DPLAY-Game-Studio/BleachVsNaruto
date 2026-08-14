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

package net.play5d.game.bvn.utils {
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

/**
 * 制作人员名单 Sprite 构建工具。
 *
 * <p>拼接 GitHub 提交页脚并生成黄色多行 HTML 文本；壳可在返回的
 * <code>Sprite</code> 上继续追加平台专属内容（如打赏二维码）。</p>
 *
 * @see GithubUtils
 */
public class CreditsSpriteUtil {

    /**
     * 构建制作人员名单显示对象。
     *
     * @param creditsInfo 基础 HTML 文案。
     * @param footerLangKey 页脚多语言键（接收 <code>url</code>/<code>label</code>）。
     * @return 含 TextField 的 Sprite。
     *
     * @example
     * <listing version="3.0">
     * return CreditsSpriteUtil.build(info, 'txt.game_interface_manager.credits_footer');
     * </listing>
     */
    public static function build(creditsInfo:String, footerLangKey:String):Sprite {
        var sp:Sprite = new Sprite();

        var commitsHash:String  = GithubUtils.getCommitsHash();
        var commitsUrl:String   = GithubUtils.getCommitsUrlByHash(commitsHash);
        var commitsLabel:String = GithubUtils.getCommitsDisplayLabel();
        creditsInfo += GetLang(footerLangKey, {
            url  : commitsUrl,
            label: commitsLabel
        });

        var txt:TextField = new TextField();

        var tf:TextFormat = new TextFormat();
        tf.font           = FONT.fontName;
        tf.size           = 17;
        tf.color          = 0xffff00;
        tf.leading        = 10;

        txt.defaultTextFormat = tf;

        txt.multiline = true;
        txt.htmlText  = creditsInfo;
        txt.autoSize  = TextFieldAutoSize.LEFT;

        txt.x = 30;
        txt.y = 25;

        sp.addChild(txt);

        return sp;
    }
}
}
