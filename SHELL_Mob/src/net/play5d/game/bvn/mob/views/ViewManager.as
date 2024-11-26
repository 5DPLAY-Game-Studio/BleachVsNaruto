package net.play5d.game.bvn.mob.views {
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.mob.GameInterfaceManager;
import net.play5d.game.bvn.mob.RootSprite;
import net.play5d.game.bvn.mob.input.JoyStickConfigVO;
import net.play5d.game.bvn.stage.SettingStage;
import net.play5d.kyo.stage.IStage;

public class ViewManager {
    private static var _i:ViewManager;

    public static function get I():ViewManager {
        _i ||= new ViewManager();
        return _i;
    }

    public function ViewManager() {
    }

    public function goP1JoyStickSet():void {
        goJoyStickSet(1, GameInterfaceManager.config.joy1Config);
    }

    public function setScreenBtns():void {
        var setBtnView:SetScreenBtnView = new SetScreenBtnView();
        RootSprite.I.addChildToGameSprite(setBtnView);
    }

    private function goJoyStickSet(player:int, config:JoyStickConfigVO):void {
        var curStg:IStage = MainGame.stageCtrl.currentStage;
        if (!curStg is SettingStage) {
            return;
        }
        var setStg:SettingStage         = curStg as SettingStage;
        var joyStickSetUI:JoyStickSetUI = new JoyStickSetUI();
        joyStickSetUI.setConfig(player, config);
        setStg.goInnerSetPage(joyStickSetUI);
    }

}
}
