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

package net.play5d.game.bvn.ui.dialog.select {
import com.greensock.TweenLite;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.mosou.MosouFighterModel;
import net.play5d.game.bvn.data.mosou.MosouFighterSellVO;
import net.play5d.game.bvn.utils.BtnUtils;
import net.play5d.game.bvn.utils.TouchMoveEvent;
import net.play5d.game.bvn.utils.TouchUtils;

public class SelectFighterList extends Sprite {
    include '../../../../../../../../include/_INCLUDE_.as';

    public function SelectFighterList() {
        super();

        this.graphics.beginBitmapFill(new BitmapData(1, 1, true, 0));
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();

        _listCt = new Sprite();
        addChild(_listCt);

        _listCt.scrollRect = new Rectangle(0, 0, _width, _height);

        build();

        listenEvents();
    }
    public var onSelectFighter:Function;
    public var onChangePage:Function;
    private var _fighterItems:Vector.<SelectFighterUI>;
    private var _scrollY:Number    = 0;
    private var _width:Number      = 385;
    private var _height:Number     = 405;
    private var _listHeight:Number = 0;
    private var _listCt:Sprite;
    private var _curPage:int;
    private var _totalPage:int;

    public function destory():void {
        this.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseHandler);
//			TouchUtils.I.unlistenOneFinger(MainGame.I.stage);
        TouchUtils.I.unlistenOneFinger(this);
    }

    public function update():void {
        for each(var i:SelectFighterUI in _fighterItems) {
            i.updateUI();
        }
    }

    public function getPage():int {
        return _curPage;
    }

    public function setPage(v:int):void {
        if (v < 1) {
            return;
        }
        if (v > getTotalPage()) {
            return;
        }

        _curPage = v;
        scrollTo((
                         v - 1
                 ) * _width);

        if (onChangePage != null) {
            onChangePage();
        }

//			trace("page", v, (v - 1) * _height);
    }

    public function getTotalPage():int {
//			return Math.ceil(_listHeight / _height);
        return _totalPage;
    }

    private function build():void {
        var fighters:Vector.<MosouFighterSellVO> = MosouFighterModel.I.fighters;

        var currentFighterIds:Array = GameData.I.mosouData.getFighterTeamIds();

        _fighterItems = new Vector.<SelectFighterUI>();

        for (var i:int; i < fighters.length; i++) {
            var sv:MosouFighterSellVO = fighters[i];
            var isInTeam:Boolean      = false;

            if (currentFighterIds.indexOf(sv.id) != -1) {
                continue;
            }

            var ui:SelectFighterUI = new SelectFighterUI(sv);

            BtnUtils.btnMode(ui.ui);
            BtnUtils.initBtn(ui.ui, selectHandler, ui);

            _fighterItems.push(ui);

            _listCt.addChild(ui.ui);
        }

        _fighterItems.sort(function (A:SelectFighterUI, B:SelectFighterUI):int {
            if (!A.isBought() && B.isBought()) {
                return 1;
            }
            if (A.isBought() && !B.isBought()) {
                return -1;
            }
            return 0;
        });

        var X:int = 10;
        var Y:int = 10;

        _totalPage = 1;
        _curPage   = 1;

        for (var j:int; j < _fighterItems.length; j++) {

            _fighterItems[j].ui.x = X + (
                    _width * (
                            _totalPage - 1
                    )
            );
            _fighterItems[j].ui.y = Y;

            X += 80;

            if (X > _width) {
                X = 10;
                Y += 80;
            }

            if (Y > _height - 10) {
                _totalPage++;
                X = 10;
                Y = 10;
            }
        }

        _listHeight = Y;
    }

    private function listenEvents():void {
        if (GameConfig.TOUCH_MODE) {
//				TouchUtils.I.listenOneFinger(MainGame.I.stage, touchHandler, false, true);
            TouchUtils.I.listenOneFinger(this, touchHandler, true, false);
        }
        else {
            this.addEventListener(MouseEvent.MOUSE_WHEEL, mouseHandler);
        }
    }

    private function scroll(v:Number):void {
        scrollTo(_scrollY + v);
    }

    private function scrollTo(v:Number):void {
        var obj:Object = {x: _listCt.scrollRect.x, y: 0};

        TweenLite.to(obj, 0.3, {
            x: v, onUpdate: function ():void {
                _listCt.scrollRect = new Rectangle(obj.x, obj.y, _width, _height);
            }
        });


    }

    private function selectHandler(sui:SelectFighterUI):void {
        for each(var i:SelectFighterUI in _fighterItems) {
            var b:Boolean = i == sui;
            i.select(b);
            if (b && onSelectFighter != null) {
                onSelectFighter(i);
            }
        }
    }

    private function mouseHandler(e:MouseEvent):void {
//			scroll(e.delta * -5);
        if (e.delta < 0) {
            setPage(_curPage + 1);
        }
        else {
            setPage(_curPage - 1);
        }
    }

    private function touchHandler(e:TouchMoveEvent):void {
        if (e.type == TouchMoveEvent.TOUCH_END) {
            if (e.distanceX > 50) {
                setPage(_curPage - 1);
            }
            if (e.distanceX < -50) {
                setPage(_curPage + 1);
            }
        }
    }

}
}
