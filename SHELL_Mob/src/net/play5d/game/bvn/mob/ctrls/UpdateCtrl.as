package net.play5d.game.bvn.mob.ctrls {
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.mob.data.VersionInfoVO;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.kyo.utils.WebUtils;

public class UpdateCtrl {

    private static var _i:UpdateCtrl;

    public static function get I():UpdateCtrl {
        _i ||= new UpdateCtrl();
        return _i;
    }

    public function UpdateCtrl() {
    }

    public function update(updateBack:Function = null, skipBack:Function = null):void {
        var version:VersionInfoVO = GamePolyCtrl.I.getVersion();
        if (!version || !version.version || !version.enabled) {
            if (skipBack != null) {
                skipBack();
            }
            return;
        }

        if (MainGame.VERSION == version.version) {
            if (skipBack != null) {
                skipBack();
            }
            return;
        }

        if (version.forceUpdate) {
            GameUI.alert('UPDATE', '您的版本过低，请进行更新！', function ():void {
                WebUtils.getURL(version.url);
                if (updateBack != null) {
                    updateBack();
                }
            });
            return;
        }

        var updateInfo:String = '\n' +
                                (
                                        version.info ?
                                '更新内容：' + version.info
                                                     :
                                        ''
                                );

        GameUI.confrim('UPDATE', '有新的版本，是否更新？' + updateInfo, function ():void {
            WebUtils.getURL(version.url);
            if (updateBack != null) {
                updateBack();
            }
        }, function ():void {
            if (skipBack != null) {
                skipBack();
            }
        });
    }
}
}
