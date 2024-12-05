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
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.cntlr.GameRender;
import net.play5d.game.bvn.cntlr.SoundCtrl;
import net.play5d.game.bvn.input.GameInputType;
import net.play5d.game.bvn.input.GameInputer;
import net.play5d.game.bvn.win.ctrls.LANClientCtrl;
import net.play5d.game.bvn.win.data.HostVO;
import net.play5d.game.bvn.win.utils.UIAssetUtil;
import net.play5d.kyo.stage.IStage;
import net.play5d.kyo.utils.KyoBtnUtils;

//import net.play5d.game.bvn.win.ctrls.LANUDPCtrler;
public class HostListDialog implements IStage {

    public function HostListDialog() {
        GameRender.add(render, this);
    }
    public var onClose:Function;
    private var ui:Sprite;
    private var _txtPage:TextField;
    private var _txtTotalpage:TextField;
    private var _btns:Array;
    private var _items:Array = [];
    private var _focusIndex:int;
    private var _hosts:Vector.<HostVO>;
    private var _page:int      = 1;
    private var _totalPage:int = 1;
    private var _perpage:int   = 10;

    /**
     * 显示对象
     */
    public function get display():DisplayObject {
        return ui;
    }

    public function findHosts():void {
        removeItems();
        _hosts     = new Vector.<HostVO>();
        _page      = 1;
        _totalPage = 1;
        LANClientCtrl.I.findHost(findHostHandler);
    }

    /**
     * 构建
     */
    public function build():void {
        ui = UIAssetUtil.I.createDisplayObject('game_list_ui');

        _txtPage      = ui.getChildByName('txt_page') as TextField;
        _txtTotalpage = ui.getChildByName('txt_totalpage') as TextField;

        initBtns(['btn_back', 'btn_refresh', 'btn_prev', 'btn_next']);

        LANClientCtrl.I.initlize();

        findHosts();
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
        GameRender.remove(render, this);
        LANClientCtrl.I.cancelFindHost();
        if (_btns) {
            for each(var i:SimpleButton in _btns) {
                i.removeEventListener(MouseEvent.CLICK, btnHandler);
                KyoBtnUtils.disposeBtn(i);
            }
            _btns = null;
        }
        removeItems();
    }

    private function findHostHandler(data:HostVO):void {
        for each(var i:HostVO in _hosts) {
            if (i.ip == data.ip) {
                return;
            }
        }
        addHost(data);
    }

    private function addHost(h:HostVO):void {
        _hosts.push(h);

        _totalPage = (
                             _hosts.length / _perpage
                     ) + 1;

        if (_items.length < _perpage) {
            createItem(h);
        }

        updatePage();
    }

    private function updatePage():void {
        _txtPage.text      = _page.toString();
        _txtTotalpage.text = _totalPage.toString() + '页';
    }

    private function render():void {
        if (GameInputer.up(GameInputType.MENU, 1)) {
            var prev:HostListItem = _items[_focusIndex - 1];
            if (prev) {
                SoundCtrl.I.sndSelect();
                focusItem(prev);
            }
            else {
                if (prevPage()) {
                    focusItem(_items[_items.length - 1]);
                    SoundCtrl.I.sndSelect();
                }
            }
        }
        if (GameInputer.down(GameInputType.MENU, 1)) {
            var next:HostListItem = _items[_focusIndex + 1];
            if (next) {
                SoundCtrl.I.sndSelect();
                focusItem(next);
            }
            else {
                if (nextPage()) {
                    SoundCtrl.I.sndSelect();
                }
            }
        }
        if (GameInputer.left(GameInputType.MENU, 1)) {
            if (prevPage()) {
                SoundCtrl.I.sndSelect();
            }
        }
        if (GameInputer.right(GameInputType.MENU, 1)) {
            if (nextPage()) {
                SoundCtrl.I.sndSelect();
            }
        }
    }

    private function removeItems():void {
        for each(var i:HostListItem in _items) {
            i.removeMouseListener();
            try {
                ui.removeChild(i.ui);
            }
            catch (e:Error) {
            }
        }
        _items = [];
    }

    private function createItem(data:HostVO):HostListItem {
        var item:HostListItem = new HostListItem();
        item.setMouseListener(itemMouseHandler);
        item.setData(data);
        item.ui.x = 25;
        item.ui.y = 96 + _items.length * 40;
        _items.push(item);
        ui.addChild(item.ui);
        return item;
    }

    private function updateList():void {

        removeItems();

        var start:int = (
                                _page - 1
                        ) * _perpage;
        var end:int   = start + _perpage;
        if (end > _hosts.length) {
            end = _hosts.length;
        }

        for (var i:int = start; i < end; i++) {
            createItem(_hosts[i]);
        }

        focusItem(_items[0]);

    }

    private function itemMouseHandler(type:String, item:HostListItem):void {
        if (type == MouseEvent.MOUSE_OVER) {
            SoundCtrl.I.sndSelect();
            focusItem(item);
        }

        if (type == MouseEvent.CLICK) {
            SoundCtrl.I.sndConfrim();
            showHostDetail(item.data);
        }
    }

    private function showHostDetail(hv:HostVO):void {
        var detailDialog:HostDetailDialog = new HostDetailDialog();
        MainGame.stageCtrl.addLayer(detailDialog, 0, 0);
        detailDialog.setData(hv);
    }

    private function focusItem(item:HostListItem):void {
        for (var i:int; i < _items.length; i++) {
            var it:HostListItem = _items[i];
            if (it == item) {
                it.focus(true);
                _focusIndex = i;
            }
            else {
                it.focus(false);
            }
        }
    }

    private function initBtns(btns:Array):void {
        _btns = [];
        for each(var i:String in btns) {
            var btn:SimpleButton = ui.getChildByName(i) as SimpleButton;
            if (btn) {
                btn.addEventListener(MouseEvent.CLICK, btnHandler);
                KyoBtnUtils.initBtn(btn, btnHandler, btn.name);
                _btns.push(btn);
            }
        }
    }

    private function btnHandler(name:String):void {
        switch (name) {
        case 'btn_back':
            close();
            break;
        case 'btn_refresh':
            findHosts();
            break;
        case 'btn_prev':
            prevPage();
            break;
        case 'btn_next':
            nextPage();
            break;
        }
    }

    private function prevPage():Boolean {
        if (_page <= 1) {
            return false;
        }
        _page--;
        _txtPage.text = _page.toString();
        updateList();
        updatePage();
        return true;
    }

    private function nextPage():Boolean {
        if (_page >= _totalPage) {
            return false;
        }
        _page++;
        _txtPage.text = _page.toString();
        updateList();
        updatePage();
        return true;
    }

}
}
