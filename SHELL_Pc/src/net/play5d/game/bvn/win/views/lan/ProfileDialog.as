/*
 * Copyright (C) 2021-2024, 5DPLAY Game Studio
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

package net.play5d.game.bvn.win.views.lan {
import flash.display.DisplayObject;
import flash.display.MovieClip;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.win.data.LanGameModel;
import net.play5d.game.bvn.win.utils.UIAssetUtil;
import net.play5d.kyo.stage.IStage;
import net.play5d.kyo.utils.KyoBtnUtils;

public class ProfileDialog implements IStage {
    public function ProfileDialog() {
    }
    public var onClose:Function;
    private var _ui:MovieClip;

    /**
     * 显示对象
     */
    public function get display():DisplayObject {
        return _ui;
    }

    /**
     * 构建
     */
    public function build():void {
        _ui = UIAssetUtil.I.createDisplayObject('profile_win_mc');

        KyoBtnUtils.initBtn(_ui.btn_ok, okHandler);
        KyoBtnUtils.initBtn(_ui.btn_close, close);

        _ui.txt.text = LanGameModel.I.playerName;
    }

    public function close():void {
        MainGame.stageCtrl.removeLayer(this);
        if (onClose != null) {
            onClose();
        }
    }

    /**
     * 稍后构建
     */
    public function afterBuild():void {
    }

    /**
     * 销毁
     * @param back 回调函数
     */
    public function destroy(back:Function = null):void {
        KyoBtnUtils.disposeBtn(_ui.btn_ok);
        KyoBtnUtils.disposeBtn(_ui.btn_close);
    }

    private function okHandler():void {
        var newName:String = _ui.txt.text;
        if (newName == '') {
            GameUI.alert('请输入名字');
            return;
        }

        LanGameModel.I.playerName = newName;

        GameData.I.saveData();

        close();
    }
}
}
