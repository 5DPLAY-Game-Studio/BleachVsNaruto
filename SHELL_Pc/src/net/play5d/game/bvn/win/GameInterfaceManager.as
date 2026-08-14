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
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.display.StageQuality;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.utils.ByteArray;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.GameQuality;
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.vos.ConfigVO;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.input.GameInputType;
import net.play5d.game.bvn.interfaces.IGameInput;
import net.play5d.game.bvn.interfaces.IExtendConfig;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.interfaces.IGameInterface;
import net.play5d.game.bvn.map.MapMain;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.utils.CreditsSpriteUtil;
import net.play5d.game.bvn.utils.EmbedAssetUtils;
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

    public function GameInterfaceManager() {
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
        trace('saveData', json);
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
                txt: 'TEAM PLAY', cn: GetLang('txt.game_interface.team_play'), children: [
                    {txt: 'TEAM ACRADE', cn: GetLang('txt.game_interface.team_play_acrade')},
                    {txt: 'TEAM VS PEOPLE', cn: GetLang('txt.game_interface.team_play_vs_people')},
                    {txt: 'TEAM VS CPU', cn: GetLang('txt.game_interface.team_play_vs_CPU')},
                    {txt: 'TEAM WATCH', cn: GetLang('txt.game_interface.team_play_watch')}
                ]
            },

            {
                txt: 'SINGLE PLAY', cn: GetLang('txt.game_interface.single_play'), children: [
                    {txt: 'SINGLE ACRADE', cn: GetLang('txt.game_interface.single_play_acrade')},
                    {txt: 'SINGLE VS PEOPLE', cn: GetLang('txt.game_interface.single_play_vs_people')},
                    {txt: 'SINGLE VS CPU', cn: GetLang('txt.game_interface.single_play_vs_CPU')},
                    {txt: 'SINGLE WATCH', cn: GetLang('txt.game_interface.single_play_watch')}
                ]
            },

            {
                txt: 'MUSOU PLAY', cn: GetLang('txt.game_interface.musou_play'), children: [
                    {txt: 'MUSOU ACRADE', cn: GetLang('txt.game_interface.musou_acrade')}
                ]
            },

            {
                txt: 'LAN PLAY', cn: GetLang('txt.game_interface_manager.lan_play'), func: function ():void {
                    LANGameCtrl.I.goLANGameState();
                }
            },

            /*{txt:'SURVIVOR',cn:'挑战模式'},*/ //暂未开放
            {txt: 'OPTION', cn: GetLang('txt.game_interface.option')},
            {txt: 'TRAINING', cn: GetLang('txt.game_interface.training')},
            {txt: 'CREDITS', cn: GetLang('txt.game_interface.credits')},
            {txt: 'MORE GAMES', cn: GetLang('txt.game_interface.more_games')},
            {
                txt: 'EXIT', cn: GetLang('txt.game_interface_manager.exit'), func: function ():void {
                    GameUI.confrim(
                            GetLang('confirm.exit_game_title'),
                            GetLang('confirm.exit_game'),
                            NativeApplication.nativeApplication.exit
                    );
                }
            }
        ];
        return a;
    }

    public function getSettingMenu():Array {
        return [
            {txt: 'P1 KEY SET', cn: GetLang('txt.set_btn_group.p1_key_set')},
            {txt: 'P2 KEY SET', cn: GetLang('txt.set_btn_group.p2_key_set')},
            {
                txt   : 'P1 JOYSTICK SET', cn: GetLang('txt.set_btn_group.p1_joystick_set'),
                select: ViewManager.I.goP1JoyStickSet
            },
            {
                txt   : 'P2 JOYSTICK SET', cn: GetLang('txt.set_btn_group.p2_joystick_set'),
                select: ViewManager.I.goP2JoyStickSet
            },
            {
                txt      : 'COM LEVEL', cn: GetLang('txt.set_btn_group.com_level'),
                options  : [
                    {label: 'VERY EASY', cn: GetLang('txt.set_btn_group.com_level_very_easy'), value: 1},
                    {label: 'EASY', cn: GetLang('txt.set_btn_group.com_level_easy'), value: 2},
                    {label: 'NORMAL', cn: GetLang('txt.set_btn_group.com_level_normal'), value: 3},
                    {label: 'HARD', cn: GetLang('txt.set_btn_group.com_level_hard'), value: 4},
                    {label: 'VERY HARD', cn: GetLang('txt.set_btn_group.com_level_very_hard'), value: 5},
                    {label: 'HELL', cn: GetLang('txt.set_btn_group.com_level_hell'), value: 6}
                ],
                optoinKey: 'AI_level'
            },
            {
                txt      : 'OPERATE MODE', cn: GetLang('txt.set_btn_group.operate_mode'),
                options  : [
                    {label: 'NORMAL', cn: GetLang('txt.set_btn_group.operate_normal'), value: 0},
                    {label: 'CLASSIC', cn: GetLang('txt.set_btn_group.operate_classic'), value: 1}
                ],
                optoinKey: 'keyInputMode'
            },
            {
                txt      : 'LIFE', cn: GetLang('txt.set_btn_group.life'),
                options  : [
                    {label: '50%', cn: '50%', value: 0.5},
                    {label: '100%', cn: '100%', value: 1},
                    {label: '200%', cn: '200%', value: 2},
                    {label: '300%', cn: '300%', value: 3},
                    {label: '500%', cn: '500%', value: 5}
                ],
                optoinKey: 'fighterHP'
            },
            {
                txt      : 'TIME', cn: GetLang('txt.set_btn_group.time'),
                options  : [
                    {label: '30s', cn: GetLang('txt.set_btn_group.time_30'), value: 30},
                    {label: '60s', cn: GetLang('txt.set_btn_group.time_60'), value: 60},
                    {label: '90s', cn: GetLang('txt.set_btn_group.time_90'), value: 90},
                    {label: '∞', cn: GetLang('txt.set_btn_group.time_unlimited'), value: -1}
                ],
                optoinKey: 'fightTime'
            },
            {
                txt      : 'SOUND', cn: GetLang('txt.set_btn_group.sound'),
                options  : [
                    {label: '0%', cn: '0%', value: 0},
                    {label: '10%', cn: '10%', value: 0.1},
                    {label: '30%', cn: '30%', value: 0.3},
                    {label: '50%', cn: '50%', value: 0.5},
                    {label: '70%', cn: '70%', value: 0.7},
                    {label: '100%', cn: '100%', value: 1},
                ],
                optoinKey: 'soundVolume'
            },
            {
                txt      : 'BGM', cn: GetLang('txt.set_btn_group.bgm'),
                options  : [
                    {label: '0%', cn: '0%', value: 0},
                    {label: '10%', cn: '10%', value: 0.1},
                    {label: '30%', cn: '30%', value: 0.3},
                    {label: '50%', cn: '50%', value: 0.5},
                    {label: '70%', cn: '70%', value: 0.7},
                    {label: '100%', cn: '100%', value: 1},
                ],
                optoinKey: 'bgmVolume'
            },
            {
                txt      : 'QUALITY', cn: GetLang('txt.set_btn_group.quality'),
                options  : [
                    {label: 'LOW', cn: GetLang('txt.set_btn_group.quality_low'), value: GameQuality.LOW},
                    {label: 'MEDIUM', cn: GetLang('txt.set_btn_group.quality_medium'), value: GameQuality.MEDIUM},
                    {label: 'HIGH', cn: GetLang('txt.set_btn_group.quality_high'), value: GameQuality.HIGH},
                    {label: 'BEST', cn: GetLang('txt.set_btn_group.quality_best'), value: GameQuality.BEST}
                ],
                optoinKey: 'quality'
            },
            {
                txt      : 'SHOW HP', cn: GetLang('txt.set_btn_group.show_hp'),
                options  : [
                    {label: 'SHOW', cn: GetLang('txt.set_btn_group.hp_show'), value: true},
                    {label: 'HIDE', cn: GetLang('txt.set_btn_group.hp_hide'), value: false},
                ],
                optoinKey: 'isShowHp'
            },
            {
                txt      : 'DISPLAY MODE', cn: GetLang('txt.game_interface_manager.display_mode'),
                options  : [
                    {
                        label: 'FULLSCREEN',
                        cn   : GetLang('txt.game_interface_manager.display_fullscreen'),
                        value: true
                    },
                    {
                        label: 'WINDOW',
                        cn   : GetLang('txt.game_interface_manager.display_window'),
                        value: false
                    }
                ],
                optoinKey: 'isFullScreen'
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
        var map:MapMain = GameCtrl.I.gameState.getMap();
        if (map.mapLayer) {
            map.mapLayer.cacheAsBitmapMatrix = new Matrix();
        }
        if (map.frontLayer) {
            map.frontLayer.cacheAsBitmapMatrix = new Matrix();
        }
        if (map.frontFixLayer) {
            map.frontFixLayer.cacheAsBitmapMatrix = new Matrix();
        }
        if (map.bgLayer) {
            map.bgLayer.cacheAsBitmap = true;
        }
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
                InputManager.I.socket_input_p1.setInputers([InputManager.I.key_p1, InputManager.I.joy_p1]);
            }

            if (LANClientCtrl.I.active) {
                InputManager.I.key_p2.setConfig(GameData.I.config.key_p1);
                InputManager.I.joy_p2.setConfig(_extendsConfig.joy1Config);
                InputManager.I.socket_input_p2.setInputers([InputManager.I.key_p2, InputManager.I.joy_p2]);
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

    public function getCreadits(creditsInfo:String):Sprite {
        var sp:Sprite = CreditsSpriteUtil.build(creditsInfo, 'txt.game_interface_manager.credits_footer');

        var android:Sprite = PayUtils.getPaySp(EmbedAssetUtils.getAndroid());
        android.y          = 400;
        android.x          = 300;
        android.width      = 150;
        android.height     = 194;
        android.addEventListener(MouseEvent.MOUSE_OVER, payOverHandler);
        sp.addChild(android);

        var alipay:Sprite = PayUtils.getPaySp(EmbedAssetUtils.getAlipay());
        alipay.y          = 400;
        alipay.x          = android.x + 170;
        alipay.width      = 150;
        alipay.height     = 194;
        alipay.alpha      = 0.2;
        alipay.addEventListener(MouseEvent.MOUSE_OVER, payOverHandler);
        sp.addChild(alipay);

        var weixin:Sprite = PayUtils.getPaySp(EmbedAssetUtils.getWeixin());
        weixin.y          = 400;
        weixin.x          = alipay.x + 170;
        weixin.width      = 150;
        weixin.height     = 194;
        weixin.alpha      = 0.2;
        weixin.addEventListener(MouseEvent.MOUSE_OVER, payOverHandler);
        sp.addChild(weixin);

        function payOverHandler(e:MouseEvent):void {
            if (e.currentTarget == alipay) {
                alipay.alpha  = 1;
                weixin.alpha  = 0.2;
                android.alpha = 0.2;
            }

            if (e.currentTarget == weixin) {
                alipay.alpha  = 0.2;
                weixin.alpha  = 1;
                android.alpha = 0.2;
            }
            if (e.currentTarget == android) {
                alipay.alpha  = 0.2;
                weixin.alpha  = 0.2;
                android.alpha = 1;
            }
        }

        return sp;
    }

    public function checkFile(url:String, file:ByteArray):Boolean {
        return true;
    }

    public function addMusouMoney(back:Function):void {
        back(100 + Math.random() * 200);
    }

}
}
