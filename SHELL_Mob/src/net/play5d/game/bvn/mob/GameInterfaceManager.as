package net.play5d.game.bvn.mob {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.filesystem.File;
import flash.utils.ByteArray;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.GameInputType;
import net.play5d.game.bvn.data.GameQuality;
import net.play5d.game.bvn.data.vos.ConfigVO;
import net.play5d.game.bvn.interfaces.IGameInput;
import net.play5d.game.bvn.interfaces.IExtendConfig;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.interfaces.IGameInterface;
import net.play5d.game.bvn.map.MapLayerCacheUtil;
import net.play5d.game.bvn.mob.data.ExtendConfig;
import net.play5d.game.bvn.mob.input.InputManager;
import net.play5d.game.bvn.mob.screenpad.ScreenPadManager;
import net.play5d.kyo.air.utils.FileUtils;
import net.play5d.game.bvn.mob.views.ViewManager;
import net.play5d.game.bvn.utils.CreditsSpriteUtil;
import net.play5d.game.bvn.utils.GameLogger;
import net.play5d.game.bvn.utils.GameSafeKeeper;
import net.play5d.game.bvn.utils.URL;

public class GameInterfaceManager implements IGameInterface {

    public static var ENGLISH_VERSION:Boolean      = false;
    private static var _extendsConfig:ExtendConfig = new ExtendConfig();

    public static function get config():ExtendConfig {
        return _extendsConfig;
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
        GameLogger.debug('sys', 'saveData ' + json);
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
                txt: 'TEAM PLAY', cn: GetLang('menu.team_play'), children: [
                    {txt: 'TEAM ARCADE', cn: GetLang('menu.team_arcade')},
                    {txt: 'TEAM VS CPU', cn: GetLang('menu.team_vs_cpu')},
                    {txt: 'TEAM WATCH', cn: GetLang('menu.team_watch')}
                ]
            },

            {
                txt: 'SINGLE PLAY', cn: GetLang('menu.single_play'), children: [
                    {txt: 'SINGLE ARCADE', cn: GetLang('menu.single_arcade')},
                    {txt: 'SINGLE VS CPU', cn: GetLang('menu.single_vs_cpu')},
                    {txt: 'SINGLE WATCH', cn: GetLang('menu.single_watch')}
                ]
            },

            {
                txt: 'MUSOU PLAY', cn: GetLang('menu.musou_play'), children: [
                    {txt: 'MUSOU ARCADE', cn: GetLang('menu.musou_arcade')}
                ]
            },

            /*{txt:'SURVIVOR',cn:'挑战模式'},*/ //暂未开放
            {txt: 'OPTION', cn: GetLang('menu.option')},
            {txt: 'TRAINING', cn: GetLang('menu.training')},
            {txt: 'CREDITS', cn: GetLang('menu.credits')},
        ];
        return a;
    }

    public function getSettingMenu():Array {
        return [
            {
                txt   : 'JOY SET', cn: GetLang('settings.joy_set'),
                select: ViewManager.I.setScreenBtns
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
                txt      : 'SCREEN MODE', cn: GetLang('settings.screen_mode'),
                options  : [
                    {label: 'FILL', cn: GetLang('settings.screen_fill'), value: 0},
                    {label: 'RATIO', cn: GetLang('settings.screen_ratio'), value: 1}
                ],
                optionKey: 'screenMode'
            },
            {
                txt      : 'SOUND', cn: GetLang('settings.sound'),
                options  : [
                    {label: '0%', cn: '0%', value: 0},
                    {label: '10%', cn: '10%', value: 0.1},
                    {label: '30%', cn: '30%', value: 0.3},
                    {label: '50%', cn: '50%', value: 0.5},
                    {label: '70%', cn: '70%', value: 0.7},
                    {label: '100%', cn: '100%', value: 1}
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
                    {label: '100%', cn: '100%', value: 1}
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

        InputManager.I.joy_menu.setConfig(_extendsConfig.joyMenuConfig);
        InputManager.I.joy_p1.setConfig(_extendsConfig.joy1Config);

        InputManager.I.socket_input_p1.enabled = false;
        InputManager.I.socket_input_p2.enabled = false;

        InputManager.I.joy_menu.enabled = true;
        InputManager.I.joy_p1.enabled   = true;

        return true;
    }


    public function applyConfig(config:Object):void {
        var cfg:ConfigVO = config as ConfigVO;
        if (!cfg) {
            return;
        }

        switch (cfg.quality) {
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

    public function getCredits(creditsInfo:String):Sprite {
        return CreditsSpriteUtil.build(creditsInfo, 'credits.footer');
    }

    public function checkFile(url:String, file:ByteArray):Boolean {
        return GameSafeKeeper.I.checkFile(url, file);
    }

    public function addMusouMoney(back:Function):void {
        var addMoney:int = 100 + Math.random() * 200;
        back(addMoney);
    }

}
}
