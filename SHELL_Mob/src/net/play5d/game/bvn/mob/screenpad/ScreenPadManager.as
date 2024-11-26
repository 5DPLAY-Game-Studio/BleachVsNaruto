package net.play5d.game.bvn.mob.screenpad {
import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.TouchEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import flash.utils.Dictionary;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrl.GameRender;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.mob.ctrls.MobileCtrler;
import net.play5d.game.bvn.mob.input.InputManager;
import net.play5d.game.bvn.mob.input.ScreenPadInput;
import net.play5d.game.bvn.stage.GameStage;
import net.play5d.game.bvn.stage.SelectFighterStage;
import net.play5d.kyo.stage.events.KyoStageEvent;

public class ScreenPadManager {

//		private static var _menu:ScreenPadMenu;
    private static var _game:ScreenPadGame;
    private static var _selectFighter:ScreenPadSelectFighter;
    private static var _curMode:int = -1;
    private static var _stage:Stage;

    private static var _listened:Dictionary = new Dictionary();

    public static function initlize(stage:Stage):void {

//			ScreenPadUtils.scale = RootSprite.FULL_SCREEN_SIZE.y / GameConfig.GAME_SIZE.y;

        _stage = stage;

        GameEvent.addEventListener(GameEvent.PAUSE_GAME, pauseResumeHandler);
        GameEvent.addEventListener(GameEvent.RESUME_GAME, pauseResumeHandler);

//			_menu = new ScreenPadMenu(stage);
//			_menu.inputers = new Vector.<ScreenPadInput>();
//			_menu.inputers.push(InputManager.I.screen_menu , InputManager.I.screen_p1);

        _game          = new ScreenPadGame(stage);
        _game.inputers = new Vector.<ScreenPadInput>();
        _game.inputers.push(InputManager.I.screen_p1);
        _game.menuInputer = InputManager.I.screen_menu;

        _selectFighter          = new ScreenPadSelectFighter(stage);
        _selectFighter.inputers = new Vector.<ScreenPadInput>();
        _selectFighter.inputers.push(InputManager.I.screen_menu, InputManager.I.screen_p1);

        Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;

//			gameMode();

    }

    public static function reBuild():void {
        var mode:int = _curMode;
        _curMode     = 0;
//			_menu.reBuild();
        _game.reBuild();
        _selectFighter.reBuild();

        switch (mode) {
        case 1:
            menuMode();
            break;
        case 2:
            gameMode();
            break;
        case 3:
            selectFighterMode();
            break;
        }

    }

    public static function listen():void {
        MainGame.stageCtrl.addEventListener(KyoStageEvent.CHANGE_STATE, stateChangeHandler);

        _stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchHandler);
        _stage.addEventListener(TouchEvent.TOUCH_MOVE, touchHandler);
        _stage.addEventListener(TouchEvent.TOUCH_END, touchHandler);

        GameEvent.addEventListener(GameEvent.PAUSE_GAME, onPauseGame);
        GameEvent.addEventListener(GameEvent.RESUME_GAME, onResumeGame);

        GameRender.add(render);
    }

    public static function testMode():void {
//			listen();
        gameMode();
    }

    public static function addTouchListener(target:DisplayObject, touchHandler:Function):void {
        _listened[target] = touchHandler;
    }

    public static function removeTouchListener(target:DisplayObject):void {
        delete _listened[target];
    }

    public static function clearTouchListener():void {
        _listened = new Dictionary();
    }

    private static function hideALL():void {
        _curMode = 0;
//			_menu.hide();
        _game.hide();
        _selectFighter.hide();
    }

    private static function menuMode():void {
        if (_curMode == 1) {
            return;
        }
        _curMode = 1;

        if (_stage) {
            _stage.mouseChildren = true;
        }

//			_menu.show();
        _game.hide();
        _selectFighter.hide();
//			AdManager.I.showBanner();
    }

    private static function gameMode():void {
        if (_curMode == 2) {
            return;
        }

        if (_stage) {
            _stage.mouseChildren = false;
        }

        _curMode = 2;
//			_menu.hide();
        _selectFighter.hide();
        _game.show();
//			AdManager.I.hideBanner();
    }

    private static function selectFighterMode():void {
        if (_curMode == 3) {
            return;
        }

        if (_stage) {
            _stage.mouseChildren = true;
        }

        _curMode = 3;
        _game.hide();
        _selectFighter.show();
    }

    private static function render():void {
        if (_game && _game.isShowing) {
            _game.render();
        }
    }

    public function ScreenPadManager() {

    }

    private static function pauseResumeHandler(e:GameEvent):void {
        if (e.type == GameEvent.PAUSE_GAME) {
            _game.onPause();
        }
        if (e.type == GameEvent.RESUME_GAME) {
            _game.onResume();
        }
    }

    private static function stateChangeHandler(e:KyoStageEvent):void {

//			if(e.stage is LogoState || e.stage is LANGameState){
//				hideALL();
//				return;
//			}

        if (e.stage is GameStage) {
            gameMode();
        }
        else if (e.stage is SelectFighterStage) {
            selectFighterMode();
        }
        else {
            menuMode();
        }
    }

    private static function touchHandler(e:TouchEvent):void {

        if (MobileCtrler.I.isAdPause) {
            MobileCtrler.I.adResume();
            return;
        }

        switch (_curMode) {
        case 1:
//					_menu.touchHandler(e);
            break;
        case 2:
            _game.touchHandler(e);
            break;
        case 3:
            _selectFighter.touchHandler(e);
            break;
        }

        listenTouchHandler(e);
    }

    private static function onPauseGame(e:GameEvent):void {
        menuMode();
    }

    private static function onResumeGame(e:GameEvent):void {
        gameMode();
    }

    private static function listenTouchHandler(e:TouchEvent):void {
        switch (e.type) {
        case TouchEvent.TOUCH_END:

            var touchPoint:Point = new Point(e.stageX, e.stageY);

            for (var k:* in _listened) {
                var i:DisplayObject = k as DisplayObject;
                if (!i.visible) {
                    continue;
                }

                if (!i || !_listened[i]) {
                    delete _listened[i];
                    continue;
                }

                var area:Rectangle = i.getBounds(_stage);
                if (area.containsPoint(touchPoint)) {
                    _listened[i](i);
                }
            }
            break;
        }
    }

}
}
