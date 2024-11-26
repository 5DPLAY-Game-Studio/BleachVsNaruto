package net.play5d.game.bvn.mob {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.filesystem.File;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.ByteArray;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.GameQuality;
import net.play5d.game.bvn.ctrl.EffectCtrl;
import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.ConfigVO;
import net.play5d.game.bvn.input.GameInputType;
import net.play5d.game.bvn.input.IGameInput;
import net.play5d.game.bvn.interfaces.IExtendConfig;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.interfaces.IGameInterface;
import net.play5d.game.bvn.map.MapMain;
import net.play5d.game.bvn.mob.data.ExtendConfig;
import net.play5d.game.bvn.mob.input.InputManager;
import net.play5d.game.bvn.mob.screenpad.ScreenPadManager;
import net.play5d.game.bvn.mob.utils.FileUtils;
import net.play5d.game.bvn.mob.views.ViewManager;
import net.play5d.game.bvn.utils.GameSafeKeeper;
import net.play5d.game.bvn.utils.URL;

public class GameInterfaceManager implements IGameInterface {

    public static var ENGLISH_VERSION:Boolean = false;
    private static var _extendsConfig:ExtendConfig = new ExtendConfig();

    public static function get config():ExtendConfig {
        return _extendsConfig;
    }

    public function GameInterfaceManager() {
    }

    public function initTitleUI(ui:DisplayObject):void {
    }

    public function moreGames():void {
        URL.go(URL.WEBSITE, true);
    }

    public function submitScore(score:int):void {
    }

    public function showRank():void {
    }

    public function saveGame(data:Object):void {
        var json:String = JSON.stringify(data);
        var file:File   = File.applicationStorageDirectory.resolvePath('bvnsave.sav');

        FileUtils.writeFile(file.nativePath, json);
        trace('saveData', json);
    }

    public function loadGame():Object {
        var file:File   = File.applicationStorageDirectory.resolvePath('bvnsave.sav');
        var json:String = FileUtils.readTextFile(file.nativePath);
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
                    {txt: 'TEAM VS CPU', cn: '对战电脑'}
                ]
            },

            {
                txt: 'SINGLE PLAY', cn: '单人模式', children: [
                    {txt: 'SINGLE ACRADE', cn: '闯关模式'},
                    {txt: 'SINGLE VS CPU', cn: '对战电脑'}
                ]
            },

//				{txt:'WIFI PLAY',cn:'WIFI对战',func:function():void{
//					LANGameCtrl.I.goLANGameState();
//				}},

            {
                txt: 'MUSOU PLAY', cn: '无双模式', children: [
                    {txt: 'MUSOU ACRADE', cn: '无双模式'}
                ]
            },

            /*{txt:'SURVIVOR',cn:'挑战模式'},*/ //暂未开放
            {txt: 'OPTION', cn: '游戏设置'},
            {txt: 'TRAINING', cn: '练习模式'},
            {txt: 'CREDITS', cn: '制作组'},
            {txt: 'MORE GAMES', cn: '更多游戏'}
//				{txt:'EXIT',cn:'退出游戏',func:function():void{
//					GameUI.confrim('EXIT GAME','退出游戏？',NativeApplication.nativeApplication.exit);
////					AdManager.I.showFullScreenAD();
//				}}
        ];
        return a;
    }

    public function getSettingMenu():Array {
        return [
//				{txt:"JOYSTICK SET",cn:"手柄设置",select:ViewManager.I.goP1JoyStickSet},
            {
                txt   : 'JOY SET', cn: '按钮设置',
                select: ViewManager.I.setScreenBtns
            },
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
                txt      : 'SCREEN MODE', cn: '屏幕模式',
                options  : [
                    {label: 'FILL', cn: '拉伸', value: 0},
                    {label: 'CENTER', cn: '等比例', value: 1}
                ],
                optoinKey: 'screenMode'
            },
            {
                txt      : 'SOUND', cn: '游戏音效',
                options  : [
                    {label: '0%', cn: '0%', value: 0},
                    {label: '10%', cn: '10%', value: 0.1},
                    {label: '30%', cn: '30%', value: 0.3},
                    {label: '50%', cn: '50%', value: 0.5},
                    {label: '70%', cn: '70%', value: 0.7},
                    {label: '100%', cn: '100%', value: 1}
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
                    {label: '100%', cn: '100%', value: 1}
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
            }
        ];
    }

    public function getGameInput(type:String):Vector.<IGameInput> {

        var vec:Vector.<IGameInput> = new Vector.<IGameInput>();

        switch (type) {
        case GameInputType.MENU:
            vec.push(InputManager.I.screen_menu);
            vec.push(InputManager.I.joy_menu);
            break;
        case GameInputType.P1:
            vec.push(InputManager.I.screen_p1);
            vec.push(InputManager.I.joy_p1);
            vec.push(InputManager.I.socket_input_p1);
            break;
        case GameInputType.P2:
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
//			if(LANServerCtrl.I.active || LANClientCtrl.I.active){
//
//				/**
//				 * 使用锁帧同步算法进行游戏操作同步
//				 * 客户端采集操作数据，定时发给服务器，服务器定时更新服务端和客户端
//				 * 服务端在同样的时间线采集操作数据，定时更新并发送到客户端
//				 */
//
//				InputManager.I.screen_menu.enabled = false;
//				InputManager.I.screen_p1.enabled = false;
//
//				InputManager.I.joy_menu.enabled = false;
//				InputManager.I.joy_p1.enabled = false;
//
//				//				InputManager.I.socket_input_menu.enabled = false;
//				InputManager.I.socket_input_p1.enabled = true;
//				InputManager.I.socket_input_p2.enabled = true;
//
//				if(LANServerCtrl.I.active){
//					InputManager.I.socket_input_p1.setInputers([InputManager.I.screen_p1 , InputManager.I.joy_p1]);
//				}
//
//				if(LANClientCtrl.I.active){
//					InputManager.I.socket_input_p2.setInputers([InputManager.I.screen_p1 , InputManager.I.joy_p1]);
//				}
//
//				return true;
//			}

        InputManager.I.joy_menu.setConfig(_extendsConfig.joyMenuConfig);
        InputManager.I.joy_p1.setConfig(_extendsConfig.joy1Config);

        InputManager.I.socket_input_p1.enabled = false;
        InputManager.I.socket_input_p2.enabled = false;

        InputManager.I.joy_menu.enabled = true;
        InputManager.I.joy_p1.enabled   = true;

        return true;
    }


    public function applyConfig(config:ConfigVO):void {
        switch (config.quality) {
        case GameQuality.BEST:
            GameConfig.setGameFps(60);
            GameConfig.FPS_SHINE_EFFECT = 15;
            EffectCtrl.EFFECT_SMOOTHING = true;
            EffectCtrl.SHADOW_ENABLED   = true;
            EffectCtrl.SHAKE_ENABLED    = true;
            EffectCtrl.BG_BULR_ENABLED  = true;
            break;
        case GameQuality.HIGH:
            GameConfig.setGameFps(60);
            GameConfig.FPS_SHINE_EFFECT = 10;
            EffectCtrl.EFFECT_SMOOTHING = false;
            EffectCtrl.SHADOW_ENABLED   = true;
            EffectCtrl.SHAKE_ENABLED    = true;
            EffectCtrl.BG_BULR_ENABLED  = false;
            break;
        case GameQuality.MEDIUM:
            GameConfig.setGameFps(30);
            GameConfig.FPS_SHINE_EFFECT = 10;
            EffectCtrl.EFFECT_SMOOTHING = false;
            EffectCtrl.SHADOW_ENABLED   = true;
            EffectCtrl.SHAKE_ENABLED    = true;
            EffectCtrl.BG_BULR_ENABLED  = false;
            break;
        case GameQuality.LOW:
            GameConfig.setGameFps(30);
            GameConfig.FPS_SHINE_EFFECT = 0;
            EffectCtrl.EFFECT_SMOOTHING = false;
            EffectCtrl.SHADOW_ENABLED   = false;
            EffectCtrl.SHAKE_ENABLED    = false;
            EffectCtrl.BG_BULR_ENABLED  = false;
            break;
        }

        RootSprite.I.updateSize();
        ScreenPadManager.reBuild();

    }

    public function getCreadits(creditsInfo:String):Sprite {
        var sp:Sprite = new Sprite();

        creditsInfo += '游戏官网 : <a href="' + URL.markURL('http://www.1212321.com/') +
                       '" target="_blank">www.1212321.com</a>' + '<br/>';
        creditsInfo += '游戏论坛 : <a href="' + URL.markURL('http://bbs.1212321.com/') +
                       '" target="_blank">bbs.1212321.com</a>' + '<br/>';

        var txt:TextField = new TextField();

        var tf:TextFormat = new TextFormat();
        tf.font           = '微软雅黑';
        tf.size           = 20;
        tf.color          = 0xffff00;
        tf.leading        = 15;

        txt.defaultTextFormat = tf;

        txt.multiline = true;

        if (ENGLISH_VERSION) {
            txt.htmlText = 'website : <a href="' + URL.markURL('http://www.1212321.com/') +
                           '" target="_blank">www.1212321.com</a>' + '<br/>' +
                           'bbs : <a href="' + URL.markURL('http://bbs.1212321.com/') +
                           '" target="_blank">bbs.1212321.com</a>' + '<br/>';
        }
        else {
            txt.htmlText = creditsInfo;
        }
        txt.autoSize = TextFieldAutoSize.LEFT;

        txt.x = 50;
        txt.y = 30;

        sp.addChild(txt);

        return sp;
    }

    public function checkFile(url:String, file:ByteArray):Boolean {
        return GameSafeKeeper.I.checkFile(url, file);
    }

    public function addMosouMoney(back:Function):void {
//			var succ:* = function():void {
//				back(addMoney);
//			};
//			var fail:* = function():void {
//				GameUI.alert("FAIL","广告加载失败或正在加载");
//			};
//			var watchAD:* = function():void {
//				AdManager.I.showRewardVideo("金币",addMoney,succ,fail);
//			};
        var addMoney:int = 100 + Math.random() * 200;
        back(addMoney);
        //		GameUI.confrim("ADD MONEY","观看广告获得 1000-3000 金币! \n (制作不易，跪求支持)",watchAD);
    }

}
}
