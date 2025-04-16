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
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.ByteArray;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.GameQuality;
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.vos.ConfigVO;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.input.GameInputType;
import net.play5d.game.bvn.input.IGameInput;
import net.play5d.game.bvn.interfaces.IExtendConfig;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.interfaces.IGameInterface;
import net.play5d.game.bvn.map.MapMain;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.utils.EmbedAssetUtils;
import net.play5d.game.bvn.utils.GithubUtils;
import net.play5d.game.bvn.utils.PayUtils;
import net.play5d.game.bvn.utils.URL;
import net.play5d.game.bvn.win.ctrls.LANClientCtrl;
import net.play5d.game.bvn.win.ctrls.LANGameCtrl;
import net.play5d.game.bvn.win.ctrls.LANServerCtrl;
import net.play5d.game.bvn.win.data.ExtendConfig;
import net.play5d.game.bvn.win.input.InputManager;
import net.play5d.game.bvn.win.utils.FileUtils;
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
        FileUtils.writeAppFloderFile('bvnsave.sav', json);
        trace('saveData', json);
    }

    public function loadGame():Object {
        var url:String  = FileUtils.getAppFloderFileUrl('bvnsave.sav');
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
                txt: 'TEAM PLAY', cn: '小队模式', children: [
                    {txt: 'TEAM ACRADE', cn: '闯关模式'},
                    {txt: 'TEAM VS PEOPLE', cn: '2P对战'},
                    {txt: 'TEAM VS CPU', cn: '对战电脑'},
                    {txt: 'TEAM WATCH', cn: '观战电脑'}
                ]
            },

            {
                txt: 'SINGLE PLAY', cn: '单人模式', children: [
                    {txt: 'SINGLE ACRADE', cn: '闯关模式'},
                    {txt: 'SINGLE VS PEOPLE', cn: '2P对战'},
                    {txt: 'SINGLE VS CPU', cn: '对战电脑'},
                    {txt: 'SINGLE WATCH', cn: '观战电脑'}
                ]
            },

            {
                txt: 'MUSOU PLAY', cn: '无双模式', children: [
                    {txt: 'MUSOU ACRADE', cn: '无双模式'}
                ]
            },

            {
                txt: 'LAN PLAY', cn: '局域网对战', func: function ():void {
                    LANGameCtrl.I.goLANGameState();
                }
            },

            /*{txt:'SURVIVOR',cn:'挑战模式'},*/ //暂未开放
            {txt: 'OPTION', cn: '游戏设置'},
            {txt: 'TRAINING', cn: '练习模式'},
            {txt: 'CREDITS', cn: '制作组'},
            {txt: 'MORE GAMES', cn: '更多游戏'},
            {
                txt: 'EXIT', cn: '退出游戏', func: function ():void {
                    GameUI.confrim('EXIT GAME', '退出游戏？', NativeApplication.nativeApplication.exit);
                }
            }
        ];
        return a;
    }

    public function getSettingMenu():Array {
        return [
            {txt: 'P1 KEY SET', cn: '玩家1 按键设置'},
            {txt: 'P2 KEY SET', cn: '玩家2 按键设置'},
            {txt: 'P1 JOYSTICK SET', cn: '玩家1 手柄设置', select: ViewManager.I.goP1JoyStickSet},
            {txt: 'P2 JOYSTICK SET', cn: '玩家2 手柄设置', select: ViewManager.I.goP2JoyStickSet},
            {
                txt      : 'COM LEVEL', cn: '电脑等级',
                options  : [
                    {label: 'VERY EASY', cn: '非常简单', value: 1},
                    {label: 'EASY', cn: '简单', value: 2},
                    {label: 'NORMAL', cn: '正常', value: 3},
                    {label: 'HARD', cn: '困难', value: 4},
                    {label: 'VERY HARD', cn: '非常困难', value: 5},
                    {label: 'HELL', cn: '地狱', value: 6}
                ],
                optoinKey: 'AI_level'
            },
            {
                txt      : 'OPERATE MODE', cn: '按键操作模式',
                options  : [
                    {label: 'NORMAL', cn: '正常模式', value: 0},
                    {label: 'CLASSIC', cn: '经典模式', value: 1}
                ],
                optoinKey: 'keyInputMode'
            },
            {
                txt      : 'LIFE', cn: '生命值',
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
                txt      : 'TIME', cn: '对战时间',
                options  : [
                    {label: '30s', cn: '30秒', value: 30},
                    {label: '60s', cn: '60秒', value: 60},
                    {label: '90s', cn: '90秒', value: 90},
                    {label: '∞', cn: '无限制', value: -1}
                ],
                optoinKey: 'fightTime'
            },
            {
                txt      : 'SOUND', cn: '游戏音效',
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
                txt      : 'BGM', cn: '背景音乐',
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
                txt      : 'QUALITY', cn: '画质等级',
                options  : [
                    {label: 'LOW', cn: '低', value: GameQuality.LOW},
                    {label: 'MEDIUM', cn: '中', value: GameQuality.MEDIUM},
                    {label: 'HIGH', cn: '高', value: GameQuality.HIGH},
                    {label: 'BEST', cn: '最高', value: GameQuality.BEST}
                ],
                optoinKey: 'quality'
            },
            {
                txt      : 'SHOW HP', cn: '显示血量',
                options  : [
                    {label: 'SHOW', cn: '显示', value: true},
                    {label: 'HIDE', cn: '隐藏', value: false},
                ],
                optoinKey: 'isShowHp'
            },
            {
                txt      : 'DISPLAY MODE', cn: '显示模式',
                options  : [
                    {label: 'FULLSCREEN', cn: '全屏', value: true},
                    {label: 'WINDOW', cn: '窗口', value: false}
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
//					vec.push(InputManager.I.socket_input_menu);
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

//				InputManager.I.socket_input_menu.enabled = false;
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

//			InputManager.I.socket_input_menu.enabled = false;
        InputManager.I.socket_input_p1.enabled = false;
        InputManager.I.socket_input_p2.enabled = false;


//			_extendsConfig.updateJoyConfig();

        return true;
    }

    public function applyConfig(config:ConfigVO):void {
        switch (config.quality) {
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
        var sp:Sprite = new Sprite();

//			creditsInfo += '安卓手机版 : <a href="' + URL.markURL('https://www.3839.com/a/103303.htm') + '"
// target="_blank">安卓手机版本下载</a>'+"<br/>"; creditsInfo += '游戏官网 : <a href="' + URL.markURL('http://www.1212321.com/') +
// '" target="_blank">www.1212321.com</a>'+"&nbsp;&nbsp; "; creditsInfo += '游戏论坛 : <a href="' +
// URL.markURL('http://bbs.5dplay.net/') + '" target="_blank">bbs.5dplay.net</a>'+"<br/>";  creditsInfo += '5dplay.net
// 已转向 1212321.com，并以新的面孔出现，请知晓。' + "<br/>"; creditsInfo += '游戏做到今天非常不易，期待您的捐赠（金额不限），谢谢！' + "<br/>";
        var commitsHash:String = GithubUtils.getCommitsHash();
        var commitsUrl:String = GithubUtils.getCommitsUrlByHash(commitsHash);
        creditsInfo += '提交：<a href="' + commitsUrl + '" target="_blank">' + commitsHash + '</a><br/>' +
                       '官网：<a href="http://www.1212321.com/" target="_blank">www.1212321.com</a>    ' +
                       '论坛：<a href="http://bbs.1212321.com/" target="_blank">bbs.1212321.com</a><br/>' +
                       '邮箱：5dplay@qun.mail.163.com （人才招募中）<br/>';

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

//			var pateronSp:Sprite = new Sprite();
//			var pateron:Bitmap = EmbedAssetUtils.getPatreon();
//			pateron.width = 100;
//			pateron.height = 129;
//			pateronSp.addChild(pateron);
//			pateronSp.y = 250;
//			pateronSp.x = 680;
//			pateronSp.buttonMode = true;
//			pateronSp.addEventListener(MouseEvent.MOUSE_UP,URL.supportUS,false,0,true);
//			sp.addChild(pateronSp);

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
        //return GameSafeKeeper.I.checkFile(url, file);
    }

    public function addMusouMoney(back:Function):void {
        back(100 + Math.random() * 200);
    }

}
}
