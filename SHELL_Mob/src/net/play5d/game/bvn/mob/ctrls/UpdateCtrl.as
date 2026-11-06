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
            GameUI.alert(
                    GetLang('menu.update.title'),
                    GetLang('update.force'),
                    function ():void {
                        WebUtils.getURL(version.url);
                        if (updateBack != null) {
                            updateBack();
                        }
                    }
            );
            return;
        }

        var updateInfo:String = version.info
                ? GetLang('update.info_prefix', {detail: version.info})
                : '';

        GameUI.confirm(
                GetLang('menu.update.title'),
                GetLang('update.optional', {info: updateInfo}),
                function ():void {
                    WebUtils.getURL(version.url);
                    if (updateBack != null) {
                        updateBack();
                    }
                },
                function ():void {
                    if (skipBack != null) {
                        skipBack();
                    }
                }
        );
    }
}
}
