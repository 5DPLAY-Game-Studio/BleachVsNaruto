package net.play5d.game.bvn.mob.ctrls {
import net.play5d.game.bvn.mob.input.InputManager;
import net.play5d.game.bvn.mob.utils.LANUtils;

public class SimpleLockFrameServerLogic {

    public function SimpleLockFrameServerLogic() {
    }
    public var enabled:Boolean;
    private var _clientK:int       = -1;
    private var _frame:int         = 0;
    private var _nextLockFrame:int = 0;
    private var _clientFrame:int;
    private var _retrySendTimes:int;
    private var _lastSendUdpMsg:String;

    public function reset():void {
        _frame          = 0;
        _clientK        = -1;
        _clientFrame    = 0;
        _nextLockFrame  = 0;
        _lastSendUdpMsg = null;
    }

    public function dispose():void {

    }

    public function render():Boolean {
        if (!enabled) {
            return true;
        }
        if (_clientK == -1) {
            return false;
        } //等待客户端

        if (_frame >= _clientFrame + LANUtils.LOCK_KEYFRAME * 2) {
            reSendUpdate();
            return false;
        }

        if (_frame++ % LANUtils.LOCK_KEYFRAME == 0) {
            sendUpdate();
        }

        return true;
    }

    public function receiveInput(k:String):void {
        var ks:Array = k.split(',');
        _clientFrame = parseInt(ks[0], 16);
        _clientK     = parseInt(ks[1], 16);
    }

    private function reSendUpdate():void {
        _retrySendTimes++;
        if (_retrySendTimes > LANUtils.LOCK_KEYFRAME) {
            sendUpdate();
            if (_lastSendUdpMsg) {
                LANServerCtrl.I.sendAllUDP(_lastSendUdpMsg);
            }
            _retrySendTimes = 0;
        }
    }

    private function sendUpdate():void {
        var serverK:int = InputManager.I.socket_input_p1.getSocketData();

        var updateArr:Array = [];
        updateArr.push(serverK.toString(16), _clientK.toString(16), _frame.toString(16));
        _lastSendUdpMsg = updateArr.join(',');
        LANServerCtrl.I.sendAllUDP(_lastSendUdpMsg);

        InputManager.I.socket_input_p1.resetInput();
        InputManager.I.socket_input_p1.setSocketData(serverK);
        InputManager.I.socket_input_p2.setSocketData(_clientK);
    }


}
}
