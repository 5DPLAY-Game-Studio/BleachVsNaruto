package net.play5d.game.bvn.mob.ctrls {
import net.play5d.game.bvn.mob.input.InputManager;
import net.play5d.game.bvn.mob.utils.LANUtils;

public class SimpleLockFrameClientLogic {
    public function SimpleLockFrameClientLogic() {
    }
    public var enabled:Boolean;
    private var _serverK:int     = -1;
    private var _clientK:int     = -1;
    private var _frame:int       = 0;
    private var _serverFrame:int = 0;
    private var _readyFrame:int  = 0;
    private var _retrySendTimes:int;
    private var _lastSendMsg:String;

    public function reset():void {
        _frame       = 0;
        _serverFrame = 0;
        _serverK     = -1;
        _clientK     = -1;
        _lastSendMsg = null;
    }

    public function dispose():void {

    }

    public function render():Boolean {

        if (!enabled) {
            return true;
        }
        if (_serverK == -1) {
            if (_readyFrame == 0) {
                sendReady();
            }
            if (++_readyFrame > LANUtils.LOCK_KEYFRAME) {
                _readyFrame = 0;
            }
            return false;
        }

        if (_frame >= _serverFrame + LANUtils.LOCK_KEYFRAME) {
            retrySendUDP();
            return false;
        }

        if (_frame++ == _serverFrame - LANUtils.LOCK_KEYFRAME) {
            sendInput();
            InputManager.I.socket_input_p1.setSocketData(_serverK);
            InputManager.I.socket_input_p2.setSocketData(_clientK);
        }

        return true;
    }

    public function receiveInput(k:String):void {
        var ks:Array = k.split(',');
        _serverK     = parseInt(ks[0], 16);
        _clientK     = parseInt(ks[1], 16);
        _serverFrame = parseInt(ks[2], 16);
    }

    private function retrySendUDP():void {
        _retrySendTimes++;
        if (_retrySendTimes > LANUtils.LOCK_KEYFRAME) {
            if (_lastSendMsg) {
                LANClientCtrl.I.sendUDP(_lastSendMsg);
            }
            _retrySendTimes = 0;
        }
    }

    private function sendReady():void {
        var ks:Array = [];
        ks.push(int(0).toString(16), int(0).toString());
        LANClientCtrl.I.sendUDP(ks.join(','));
    }

    private function sendInput():void {
        trace('sendInput');
        var clientK:int = InputManager.I.socket_input_p2.getSocketData();

        var data:Array = [];
        data.push(clientK.toString(16), _frame.toString(16));
        _lastSendMsg = data.join(',');

        LANClientCtrl.I.sendUDP(_lastSendMsg);
        InputManager.I.socket_input_p2.resetInput();
    }

}
}
