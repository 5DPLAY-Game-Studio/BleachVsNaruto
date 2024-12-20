/*
 * Copyright (C) 2021-2024, 5DPLAY Game Studio
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package net.play5d.game.bvn.ctrler.game_ctrls {
import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.data.GameRunFighterGroup;
import net.play5d.game.bvn.fighter.Assister;
import net.play5d.game.bvn.fighter.data.FighterActionState;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.events.FighterEvent;
import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IGameSprite;

public class FighterEventCtrl extends BaseFighterEventCtrl {
    include '../../../../../../../include/_INCLUDE_OVERRIDE_.as';

    public override function initlize():void {
        super.initlize();

        FighterEventDispatcher.addEventListener(FighterEvent.DO_SPECIAL, addAssister);

        FighterEventDispatcher.addEventListener(FighterEvent.HIT_TARGET, onHitTarget);
        FighterEventDispatcher.addEventListener(FighterEvent.HURT_RESUME, onHurtResume);
        FighterEventDispatcher.addEventListener(FighterEvent.DEAD, onDead);
        FighterEventDispatcher.addEventListener(FighterEvent.IDLE, onIdle);
        FighterEventDispatcher.addEventListener(FighterEvent.DIE, onDie);
    }

    private function removeAssister(assister:Assister):void {
        GameCtrl.I.removeGameSprite(assister);
    }

    //显示连击数字
    private function addHits(fighter:FighterMain, target:IGameSprite):void {
        var targetId:String = target && target is BaseGameSprite ? (
                target as BaseGameSprite
        ).id : null;
        //			var hitsObj:Object = GameLogic.getHitsObj(fighter.id);
        //			var uiId:int = 1;
        //			if(hitsObj && hitsObj.uiID){
        //				uiId = hitsObj.uiID;
        //			}else{
        //				if(fighter.getDisplay() && target.getDisplay()){
        //					uiId = fighter.getDisplay().x > target.getDisplay().x ? 2 : 1;
        //				}
        //			}

        var uiId:int = 1;
        switch (fighter.team.id) {
        case 1:
            uiId = 1;
            break;
        case 2:
            uiId = 2;
            break;
        }

        var hits:int = GameLogic.addHits(fighter.id, targetId, uiId);
        if (hits > 1) {
            GameCtrl.I.gameState.gameUI.getUI().showHits(hits, uiId);
        }
    }

    //清除连击数字
    private function removeHits(targetId:String):void {
//			trace('removeHits', targetId);
        var o:Object = GameLogic.getHitsObjByTargetId(targetId);
        if (o) {
            GameCtrl.I.gameState.gameUI.getUI().hideHits(o.uiID);
        }
        GameLogic.clearHitsByTargetId(targetId);
    }

    private function addAssister(event:FighterEvent):void {
        var fighter:FighterMain = event.fighter as FighterMain;
        if (fighter.actionState != FighterActionState.NORMAL && fighter.actionState !=
            FighterActionState.DEFENCE_ING) {
            return;
        }
        if (fighter.fzqi < fighter.fzqiMax) {
            return;
        }

        fighter.fzqi = 0;

        var group:GameRunFighterGroup = fighter.team.id == 1 ? GameCtrl.I.gameRunData.p1FighterGroup :
                                        GameCtrl.I.gameRunData.p2FighterGroup;
        var fz:Assister               = group.currentAssister;
        fz.setOwner(fighter);
        fz.direct   = fighter.direct;
        fz.x        = fighter.x - 30 * fz.direct;
        fz.y        = fighter.y;
        fz.onRemove = removeAssister;
        GameCtrl.I.addGameSprite(event.fighter.team.id, fz);
        EffectCtrl.I.assisterEffect(fz);
        fz.goFight();
    }

    //攻击到目标事件
    private function onHitTarget(e:FighterEvent):void {
//			trace("onHitTarget");
        addHits(e.fighter as FighterMain, e.params.target);
        if (GameMode.isAcrade() && e.fighter.team.id == 1) {
            GameLogic.addScoreByHitTarget(e.params.hitvo);
        }
    }

    //角色受击恢复事件
    private function onHurtResume(e:FighterEvent):void {
        removeHits(e.fighter.id);
    }

    private function onDead(e:FighterEvent):void {
        removeHits(e.fighter.id);
    }

    //角色倒地事件
    private function onIdle(e:FighterEvent):void {
        removeHits(e.fighter.id);
    }

    private function onDie(e:FighterEvent):void {
        GameCtrl.I.onFighterDie(e.fighter as FighterMain);
    }

}
}
