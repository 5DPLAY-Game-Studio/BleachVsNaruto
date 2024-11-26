package net.play5d.game.bvn.mob {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.mob.views.GameSideBg;
import net.play5d.game.bvn.ui.UIUtils;

public class RootSprite {
    public static var FULL_SCREEN_SIZE:Point = new Point();
    public static var STAGE:Stage;
    private static var _i:RootSprite;

    public static function get I():RootSprite {
        _i ||= new RootSprite();
        return _i;
    }

    public function RootSprite() {
    }
    private var _sp:Sprite;
    private var _gameSprite:Sprite;
    private var _mainGame:MainGame;
    private var _showGameSide:Boolean = false;

//		private var _assetLoader:AssetLoader = new AssetLoader();
    private var _gameSideBg:GameSideBg;

    public function getMainGame():MainGame {
        return _mainGame;
    }

    public function init(sp:Sprite):void {
        _sp = sp;
    }

    public function buildGame(successBack:Function, failBack:Function):void {
//			AssetManager.I.setAssetLoader(_assetLoader);

        _gameSprite = new Sprite();
        _sp.addChild(_gameSprite);
        _mainGame = new MainGame();
//        _mainGame.initlize(_gameSprite, STAGE, successBack, failBack);
        _mainGame.initlize(_gameSprite, STAGE, function ():void {
            _mainGame.goLanguage(function ():void {
                trace('字体名称：' + FONT.fontName);
                UIUtils.LOCK_FONT = FONT.fontName;

                GameData.I.saveData();
                _mainGame.initalizeLoad(successBack, failBack);
            });

        }, failBack);

        updateFullScreenSize();
    }

    public function addChild(d:DisplayObject):void {
        _sp.addChild(d);
    }

    public function addChildToGameSprite(d:DisplayObject):void {
        _gameSprite && _gameSprite.addChild(d);
    }

    public function updateSize():void {
        updateFullScreenSize();
    }

    private function updateGameSize():void {
        trace('updateGameSize');

        if (!_gameSprite) {
            trace('_gameSprite is null, return!');
            return;
        }

        var stageWidth:Number  = STAGE.stageWidth;
        var stageHeight:Number = STAGE.stageHeight;
        var sizeX:Number       = GameConfig.GAME_SIZE.x;
        var sizeY:Number       = GameConfig.GAME_SIZE.y;

        var X:Number      = 0;
        var Y:Number      = 0;
        var XScale:Number = 0;
        var YScale:Number = 0;
        var showGameSide:Boolean;

        switch (GameInterfaceManager.config.screenMode) {
        case 0:
            XScale = stageWidth / sizeX;
            YScale = stageHeight / sizeY;
            X      = Y = 0;

            showGameSide = false;
            break;
        case 1:

            var sx:Number = stageWidth / sizeX;
            var sy:Number = stageHeight / sizeY;

            if (sx < sy) {
                XScale = YScale = sx;
                Y      = (
                                 stageHeight - sizeY * sx
                         ) / 2;
            }
            else {
                XScale = YScale = sy;
                X      = (
                                 stageWidth - sizeX * sy
                         ) / 2;
            }
            showGameSide = true;
            break;
        }

        if (_showGameSide == showGameSide &&
            Math.abs(_gameSprite.x - X) < 1 &&
            Math.abs(_gameSprite.y - Y) < 1 &&
            Math.abs(_gameSprite.scaleX - XScale) < 1 &&
            Math.abs(_gameSprite.scaleY - YScale) < 1) {
            trace('scale samed, return!');
            return;
        }

        _gameSprite.x      = X;
        _gameSprite.y      = Y;
        _gameSprite.scaleX = XScale;
        _gameSprite.scaleY = YScale;

        if (showGameSide) {
            var screenPoint:Point = new Point(stageWidth, stageHeight);

            var gameRect:Rectangle = new Rectangle(
                    X,
                    Y,
                    sizeX * XScale,
                    sizeY * YScale
            );

//				trace('resize', screenPoint, gameRect);

            if (!_gameSideBg) {
                _gameSideBg = new GameSideBg(screenPoint, gameRect);
                _sp.addChildAt(_gameSideBg, 0);
            }
            else {
                _gameSideBg.update(screenPoint, gameRect);
            }
        }
        else {
            if (_gameSideBg) {
                _gameSideBg.destory();
                _gameSideBg = null;
            }
        }


        GameConfig.GAME_SCALE.x = XScale;
        GameConfig.GAME_SCALE.y = YScale;

        _showGameSide = showGameSide;

//			trace('RESET GAME_SIZE', GameConfig.GAME_SCALE.x, GameConfig.GAME_SCALE.y);
        trace('==== UPDATE GAME SIZE =========================================');
        trace('stage W & H :', stageWidth, stageHeight);
        trace('game rect :', _gameSprite.x, _gameSprite.y, sizeX * XScale, sizeY * YScale);
        trace('game scale :', GameConfig.GAME_SCALE.x, GameConfig.GAME_SCALE.y);
        trace('====------------------=========================================');
    }

    public function updateFullScreenSize(e:Event = null):void {
        var stageWidth:Number  = STAGE.stageWidth;
        var stageHeight:Number = STAGE.stageHeight;

        if (stageWidth > stageHeight) {
            FULL_SCREEN_SIZE.x = stageWidth;
            FULL_SCREEN_SIZE.y = stageHeight;
        }
        else {
            FULL_SCREEN_SIZE.x = stageHeight;
            FULL_SCREEN_SIZE.y = stageWidth;
        }

        updateGameSize();
    }
}
}
