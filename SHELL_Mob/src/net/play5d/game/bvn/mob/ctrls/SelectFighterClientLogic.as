package net.play5d.game.bvn.mob.ctrls {
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.mob.utils.SelectFighterDataType;

public class SelectFighterClientLogic {
    public function SelectFighterClientLogic() {
    }

    public function init():void {
        SelectFighterStage.AUTO_FINISH = false;
        LoadingState.AUTO_START_GAME   = false;
        GameEvent.addEventListener(GameEvent.SELECT_FIGHTER_STEP, onSelectStep);
        GameEvent.addEventListener(GameEvent.SELECT_FIGHTER_INDEX, onSelectIndex);
    }

    public function dispose():void {
        GameEvent.removeEventListener(GameEvent.SELECT_FIGHTER_STEP, onSelectStep);
        GameEvent.removeEventListener(GameEvent.SELECT_FIGHTER_INDEX, onSelectIndex);
    }

    public function receiveSelect(data:Object):Boolean {
        var arr:Array = data as Array;
        if (!arr || arr[0] != SelectFighterDataType.KEY) {
            return false;
        }

        var type:int = arr[1];
        var stg:SelectFighterStage;

        switch (type) {
        case SelectFighterDataType.SELECT:
            try {
                stg = MainGame.stageCtrl.currentStage as SelectFighterStage;
                stg.setSelect(1, arr[2]);
            }
            catch (e:Error) {
            }
            break;
        case SelectFighterDataType.NEXT_STEP:
            try {
                stg = MainGame.stageCtrl.currentStage as SelectFighterStage;
                stg.nextStep();
            }
            catch (e:Error) {
            }
            break;
        case SelectFighterDataType.FIGHTER_FINISH:
            onSelectFighter(arr);
            break;
        case SelectFighterDataType.INDEX:
            receiveSelectIndex(arr);
            break;
        case SelectFighterDataType.INDEX_FINISH:
            onSelectFighterIndexFinish(arr);
            break;
        }

        return true;
    }


    private function onSelectFighter(arr:Array):void {
        if (MainGame.stageCtrl.currentStage is SelectFighterStage) {
            GameData.I.p1Select.fighter1 = arr[2];
            GameData.I.p1Select.fighter2 = arr[3];
            GameData.I.p1Select.fighter3 = arr[4];
            GameData.I.p1Select.fuzhu    = arr[5];

            GameData.I.p2Select.fighter1 = arr[6];
            GameData.I.p2Select.fighter2 = arr[7];
            GameData.I.p2Select.fighter3 = arr[8];
            GameData.I.p2Select.fuzhu    = arr[9];

            GameData.I.selectMap = arr[10];

            (
                    MainGame.stageCtrl.currentStage as SelectFighterStage
            ).goLoadGame();
        }
    }

    private function receiveSelectIndex(arr:Array):void {
        var stg:LoadingState = MainGame.stageCtrl.currentStage as LoadingState;
        if (stg) {
            stg.setOrder(1, arr[2]);
        }
    }

    private function onSelectFighterIndexFinish(arr:Array):void {
        if (MainGame.stageCtrl.currentStage is LoadingState) {
            (
                    MainGame.stageCtrl.currentStage as LoadingState
            ).gotoGame(arr[2], arr[3]);
        }
    }

    private function onSelectStep(e:GameEvent):void {
        var data:Array = [SelectFighterDataType.KEY, SelectFighterDataType.SELECT, e.param];
        LANClientCtrl.I.sendTCP(data);
    }

    private function onSelectIndex(e:GameEvent):void {
        var data:Array = [SelectFighterDataType.KEY, SelectFighterDataType.INDEX, e.param];
        LANClientCtrl.I.sendTCP(data);
    }

}
}
