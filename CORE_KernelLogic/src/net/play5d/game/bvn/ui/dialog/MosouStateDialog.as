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

package net.play5d.game.bvn.ui.dialog {
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;

import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.data.FighterModel;
import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.musou.LevelModel;
import net.play5d.game.bvn.data.musou.player.MusouFighterVO;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.ui.Text;
import net.play5d.game.bvn.ui.dialog.musou_state.BigFaceUI;
import net.play5d.game.bvn.ui.musou.CoinUI;
import net.play5d.game.bvn.utils.BtnUtils;
import net.play5d.game.bvn.utils.ResUtils;

public class MosouStateDialog extends BaseDialog {
    include '../../../../../../../include/_INCLUDE_OVERRIDE_.as';

    public function MosouStateDialog() {
        super();

        width  = 741;
        height = 478;

        offsetY = 20;

        _ui       = ResUtils.I.createDisplayObject(ResUtils.swfLib.dialog, 'dialog_mosou_status');
        _dialogUI = _ui;

        _coinUI = new CoinUI(_ui.getChildByName('coinmc') as MovieClip);

        _bigFaces = new Vector.<BigFaceUI>();
        _bigFaces.push(new BigFaceUI(_ui.getChildByName('p0') as Sprite));
        _bigFaces.push(new BigFaceUI(_ui.getChildByName('p1') as Sprite));
        _bigFaces.push(new BigFaceUI(_ui.getChildByName('p2') as Sprite));

        _leaderBtn = _ui.getChildByName('leader') as SimpleButton;
        _changeBtn = _ui.getChildByName('change') as SimpleButton;

        BtnUtils.initBtn(_leaderBtn, btnHandler);
        BtnUtils.initBtn(_changeBtn, btnHandler);

        _nameText = new Text(0XFFFFFF);

        _lvText = new Text(0XFFFFFF, 14);

        _introText         = new Text(0XFFFFFF, 16);
        _introText.leading = 18;

        _introText2         = new Text(0XFFFFFF, 16);
        _introText2.leading = 18;

        _expText = new Text(0XCCCCCC, 14);

        var ct:Sprite = _ui.getChildByName('ct_fighter') as Sprite;
        if (ct) {
            _nameText.x = 75;
            _nameText.y = 30;
            ct.addChild(_nameText);

            _lvText.x = 220;
            _lvText.y = 55;
            ct.addChild(_lvText);

            _expText.x = 10;
            _expText.y = 90;
            ct.addChild(_expText);

            _introText.x = 10;
            _introText.y = 130;
            ct.addChild(_introText);

            _introText2.x = 180;
            _introText2.y = 130;
            ct.addChild(_introText2);

        }

    }
    private var _ui:dialog_mosou_status;
    private var _bigFaces:Vector.<BigFaceUI>;
    private var _leaderBtn:SimpleButton;
    private var _changeBtn:SimpleButton;
    private var _currentFighter:MusouFighterVO;
    private var _coinUI:CoinUI;
    private var _nameText:Text;
    private var _lvText:Text;
    private var _introText:Text;
    private var _introText2:Text;
    private var _expText:Text;
    private var _changeIndex:int;
    private var _face:Sprite;

    protected override function onShow():void {
        initBigFaces();
        updateCurrentFighter();
    }

    protected override function onClose():void {
        GameEvent.dispatchEvent(GameEvent.MOSOU_FIGHTER_CLOSE);
    }

    protected override function onDestory():void {
        if (_coinUI) {
            _coinUI.destory();
            _coinUI = null;
        }
    }

    protected override function onResume():void {
        super.onResume();
        updateBigFaces();
        updateCurrentFighter();
    }

    private function btnHandler(b:DisplayObject):void {
        if (b == _leaderBtn) {
            GameData.I.mosouData.setLeader(_currentFighter);
            GameData.I.saveData();
            for each(var i:BigFaceUI in _bigFaces) {
                i.updateLeader();
            }
        }
        if (b == _changeBtn) {
            _changeIndex = GameData.I.mosouData.getFighterTeam().indexOf(_currentFighter);
            if (_changeIndex < 0) {
                _changeIndex = 0;
            }
            DialogManager.showDialog(new MosouSelectDialog(_changeIndex));
        }
    }

    private function updateCurrentFighter():void {
        _currentFighter = _bigFaces[0].getFighter();
        if (!_currentFighter) {
            return;
        }

        var fv:FighterVO = FighterModel.I.getFighter(_currentFighter.id);
        if (!fv) {
            return;
        }

        var ct:Sprite = _ui.getChildByName('ct_fighter') as Sprite;
        if (!ct) {
            return;
        }

//			ct.removeChildren();

        if (_face) {
            ct.removeChild(_face);
        }

        var face:DisplayObject = AssetManager.I.getFighterFace(fv);

        if (face) {
            _face   = ResUtils.I.createDisplayObject(ResUtils.swfLib.dialog, 'face_ui_mc');
            _face.x = 16;
            _face.y = 15;
            face.x  = 1;
            _face.addChildAt(face, 0);
            ct.addChild(_face);
        }

        // -----------------------------------------------------------------------------

        _nameText.text = fv.name;

        _lvText.text = 'Lv.' + _currentFighter.getLevel();

        var exp:int    = _currentFighter.getExp();
        var expMax:int = LevelModel.getLevelUpExp(_currentFighter.getLevel());

        var expmc:Sprite = _ui.getChildByName('expmc') as Sprite;
        if (expmc) {
            var expBar:DisplayObject = expmc.getChildByName('bar');
            if (expBar) {
                expBar.scaleX = exp / expMax;
            }
        }

        _expText.text = 'Exp.' + exp + '/' + expMax;

        _introText.text = 'HP ' + _currentFighter.getHP() + '\n' +
                          'MP ' + _currentFighter.getQI() + '\n' +
                          'EN ' + _currentFighter.getEnergy();

        _introText2.text = 'ATK ' + (
                _currentFighter.getAttackDmg() * 10
        );

//			_introText2.text = "ATK " + (_currentFighter.getAttackDmg() * 10) + "\n" +
//				"DEF " + (_currentFighter.getDefense() * 10);
    }

    private function initBigFaces():void {
        var fighters:Vector.<MusouFighterVO> = GameData.I.mosouData.getFighterTeam();
        for (var i:int; i < fighters.length; i++) {
            if (_bigFaces[i]) {
                _bigFaces[i].setFighter(fighters[i]);
                BtnUtils.btnMode(_bigFaces[i].getUI());
                BtnUtils.initBtn(_bigFaces[i].getUI(), bigFaceHandler, _bigFaces[i]);
                _bigFaces[i].updatePos(i, false);
                _bigFaces[i].updateLeader();
            }
        }
    }

    private function updateBigFaces():void {
        var fighters:Vector.<MusouFighterVO> = GameData.I.mosouData.getFighterTeam();
        for (var i:int; i < fighters.length; i++) {
            if (_bigFaces[i]) {
                _bigFaces[i].setFighter(fighters[i]);
                _bigFaces[i].updateLeader();
            }
        }

        focusFighter(_changeIndex, false);
    }

    private function bigFaceHandler(ui:BigFaceUI):void {
        var index:int = _bigFaces.indexOf(ui);
        if (index == 0 || index == -1) {
            return;
        }

        focusFighter(index);
    }

    private function focusFighter(index:int, tween:Boolean = true):void {
        var tmpArr:Vector.<BigFaceUI> = _bigFaces.concat();

        if (index == 2) {
            _bigFaces[2] = tmpArr[1];
            _bigFaces[1] = tmpArr[0];
            _bigFaces[0] = tmpArr[2];
        }

        if (index == 1) {
            _bigFaces[1] = tmpArr[2];
            _bigFaces[2] = tmpArr[0];
            _bigFaces[0] = tmpArr[1];
        }

        _bigFaces[0].updatePos(0, tween);
        _bigFaces[1].updatePos(1, tween);
        _bigFaces[2].updatePos(2, tween);

        updateCurrentFighter();
    }


}
}
