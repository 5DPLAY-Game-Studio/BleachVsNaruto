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

package net.play5d.game.bvn.stage {
import com.greensock.TweenLite;

import flash.display.DisplayObject;
import flash.utils.setTimeout;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.ctrler.GameRender;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.ctrler.StateCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.ctrler.game_stage_loader.GameStageLoadCtrl;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.vos.SelectVO;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.input.GameInputter;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.ui.select.SelectIndexUI;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.stage.IStage;

/**
 * 对战资源加载和出场顺序。
 *
 * <p>自动开打默认开着。顺序界面还没建时，读完成状态或顺序会抛错。<code>setOrder</code> 只认 1 和 2，其它玩家编号什么都不做。
 * 加载会把双方三个角色位原样放进列表，空位也在里面。资源和顺序都完成且还没开打过，才会进入对战。自动开打关掉时 <code>finish</code> 直接返回。
 * 返回键弹出回主菜单确认。</p>
 *
 * @see net.play5d.kyo.stage.IStage
 */
public class LoadingStage implements IStage {

    /**
     * 资源和顺序都完成后是否自动进入对战。
     *
     * @default true
     */
    public static var AUTO_START_GAME:Boolean = true;

    private var _ui:$loading$MC_loadingFight;
    private var _sltUI:$loading$MC_selectUI;
    private var _destroyed:Boolean;
    private var _loadFin:Boolean;
    private var _selectIndexUI:SelectIndexUI;
    private var _gameFinished:Boolean;

    /**
     * 显示对象
     */
    public function get display():DisplayObject {
        return _ui;
    }

    /**
     * 1P 出场顺序是否排完。顺序界面还没建时抛错。
     *
     * @return 排完时为 true。
     * @throws TypeError 顺序界面为 null 时。
     * @example
     * <listing version="3.0">
     * var done:Boolean = stage.p1SelectFinish();
     * </listing>
     */
    public function p1SelectFinish():Boolean {
        return _selectIndexUI.p1Finish();
    }

    /**
     * 2P 出场顺序是否排完。顺序界面还没建时抛错。
     *
     * @return 排完时为 true。
     * @throws TypeError 顺序界面为 null 时。
     * @example
     * <listing version="3.0">
     * var done:Boolean = stage.p2SelectFinish();
     * </listing>
     */
    public function p2SelectFinish():Boolean {
        return _selectIndexUI.p2Finish();
    }

    /**
     * 双方出场顺序是否都排完。顺序界面还没建时抛错。
     *
     * @return 都排完时为 true。
     * @throws TypeError 顺序界面为 null 时。
     * @example
     * <listing version="3.0">
     * var done:Boolean = stage.selectFinish();
     * </listing>
     */
    public function selectFinish():Boolean {
        return _selectIndexUI.isFinish();
    }

    /**
     * 双方当前出场顺序。返回新数组，里面仍是界面上的那两份顺序。
     *
     * @return 下标 0 是 1P，下标 1 是 2P。
     * @throws TypeError 顺序界面为 null 时。
     * @example
     * <listing version="3.0">
     * var orders:Array = stage.getSort();
     * </listing>
     */
    public function getSort():Array {
        return [_selectIndexUI.getP1Order(), _selectIndexUI.getP2Order()];
    }

    /**
     * 写入某一方的出场顺序。玩家编号不是 1 或 2 时什么都不做。
     *
     * @param player 1 或 2。
     * @param v 顺序。
     * @throws TypeError 顺序界面为 null 时。
     * @example
     * <listing version="3.0">
     * stage.setOrder(1, ids);
     * </listing>
     */
    public function setOrder(player:int, v:Array):void {
        if (player == 1) {
            _selectIndexUI.setP1Order(v);
        }
        if (player == 2) {
            _selectIndexUI.setP2Order(v);
        }
    }

    /**
     * 构建
     */
    public function build():void {
        GameEvent.dispatchEvent(GameEvent.FIGHT_LOADING_START);

        GameRender.add(render);
        GameInputter.focus();
        GameInputter.enabled = true;

        SoundCtrl.I.BGM(AssetManager.I.getSound('loading'));

        _ui    = ResUtils.I.createDisplayObject(ResUtils.swfLib.fight, '$loading$MC_loadingFight');
        _sltUI = _ui.sltui;

        _selectIndexUI          = new SelectIndexUI();
        _selectIndexUI.onFinish = finish;
        _sltUI.addChild(_selectIndexUI);

    }

    /**
     * 按这两份顺序准备对战，派发加载结束，再转入游戏。
     *
     * @param sort1 1P 顺序。
     * @param sort2 2P 顺序。
     * @example
     * <listing version="3.0">
     * stage.gotoGame(sort1, sort2);
     * </listing>
     */
    public function gotoGame(sort1:Array, sort2:Array):void {
        GameCtrl.I.prepareFight(sort1, sort2);

        GameEvent.dispatchEvent(GameEvent.FIGHT_LOADING_FINISH);

        StateCtrl.I.transIn(MainGame.I.goGame, false);

    }

    /**
     * 稍后构建
     */
    public function afterBuild():void {
        StateCtrl.I.transOut(startLoad);
    }

    /**
     * 销毁
     * @param back 回调函数
     */
    public function destroy(back:Function = null):void {
        _destroyed = true;

        if (_selectIndexUI) {
            _selectIndexUI.destroy();
            _selectIndexUI = null;
        }

        SoundCtrl.I.BGM(null);

        GameInputter.clearInput();
        GameRender.remove(render);

        GameUI.closeConfirm();
    }

    private function render():void {
        if (GameInputter.back(1)) {
            if (GameUI.showingDialog()) {
                GameUI.cancelConfirm();
            }
            else {
                GameUI.confirmBackMenu(IsMobile());
            }
        }
    }

    private function onLoadProgress(msg:String, progress:Number):void {
        _sltUI.bar.txt.text   = msg;
        _sltUI.bar.bar.scaleX = progress;
    }

    private function onLoadError(msg:String):void {
        Debugger.errorMsg(msg);
    }

    private function onLoadFinish():void {

        TweenLite.to(_sltUI, 1, {
            y: 80, onComplete: function ():void {
                setTimeout(delayCall, 2000);
            }
        });

        function delayCall():void {
            _loadFin = true;
            finish();
        }

    }

    private function finish():void {
        if (_destroyed) {
            return;
        }
        if (!_selectIndexUI.isFinish() || !_loadFin) {
            return;
        }
        if (!AUTO_START_GAME) {
            return;
        }

        if (_gameFinished) {
            return;
        }

        _gameFinished = true;

        var sort1:Array = _selectIndexUI.getP1Order();
        var sort2:Array = _selectIndexUI.getP2Order();

        gotoGame(sort1, sort2);
    }

    private function startLoad():void {
        var maps:Array      = [];
        var fighters:Array  = [];
        var assisters:Array = [];
        var bgms:Array      = [];

        maps.push(GameData.I.selectMap);

        var p1selt:SelectVO = GameData.I.p1Select;
        fighters.push(p1selt.fighter1, p1selt.fighter2, p1selt.fighter3);

        var p2selt:SelectVO = GameData.I.p2Select;
        fighters.push(p2selt.fighter1, p2selt.fighter2, p2selt.fighter3);

        assisters.push(p1selt.fuzhu, p2selt.fuzhu);

        bgms = fighters.concat([GameData.I.selectMap]);

        GameStageLoadCtrl.I.init(onLoadProgress, onLoadError);
        GameStageLoadCtrl.I.loadGame(maps, fighters, assisters, bgms, onLoadFinish);

        GameEvent.dispatchEvent(GameEvent.FIGHT_LOADING);
    }
}
}
