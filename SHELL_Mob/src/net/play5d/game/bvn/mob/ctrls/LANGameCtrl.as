package net.play5d.game.bvn.mob.ctrls {
import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.mob.data.HostVO;
import net.play5d.game.bvn.mob.sockets.SocketClient;
import net.play5d.game.bvn.mob.utils.LANUtils;
import net.play5d.game.bvn.mob.views.lan.LANGameState;

public class LANGameCtrl {

    public static const PORT_UDP_SERVER:int = 17477;
    public static const PORT_UDP_CLIENT:int = 17478;

    public static const PORT_TCP:int = 17511;

    private static var _i:LANGameCtrl;

    public static function get I():LANGameCtrl {
        _i ||= new LANGameCtrl();
        return _i;
    }

    public function LANGameCtrl() {
    }
    public var gameMode:int;
    public var userName:String = 'test';
    private var _client:SocketClient;

    public function goLANGameState():void {
        this.gameMode = gameMode;
        MainGame.stageCtrl.goStage(new LANGameState());
    }

    public function gameStart(host:HostVO):void {

        GameData.I.config.fighterHP = host.hp;
        GameData.I.config.fightTime = host.gameTime;

        GameConfig.setGameFps(30);
        GameData.I.config.keyInputMode = 1;

        LANUtils.updateParams();

        switch (host.gameMode) {
        case 1:
            GameMode.currentMode = GameMode.TEAM_VS_PEOPLE;
            break;
        case 2:
            GameMode.currentMode = GameMode.SINGLE_VS_PEOPLE;
            break;
        }

        LanGameMenuCtrl.I.init();

        MainGame.I.goSelect();
    }

    public function gameEnd():void {
        GameData.I.loadData();
        MainGame.I.goMenu();
        LanGameMenuCtrl.I.dispose();
    }

}
}
