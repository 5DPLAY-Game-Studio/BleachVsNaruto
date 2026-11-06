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

package net.play5d.game.bvn.win {
import flash.desktop.NativeApplication;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.display.StageQuality;
import flash.events.MouseEvent;
import flash.utils.ByteArray;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameInputType;
import net.play5d.game.bvn.data.GameQuality;
import net.play5d.game.bvn.data.vos.ConfigVO;
import net.play5d.game.bvn.interfaces.IGameInput;
import net.play5d.game.bvn.interfaces.IExtendConfig;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.interfaces.IGameInterface;
import net.play5d.game.bvn.map.MapLayerCacheUtil;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.utils.CreditsSpriteUtil;
import net.play5d.game.bvn.utils.GameLogger;
import net.play5d.game.bvn.utils.UiBitmap;
import net.play5d.game.bvn.utils.PayUtils;
import net.play5d.game.bvn.utils.URL;
import net.play5d.game.bvn.win.ctrls.LANClientCtrl;
import net.play5d.game.bvn.win.ctrls.LANGameCtrl;
import net.play5d.game.bvn.win.ctrls.LANServerCtrl;
import net.play5d.game.bvn.win.data.ExtendConfig;
import net.play5d.game.bvn.win.input.InputManager;
import net.play5d.kyo.air.utils.FileUtils;
import net.play5d.game.bvn.win.views.ViewManager;

public class GameInterfaceManager implements IGameInterface {

    private static var _extendsConfig:ExtendConfig = new ExtendConfig();

    public static function get config():ExtendConfig {
        return _extendsConfig;
    }


    public function initTitleUI(ui:DisplayObject):void {
        var logomc:Sprite = (
                            ui as Sprite
                            ).getChildByName('logo_mc') as Sprite;
        if (!logomc) {
            return;
        }
        logomc.visible    = true;
        var logo5d:Sprite = logomc.getChildByName('logo_site') as Sprite;
        if (logo5d) {
            logo5d.buttonMode = true;
            logo5d.addEventListener(MouseEvent.MOUSE_UP, URL.website, false, 0, true);
        }
        var logobbs:Sprite = logomc.getChildByName('logo_android') as Sprite;
        if (logobbs) {
            logobbs.buttonMode = true;
            logobbs.addEventListener(MouseEvent.MOUSE_UP, URL.bbs, false, 0, true);
        }
    }

    public function moreGames():void {
        URL.website();
    }

    public function submitScore(score:int):void {
    }

    public function showRank():void {
    }

    public function saveGame(data:Object):void {
        var json:String = JSON.stringify(data);
        FileUtils.writeAppFolderFile('bvnsave.sav', json);
        GameLogger.debug('sys', 'saveData ' + json);
    }

    public function loadGame():Object {
        var url:String  = FileUtils.getAppFolderFileUrl('bvnsave.sav');
        var json:String = FileUtils.readTextFile(url);
        if (!json) {
            return null;
        }
        var o:Object = JSON.parse(json);
        return o;
    }

    public function getFighterCtrl(player:int):IFighterActionCtrl {
        return null;
    }

    public function getGameMenu():Array {
        var a:Array = [

            {
                txt: 'TEAM PLAY', cn: GetLang('menu.team_play'), children: [
                    {txt: 'TEAM ARCADE', cn: GetLang('menu.team_arcade')},
                    {txt: 'TEAM VS PEOPLE', cn: GetLang('menu.team_vs_people')},
                    {txt: 'TEAM VS CPU', cn: GetLang('menu.team_vs_cpu')},
                    {txt: 'TEAM WATCH', cn: GetLang('menu.team_watch')}
                ]
            },

            {
                txt: 'SINGLE PLAY', cn: GetLang('menu.single_play'), children: [
                    {txt: 'SINGLE ARCADE', cn: GetLang('menu.single_arcade')},
                    {txt: 'SINGLE VS PEOPLE', cn: GetLang('menu.single_vs_people')},
                    {txt: 'SINGLE VS CPU', cn: GetLang('menu.single_vs_cpu')},
                    {txt: 'SINGLE WATCH', cn: GetLang('menu.single_watch')}
                ]
            },

            {
                txt: 'MUSOU PLAY', cn: GetLang('menu.musou_play'), children: [
                    {txt: 'MUSOU ARCADE', cn: GetLang('menu.musou_arcade')}
                ]
            },

            {
                txt: 'LAN PLAY', cn: GetLang('menu.lan_play'), func: function ():void {
                    LANGameCtrl.I.goLANGameState();
                }
            },

            /*{txt:'SURVIVOR',cn:'挑战模式'},*/ //暂未开放
            {txt: 'OPTION', cn: GetLang('menu.option')},
            {txt: 'TRAINING', cn: GetLang('menu.training')},
            {txt: 'CREDITS', cn: GetLang('menu.credits')},
            {txt: 'MORE GAMES', cn: GetLang('menu.more_games')},
            {
                txt: 'EXIT', cn: GetLang('menu.exit'), func: function ():void {
                    GameUI.confirm(
                            GetLang('menu.exit_game.title'),
                            GetLang('menu.exit_game'),
                            NativeApplication.nativeApplication.exit
                    );
                }
            }
        ];
        return a;
    }

    public function getSettingMenu():Array {
        return [
            {txt: 'P1 KEY SET', cn: GetLang('settings.p1_keys')},
            {txt: 'P2 KEY SET', cn: GetLang('settings.p2_keys')},
            {
                txt   : 'P1 JOYSTICK SET', cn: GetLang('settings.p1_joystick'),
                select: ViewManager.I.goP1JoyStickSet
            },
            {
                txt   : 'P2 JOYSTICK SET', cn: GetLang('settings.p2_joystick'),
                select: ViewManager.I.goP2JoyStickSet
            },
            {
                txt      : 'COM LEVEL', cn: GetLang('settings.difficulty'),
                options  : [
                    {label: 'VERY EASY', cn: GetLang('settings.difficulty.very_easy'), value: 1},
                    {label: 'EASY', cn: GetLang('settings.difficulty.easy'), value: 2},
                    {label: 'NORMAL', cn: GetLang('settings.difficulty.normal'), value: 3},
                    {label: 'HARD', cn: GetLang('settings.difficulty.hard'), value: 4},
                    {label: 'VERY HARD', cn: GetLang('settings.difficulty.very_hard'), value: 5},
                    {label: 'HELL', cn: GetLang('settings.difficulty.hell'), value: 6}
                ],
                optionKey: 'AI_level'
            },
            {
                txt      : 'OPERATE MODE', cn: GetLang('settings.operate_mode'),
                options  : [
                    {label: 'NORMAL', cn: GetLang('settings.operate_normal'), value: 0},
                    {label: 'CLASSIC', cn: GetLang('settings.operate_classic'), value: 1}
                ],
                optionKey: 'keyInputMode'
            },
            {
                txt      : 'LIFE', cn: GetLang('settings.life'),
                options  : [
                    {label: '50%', cn: '50%', value: 0.5},
                    {label: '100%', cn: '100%', value: 1},
                    {label: '200%', cn: '200%', value: 2},
                    {label: '300%', cn: '300%', value: 3},
                    {label: '500%', cn: '500%', value: 5}
                ],
                optionKey: 'fighterHP'
            },
            {
                txt      : 'TIME', cn: GetLang('settings.time'),
                options  : [
                    {label: '30s', cn: GetLang('settings.time.30'), value: 30},
                    {label: '60s', cn: GetLang('settings.time.60'), value: 60},
                    {label: '90s', cn: GetLang('settings.time.90'), value: 90},
                    {label: '∞', cn: GetLang('settings.time.unlimited'), value: -1}
                ],
                optionKey: 'fightTime'
            },
            {
                txt      : 'SOUND', cn: GetLang('settings.sound'),
                options  : [
                    {label: '0%', cn: '0%', value: 0},
                    {label: '10%', cn: '10%', value: 0.1},
                    {label: '30%', cn: '30%', value: 0.3},
                    {label: '50%', cn: '50%', value: 0.5},
                    {label: '70%', cn: '70%', value: 0.7},
                    {label: '100%', cn: '100%', value: 1},
                ],
                optionKey: 'soundVolume'
            },
            {
                txt      : 'BGM', cn: GetLang('settings.bgm'),
                options  : [
                    {label: '0%', cn: '0%', value: 0},
                    {label: '10%', cn: '10%', value: 0.1},
                    {label: '30%', cn: '30%', value: 0.3},
                    {label: '50%', cn: '50%', value: 0.5},
                    {label: '70%', cn: '70%', value: 0.7},
                    {label: '100%', cn: '100%', value: 1},
                ],
                optionKey: 'bgmVolume'
            },
            {
                txt      : 'QUALITY', cn: GetLang('settings.quality'),
                options  : [
                    {label: 'LOW', cn: GetLang('settings.quality.low'), value: GameQuality.LOW},
                    {label: 'MEDIUM', cn: GetLang('settings.quality.medium'), value: GameQuality.MEDIUM},
                    {label: 'HIGH', cn: GetLang('settings.quality.high'), value: GameQuality.HIGH},
                    {label: 'BEST', cn: GetLang('settings.quality.best'), value: GameQuality.BEST}
                ],
                optionKey: 'quality'
            },
            {
                txt      : 'SHOW HP', cn: GetLang('settings.show_hp'),
                options  : [
                    {label: 'SHOW', cn: GetLang('settings.hp_show'), value: true},
                    {label: 'HIDE', cn: GetLang('settings.hp_hide'), value: false},
                ],
                optionKey: 'isShowHp'
            },
            {
                txt      : 'DISPLAY MODE', cn: GetLang('settings.display_mode'),
                options  : [
                    {
                        label: 'FULLSCREEN',
                        cn   : GetLang('settings.display_fullscreen'),
                        value: true
                    },
                    {
                        label: 'WINDOW',
                        cn   : GetLang('settings.display_window'),
                        value: false
                    }
                ],
                optionKey: 'isFullScreen'
            },
        ];
    }

    public function getGameInput(type:String):Vector.<IGameInput> {

        var vec:Vector.<IGameInput> = new Vector.<IGameInput>();

        switch (type) {
        case GameInputType.MENU:
            vec.push(InputManager.I.key_menu);
            vec.push(InputManager.I.joy_menu);
            break;
        case GameInputType.P1:
            vec.push(InputManager.I.key_p1);
            vec.push(InputManager.I.joy_p1);
            vec.push(InputManager.I.socket_input_p1);
            break;
        case GameInputType.P2:
            vec.push(InputManager.I.key_p2);
            vec.push(InputManager.I.joy_p2);
            vec.push(InputManager.I.socket_input_p2);
            break;
        default:
            return null;
        }
        return vec;
    }

    public function getConfigExtend():IExtendConfig {
        return _extendsConfig;
    }

    public function afterBuildGame():void {
        MapLayerCacheUtil.enableBitmapCache(GameCtrl.I.gameState.getMap());
    }

    /**
     * 更新输入设置
     */
    public function updateInputConfig():Boolean {
        var onJoyChanged:Function = function ():void {
            _extendsConfig.updateJoyConfig();
        };
        InputManager.I.joy_menu.onDevicesChanged = onJoyChanged;
        InputManager.I.joy_p1.onDevicesChanged   = onJoyChanged;
        InputManager.I.joy_p2.onDevicesChanged   = onJoyChanged;

        if (LANServerCtrl.I.active || LANClientCtrl.I.active) {

            /**
             * 使用锁帧同步算法进行游戏操作同步
             * 客户端采集操作数据，定时发给服务器，服务器定时更新服务端和客户端
             * 服务端在同样的时间线采集操作数据，定时更新并发送到客户端
             */

            InputManager.I.key_menu.enabled = false;
            InputManager.I.key_p1.enabled   = false;
            InputManager.I.key_p2.enabled   = false;

            InputManager.I.joy_menu.enabled = false;
            InputManager.I.joy_p1.enabled   = false;
            InputManager.I.joy_p2.enabled   = false;

            InputManager.I.socket_input_p1.enabled = true;
            InputManager.I.socket_input_p2.enabled = true;

            if (LANServerCtrl.I.active) {
                InputManager.I.socket_input_p1.setInputters([InputManager.I.key_p1, InputManager.I.joy_p1]);
            }

            if (LANClientCtrl.I.active) {
                InputManager.I.key_p2.setConfig(GameData.I.config.key_p1);
                InputManager.I.joy_p2.setConfig(_extendsConfig.joy1Config);
                InputManager.I.socket_input_p2.setInputters([InputManager.I.key_p2, InputManager.I.joy_p2]);
            }

            return true;
        }

        InputManager.I.key_menu.setConfig(GameData.I.config.key_menu);
        InputManager.I.key_p1.setConfig(GameData.I.config.key_p1);
        InputManager.I.key_p2.setConfig(GameData.I.config.key_p2);

        InputManager.I.joy_menu.setConfig(_extendsConfig.joyMenuConfig);
        InputManager.I.joy_p1.setConfig(_extendsConfig.joy1Config);
        InputManager.I.joy_p2.setConfig(_extendsConfig.joy2Config);

        InputManager.I.socket_input_p1.enabled = false;
        InputManager.I.socket_input_p2.enabled = false;

        return true;
    }

    public function applyConfig(config:Object):void {
        var cfg:ConfigVO = config as ConfigVO;
        if (!cfg) {
            return;
        }

        switch (cfg.quality) {
        case GameQuality.BEST:
            MainGame.I.stage.quality = StageQuality.HIGH_16X16;
            MainGame.I.setFPS(60);
            GameConfig.FPS_SHINE_EFFECT = 60;
            break;
        case GameQuality.HIGHER:
            MainGame.I.stage.quality = StageQuality.HIGH_8X8;
            MainGame.I.setFPS(60);
            GameConfig.FPS_SHINE_EFFECT = 30;
            break;
        case GameQuality.HIGH:
            MainGame.I.stage.quality = StageQuality.HIGH;
            MainGame.I.setFPS(60);
            GameConfig.FPS_SHINE_EFFECT = 30;
            break;
        case GameQuality.MEDIUM:
            MainGame.I.stage.quality = StageQuality.MEDIUM;
            MainGame.I.setFPS(60);
            GameConfig.FPS_SHINE_EFFECT = 15;
            break;
        case GameQuality.LOW:
            MainGame.I.stage.quality = StageQuality.LOW;
            MainGame.I.setFPS(30);
            GameConfig.FPS_SHINE_EFFECT = 10;
            break;
        }

        if (_extendsConfig.isFullScreen) {
            MainGame.I.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
        }
        else {
            MainGame.I.stage.displayState = StageDisplayState.NORMAL;
        }

    }

    public function getCredits(creditsInfo:String):Sprite {
        var sp:Sprite = CreditsSpriteUtil.build(creditsInfo, 'credits.footer');
        var android:Sprite;
        var alipay:Sprite;
        var weixin:Sprite;

        loadPay(sp, 'android.png', 300, 1, function (icon:Sprite):void {
            android = icon;
            icon.addEventListener(MouseEvent.MOUSE_OVER, payOverHandler);
        });
        loadPay(sp, 'alipay.png', 470, 0.2, function (icon:Sprite):void {
            alipay = icon;
            icon.addEventListener(MouseEvent.MOUSE_OVER, payOverHandler);
        });
        loadPay(sp, 'weixin.png', 640, 0.2, function (icon:Sprite):void {
            weixin = icon;
            icon.addEventListener(MouseEvent.MOUSE_OVER, payOverHandler);
        });

        function payOverHandler(e:MouseEvent):void {
            if (e.currentTarget == alipay) {
                setPayAlpha(alipay, 1);
                setPayAlpha(weixin, 0.2);
                setPayAlpha(android, 0.2);
            }
            if (e.currentTarget == weixin) {
                setPayAlpha(alipay, 0.2);
                setPayAlpha(weixin, 1);
                setPayAlpha(android, 0.2);
            }
            if (e.currentTarget == android) {
                setPayAlpha(alipay, 0.2);
                setPayAlpha(weixin, 0.2);
                setPayAlpha(android, 1);
            }
        }

        return sp;
    }

    /** @private */
    private function loadPay(sp:Sprite, file:String, x:Number, alpha:Number, ready:Function):void {
        UiBitmap.load(file, function (bmp:Bitmap):void {
            bmp.smoothing = true;
            var icon:Sprite = PayUtils.getPaySp(bmp);
            icon.x          = x;
            icon.y          = 400;
            icon.width      = 150;
            icon.height     = 194;
            icon.alpha      = alpha;
            sp.addChild(icon);
            ready(icon);
        });
    }

    /** @private */
    private function setPayAlpha(icon:Sprite, alpha:Number):void {
        if (icon) {
            icon.alpha = alpha;
        }
    }

    public function checkFile(url:String, file:ByteArray):Boolean {
        return true;
    }

    public function addMusouMoney(back:Function):void {
        back(100 + Math.random() * 200);
    }

}
}
