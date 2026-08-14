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
                    GetLang('alert.menu_stage.update_title'),
                    GetLang('alert.update_ctrl.force_update'),
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
                ? GetLang('confirm.update_ctrl.update_info_prefix', {detail: version.info})
                : '';

        GameUI.confrim(
                GetLang('alert.menu_stage.update_title'),
                GetLang('confirm.update_ctrl.optional_update', {info: updateInfo}),
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
