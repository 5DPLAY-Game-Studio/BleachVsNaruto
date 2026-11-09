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

package net.play5d.game.bvn.events {
import flash.events.Event;
import flash.events.EventDispatcher;

/**
 * 全局游戏事件，以及一条静态总线。
 *
 * <p>监听、移除和派发都走内部的 <code>EventDispatcher</code>，不走某个实例，也不在显示列表上，所以 <code>bubbles</code> 不会冒到舞台。
 * 没有覆写 <code>clone</code>。显示列表重派时 <code>param</code> 会变成 <code>null</code>。静态 <code>dispatchEvent</code> 会新建事件，参数还在。
 * 默认不用弱引用，总线会一直留着监听函数，直到配对移除。派发不返回监听方是否取消。</p>
 *
 * @see flash.events.Event
 * @see #dispatchEvent()
 */
public class GameEvent extends Event {

    /**
     * 分数已写入。参数为空。
     *
     * @eventType SCORE_UPDATE
     */
    public static const SCORE_UPDATE:String = 'SCORE_UPDATE';

    /**
     * 对局暂停。参数为空。
     *
     * @eventType PAUSE_GAME
     */
    public static const PAUSE_GAME:String      = 'PAUSE_GAME';
    /**
     * 暂停菜单里的操作。参数是 <code>movelist</code> 或 <code>movelist-back</code>。
     *
     * @eventType PAUSE_GAME_MENU
     */
    public static const PAUSE_GAME_MENU:String = 'PAUSE_GAME_MENU';
    /**
     * 对局继续。参数为空。
     *
     * @eventType RESUME_GAME
     */
    public static const RESUME_GAME:String     = 'RESUME_GAME';

    /**
     * 初始化加载的一步进度。参数是 <code>msg</code>、<code>progress</code>、<code>step</code>、<code>totalStep</code>。
     *
     * @eventType LOADING_GAME
     */
    public static const LOADING_GAME:String       = 'LOADING_GAME';
    /**
     * 开始初始化加载。此时加载还没结束，参数为空。
     *
     * @eventType LOAD_GAME_START
     */
    public static const LOAD_GAME_START:String    = 'LOAD_GAME_START';
    /**
     * 初始化数据、配置、输入和特效都就绪。参数为空。
     *
     * @eventType LOAD_GAME_COMPLETE
     */
    public static const LOAD_GAME_COMPLETE:String = 'LOAD_GAME_COMPLETE';

    /**
     * 对战开局。参数为空。
     *
     * @eventType GAME_START
     */
    public static const GAME_START:String  = 'GAME_START';
    /**
     * 回合开始。参数为空。
     *
     * @eventType ROUND_START
     */
    public static const ROUND_START:String = 'ROUND_START';
    /**
     * 回合结束。参数为空。
     *
     * @eventType ROUND_END
     */
    public static const ROUND_END:String   = 'ROUND_END';
    /**
     * 这场对战结束。参数为空。
     *
     * @eventType GAME_END
     */
    public static const GAME_END:String    = 'GAME_END';

    /**
     * 进入结束界面。参数为空。
     *
     * @eventType GAME_OVER
     */
    public static const GAME_OVER:String          = 'GAME_OVER';
    /**
     * 结束界面选择续关。参数为空。
     *
     * @eventType GAME_OVER_CONTINUE
     */
    public static const GAME_OVER_CONTINUE:String = 'GAME_OVER_CONTINUE';
    /**
     * 全部关卡通关。参数为空。
     *
     * @eventType GAME_PASS_ALL
     */
    public static const GAME_PASS_ALL:String      = 'GAME_PASS_ALL';

    /**
     * 进入选人。参数为空。
     *
     * @eventType SELECT_FIGHTER
     */
    public static const SELECT_FIGHTER:String        = 'SELECT_FIGHTER';
    /**
     * 进入选图。参数为空。
     *
     * @eventType SELECT_MAP
     */
    public static const SELECT_MAP:String            = 'SELECT_MAP';
    /**
     * 选人走了一步。参数是当前 id 数组：角色步是三个角色位，援助步是援助 id。
     *
     * @eventType SELECT_FIGHTER_STEP
     */
    public static const SELECT_FIGHTER_STEP:String   = 'SELECT_FIGHTER_STEP';
    /**
     * 选人完成。参数为空。
     *
     * @eventType SELECT_FIGHTER_FINISH
     */
    public static const SELECT_FIGHTER_FINISH:String = 'SELECT_FIGHTER_FINISH';
    /**
     * 选人顺序确定。参数是角色 id 数组。
     *
     * @eventType SELECT_FIGHTER_INDEX
     */
    public static const SELECT_FIGHTER_INDEX:String  = 'SELECT_FIGHTER_INDEX';

    /**
     * 无双金钱已改。参数为空。
     *
     * @eventType MONEY_UPDATE
     */
    public static const MONEY_UPDATE:String = 'MONEY_UPDATE';

    /**
     * 无双角色升级。参数是该角色数据。到达等级上限时不会发出。
     *
     * @eventType LEVEL_UP
     */
    public static const LEVEL_UP:String = 'LEVEL_UP';

    /**
     * 菜单进入无双。参数为空。
     *
     * @eventType ENTER_MUSOU_STAGE
     */
    public static const ENTER_MUSOU_STAGE:String  = 'ENTER_MUSOU_STAGE';
    /**
     * 菜单进入组队。参数为空。
     *
     * @eventType ENTER_TEAM_STAGE
     */
    public static const ENTER_TEAM_STAGE:String   = 'ENTER_TEAM_STAGE';
    /**
     * 菜单进入单人。参数为空。
     *
     * @eventType ENTER_SINGLE_STAGE
     */
    public static const ENTER_SINGLE_STAGE:String = 'ENTER_SINGLE_STAGE';
    /**
     * 菜单进入训练。参数为空。
     *
     * @eventType ENTER_TRAIN_STAGE
     */
    public static const ENTER_TRAIN_STAGE:String  = 'ENTER_TRAIN_STAGE';

    /**
     * 切换场景。参数是目标场景的类。
     *
     * @eventType ENTER_STAGE
     */
    public static const ENTER_STAGE:String = 'ENTER_STAGE';

    /**
     * 打开更多游戏。参数为空。
     *
     * @eventType MORE_GAMES
     */
    public static const MORE_GAMES:String = 'MORE_GAMES';

    /**
     * 胜利演出播完。事件名是 <code>SHOW_WINNER</code>，和常量名不一致。参数为空。
     *
     * @eventType SHOW_WINNER
     */
    public static const WINNER_SHOW:String = 'SHOW_WINNER';
    /**
     * 胜利界面销毁。参数为空。
     *
     * @eventType WINNER_END
     */
    public static const WINNER_END:String  = 'WINNER_END';

    /**
     * 打开无双地图。参数为空。
     *
     * @eventType MUSOU_MAP
     */
    public static const MUSOU_MAP:String           = 'MUSOU_MAP';
    /**
     * 从无双回到地图。参数为空。
     *
     * @eventType MUSOU_BACK_MAP
     */
    public static const MUSOU_BACK_MAP:String      = 'MUSOU_BACK_MAP';
    /**
     * 打开无双角色。参数为空。
     *
     * @eventType MUSOU_FIGHTER
     */
    public static const MUSOU_FIGHTER:String       = 'MUSOU_FIGHTER';
    /**
     * 关闭无双角色界面。参数为空。
     *
     * @eventType MUSOU_FIGHTER_CLOSE
     */
    public static const MUSOU_FIGHTER_CLOSE:String = 'MUSOU_FIGHTER_CLOSE';

    /**
     * 无双队伍或队长已改。参数为空。
     *
     * @eventType MUSOU_FIGHTER_UPDATE
     */
    public static const MUSOU_FIGHTER_UPDATE:String = 'MUSOU_FIGHTER_UPDATE';

    /**
     * 无双加载开始。参数为空。
     *
     * @eventType MUSOU_LOADING_START
     */
    public static const MUSOU_LOADING_START:String  = 'MUSOU_LOADING_START';
    /**
     * 无双加载进度。参数是 <code>msg</code> 和 <code>progress</code>。
     *
     * @eventType MUSOU_LOADING
     */
    public static const MUSOU_LOADING:String        = 'MUSOU_LOADING';
    /**
     * 无双加载结束。参数为空。
     *
     * @eventType MUSOU_LOADING_FINISH
     */
    public static const MUSOU_LOADING_FINISH:String = 'MUSOU_LOADING_FINISH';

    /**
     * 无双关卡开始。参数为空。
     *
     * @eventType MUSOU_MISSION_START
     */
    public static const MUSOU_MISSION_START:String  = 'MUSOU_MISSION_START';
    /**
     * 无双关卡结束。参数为空。
     *
     * @eventType MUSOU_MISSION_FINISH
     */
    public static const MUSOU_MISSION_FINISH:String = 'MUSOU_MISSION_FINISH';

    /**
     * 对战加载开始。参数为空。
     *
     * @eventType FIGHT_LOADING_START
     */
    public static const FIGHT_LOADING_START:String  = 'FIGHT_LOADING_START';
    /**
     * 对战资源开始加载。参数为空，进度不在这条事件上。
     *
     * @eventType FIGHT_LOADING
     */
    public static const FIGHT_LOADING:String        = 'FIGHT_LOADING';
    /**
     * 对战加载结束。参数为空。
     *
     * @eventType FIGHT_LOADING_FINISH
     */
    public static const FIGHT_LOADING_FINISH:String = 'FIGHT_LOADING_FINISH';

    /**
     * 对战场景开始。参数为空。
     *
     * @eventType FIGHT_START
     */
    public static const FIGHT_START:String = 'FIGHT_START';

    /**
     * 确认返回菜单。事件名保持 <code>CONFRIM</code> 这个拼写。参数为空。
     *
     * @eventType CONFRIM_BACK_MENU
     */
    public static const CONFRIM_BACK_MENU:String = 'CONFRIM_BACK_MENU';

    /**
     * 确认进入无双下一关。事件名保持 <code>CONFRIM</code> 这个拼写。参数为空。
     *
     * @eventType CONFRIM_MUSOU_NEXT_MISSION
     */
    public static const CONFRIM_MUSOU_NEXT_MISSION:String = 'CONFRIM_MUSOU_NEXT_MISSION';

    /**
     * 打开确认框。事件名保持 <code>CONFRIM</code> 这个拼写。参数为空。
     *
     * @eventType UI_CONFRIM
     */
    public static const UI_CONFRIM:String          = 'UI_CONFRIM';
    /**
     * 确认框关闭。参数为空。
     *
     * @eventType UI_CONFRIM_CLOSE
     */
    public static const UI_CONFRIM_CLOSE:String    = 'UI_CONFRIM_CLOSE';
    /**
     * 打开提示。参数是 <code>enMsg</code> 和 <code>cnMsg</code>。
     *
     * @eventType UI_ALERT
     */
    public static const UI_ALERT:String            = 'UI_ALERT';
    /**
     * 提示关闭。参数为空。
     *
     * @eventType UI_ALERT_CLOSE
     */
    public static const UI_ALERT_CLOSE:String      = 'UI_ALERT_CLOSE';
    /** @private */
    private static var _dispatcher:EventDispatcher = new EventDispatcher();

    /**
     * 在总线上派发一条新的游戏事件。
     *
     * <p><code>type</code> 为空时构造抛错。返回值被丢掉，调用方看不到是否被取消。</p>
     *
     * @param type 事件名。
     * @param param 随事件带走的值。默认 <code>null</code>。
     * @param bubbles 是否冒泡。默认 <code>false</code>。总线不在显示列表上。
     * @param cancelable 是否可取消。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, MenuStage);
     * </listing>
     */
    public static function dispatchEvent(type:String, param:* = null, bubbles:Boolean = false,
                                         cancelable:Boolean = false):void {
        _dispatcher.dispatchEvent(new GameEvent(type, param, bubbles, cancelable));
    }

    /**
     * 在总线上监听。
     *
     * <p>默认强引用。同一函数对同一事件名再加一次不会多出一份。监听函数收到的是 <code>GameEvent</code>。</p>
     *
     * @param type 事件名。
     * @param listener 监听函数。为空时抛错。
     * @param useCapture 是否捕获。默认 <code>false</code>。移除时必须用同一个值。
     * @param priority 优先级。默认 0。数大的先调用。
     * @param useWeakReference 是否弱引用。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * GameEvent.addEventListener(GameEvent.SCORE_UPDATE, onScore);
     * </listing>
     */
    public static function addEventListener(
            type:String, listener:Function, useCapture:Boolean = false, priority:int = 0,
            useWeakReference:Boolean = false
    ):void {
        _dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    /**
     * 从总线上移除监听。没加过时什么都不做。
     *
     * @param type 事件名。
     * @param listener 当初加上的函数。
     * @param useCapture 必须和添加时一致。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * GameEvent.removeEventListener(GameEvent.SCORE_UPDATE, onScore);
     * </listing>
     */
    public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
        _dispatcher.removeEventListener(type, listener, useCapture);
    }

    /**
     * 构造一条游戏事件。静态派发会走这里。
     *
     * @param type 事件名。为空时父类构造抛错。
     * @param param 随事件带走的值。默认 <code>null</code>。
     * @param bubbles 是否冒泡。默认 <code>false</code>。
     * @param cancelable 是否可取消。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * var e:GameEvent = new GameEvent(GameEvent.LEVEL_UP, vo);
     * </listing>
     */
    public function GameEvent(type:String, param:* = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.param = param;
    }
    /**
     * 静态派发带上的参数。没传时为 <code>null</code>。
     *
     * @default null
     */
    public var param:*;

}
}
