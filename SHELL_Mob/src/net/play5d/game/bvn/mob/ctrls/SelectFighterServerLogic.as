package net.play5d.game.bvn.mob.ctrls {
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.mob.utils.SelectFighterDataType;

public class SelectFighterServerLogic {

    public function SelectFighterServerLogic() {
    }
    private var _timeout:int;

    public function init():void {

        SelectFighterStage.AUTO_FINISH = false;
        LoadingState.AUTO_START_GAME   = false;

        GameEvent.addEventListener(GameEvent.SELECT_FIGHTER_STEP, onSelectStep);
        GameEvent.addEventListener(GameEvent.SELECT_FIGHTER_FINISH, onSelectFinish);
        GameEvent.addEventListener(GameEvent.SELECT_FIGHTER_INDEX, onSelectFighterIndex);
    }

    public function dispose():void {
        GameEvent.removeEventListener(GameEvent.SELECT_FIGHTER_STEP, onSelectStep);
        GameEvent.removeEventListener(GameEvent.SELECT_FIGHTER_FINISH, onSelectFinish);
        GameEvent.removeEventListener(GameEvent.SELECT_FIGHTER_INDEX, onSelectFighterIndex);
    }

    public function receiveSelect(data:Object):Boolean {
        var arr:Array = data as Array;
        if (!arr || arr[0] != SelectFighterDataType.KEY) {
            return false;
        }

        var type:int = data[1];

        switch (type) {
        case SelectFighterDataType.SELECT:
            try {
                var stg:SelectFighterStage = MainGame.stageCtrl.currentStage as SelectFighterStage;
                stg.setSelect(2, arr[2]);
                checkSelectFinish();
            }
            catch (e:Error) {
            }
            break;
        case SelectFighterDataType.INDEX:
            try {
                var stg2:LoadingState = MainGame.stageCtrl.currentStage as LoadingState;
                stg2.setOrder(2, data[2]);
                checkSelectIndexFinish();
            }
            catch (e:Error) {
            }
            break;
        }

        return true;
    }

    private function checkSelectFinish():void {
//			try{
        var stg:SelectFighterStage = MainGame.stageCtrl.currentStage as SelectFighterStage;
        if (stg.p1SelectFinish && stg.p2SelectFinish) {
            clearTimeout(_timeout);
            _timeout = setTimeout(function ():void {
                LANServerCtrl.I.sendTCP([SelectFighterDataType.KEY, SelectFighterDataType.NEXT_STEP]);
                stg.nextStep();
            }, 1000);
        }
//			}catch(e:Error){}
    }

    private function checkSelectIndexFinish():void {
        try {
            var stg:LoadingState = MainGame.stageCtrl.currentStage as LoadingState;
            if (stg.selectFinish()) {
                setTimeout(function ():void {

                    var orders:Array = stg.getSort();

                    LANServerCtrl.I.sendTCP(
                            [SelectFighterDataType.KEY, SelectFighterDataType.INDEX_FINISH, orders[0], orders[1]]);
                    stg.gotoGame(orders[0], orders[1]);
                }, 1000);
            }
        }
        catch (e:Error) {
        }
    }

    private function onSelectStep(e:GameEvent):void {
        var data:Array = [SelectFighterDataType.KEY, SelectFighterDataType.SELECT, e.param];
        LANServerCtrl.I.sendTCP(data);
        checkSelectFinish();
    }

    private function onSelectFinish(e:GameEvent):void {
        var data:Array = [
            SelectFighterDataType.KEY, SelectFighterDataType.FIGHTER_FINISH,
            GameData.I.p1Select.fighter1, GameData.I.p1Select.fighter2, GameData.I.p1Select.fighter3,
            GameData.I.p1Select.fuzhu,
            GameData.I.p2Select.fighter1, GameData.I.p2Select.fighter2, GameData.I.p2Select.fighter3,
            GameData.I.p2Select.fuzhu,
            GameData.I.selectMap
        ];
        LANServerCtrl.I.sendTCP(data);

//			try{
        var stg:SelectFighterStage = MainGame.stageCtrl.currentStage as SelectFighterStage;
        stg.goLoadGame();
//			}catch(e:Error){}

    }

    private function onSelectFighterIndex(e:GameEvent):void {
        var data:Array = [SelectFighterDataType.KEY, SelectFighterDataType.INDEX, e.param];
        LANServerCtrl.I.sendTCP(data);

        checkSelectIndexFinish();
    }


}
}
