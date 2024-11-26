package net.play5d.game.bvn.mob.ctrls {
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.mob.views.lan.LANExitDialog;
import net.play5d.game.bvn.utils.KeyBoarder;

public class LanGameMenuCtrl {

    private static var _i:LanGameMenuCtrl;

    public static function get I():LanGameMenuCtrl {
        _i ||= new LanGameMenuCtrl();
        return _i;
    }

    public function LanGameMenuCtrl() {
    }
    private var _isKeyDown:Boolean;
    private var _exitDialog:LANExitDialog;

    public function init():void {

        _exitDialog = new LANExitDialog();
        _exitDialog.hide();
        KeyBoarder.listen(keyHandler);
    }

    public function dispose():void {
        if (_exitDialog) {
            try {
                MainGame.I.root.removeChild(_exitDialog);
            }
            catch (e:Error) {
                trace(e);
            }
            _exitDialog.destory();
            _exitDialog = null;
        }

        KeyBoarder.unListen(keyHandler);

        _isKeyDown = false;

    }

    private function keyHandler(e:KeyboardEvent):void {

        if (e.type == KeyboardEvent.KEY_DOWN) {
            if (_isKeyDown) {
                return;
            }
            if (!_exitDialog) {
                return;
            }
            if (e.keyCode == Keyboard.ESCAPE) {
                _isKeyDown = true;
                if (_exitDialog.isShowing()) {
                    _exitDialog.hide();
                }
                else {
                    MainGame.I.root.addChild(_exitDialog);
                    _exitDialog.show();
                }
            }
        }

        if (e.type == KeyboardEvent.KEY_UP) {
            if (e.keyCode == Keyboard.ESCAPE) {
                _isKeyDown = false;
            }
        }

    }

}
}
