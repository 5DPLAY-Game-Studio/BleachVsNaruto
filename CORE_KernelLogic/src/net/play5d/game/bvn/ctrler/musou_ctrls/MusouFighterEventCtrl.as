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

package net.play5d.game.bvn.ctrler.musou_ctrls {
import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.BaseFighterEventCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameRunFighterGroup;
import net.play5d.game.bvn.data.TeamID;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.events.FighterEvent;
import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.ui.musou.MosouUI;

public class MusouFighterEventCtrl extends BaseFighterEventCtrl {
    include '../../../../../../../include/_INCLUDE_OVERRIDE_.as';

    public override function initlize():void {
        super.initlize();

        FighterEventDispatcher.addEventListener(FighterEvent.HIT_TARGET, onHitTarget);

        FighterEventDispatcher.addEventListener(FighterEvent.BIRTH, onEnemyEvent);
        FighterEventDispatcher.addEventListener(FighterEvent.HURT, onEnemyEvent);
        FighterEventDispatcher.addEventListener(FighterEvent.DEFENSE, onEnemyEvent);
//			FighterEventDispatcher.addEventListener(FighterEvent.DEAD, onEnemyEvent);
        FighterEventDispatcher.addEventListener(FighterEvent.IDLE, onEnemyEvent);
        FighterEventDispatcher.addEventListener(FighterEvent.HURT_RESUME, onEnemyEvent);
        FighterEventDispatcher.addEventListener(FighterEvent.HURT_DOWN, onEnemyEvent);

        FighterEventDispatcher.addEventListener(FighterEvent.DO_SPECIAL, changeFighter);
//			FighterEventDispatcher.addEventListener(FighterEvent.IDLE,onIdle);
        FighterEventDispatcher.addEventListener(FighterEvent.DIE, onDie);
        FighterEventDispatcher.addEventListener(FighterEvent.DEAD, onDead);
    }

    private function onEnemyBeHit(f:FighterMain):void {
//			var ui:MosouUI = GameUI.I.getUI() as MosouUI;
//			if(ui) ui.updateEnemyHp(f);

        GameCtrl.I.getMosouCtrl().updateEnemy(f);
    }

    private function onEnemyBirth(f:FighterMain):void {
        if (f.mosouEnemyData.isBoss) {
            GameCtrl.I.getMosouCtrl().onBossBirth(f);
        }
        GameCtrl.I.getMosouCtrl().updateEnemy(f);
    }

    private function onEnemyDead(f:FighterMain):void {
        GameCtrl.I.getMosouCtrl().gameRunData.koNum++;
        (
                GameUI.I.getUI() as MosouUI
        ).updateKONum();

        GameData.I.mosouData.addMoney(f.mosouEnemyData.getMoney());
        GameData.I.mosouData.addFighterExp(f.mosouEnemyData.getExp());

        if (f.mosouEnemyData.isBoss) {
            GameCtrl.I.getMosouCtrl().onBossDead(f);

            var ui:MosouUI = GameUI.I.getUI() as MosouUI;
            if (ui) {
                ui.updateBossHp();
            }

            return;
        }

        EffectCtrl.I.removeEnemyEffect(f, function ():void {
            GameCtrl.I.getMosouCtrl().removeEnemy(f);
        });
    }

    private function changeNextFighter():Boolean {
        var group:GameRunFighterGroup = GameCtrl.I.gameRunData.p1FighterGroup;
        var nextFighter:FighterMain   = group.getNextAliveFighter();
        if (!nextFighter) {
            return false;
        }

        GameCtrl.I.getMosouCtrl().changeFighter(group.currentFighter, nextFighter);

        return true;
    }

    /**
     * 增加显示连击数字
     * @param fighter 角色
     * @param target 目标
     */
    private function addHits(fighter:FighterMain, target:IGameSprite):void {
        if (!(target is FighterMain)) {
            return;
        }
        if (!TeamID.isTeam1(fighter)) {
            return;
        }

        MusouLogic.I.addHits(target as FighterMain);
    }

    private function onEnemyEvent(event:FighterEvent):void {
        var f:FighterMain = event.fighter as FighterMain;
        if (!f.mosouEnemyData) {
            return;
        }

        switch (event.type) {
        case FighterEvent.BIRTH:
            onEnemyBirth(f);
            break;
        case FighterEvent.HURT:
        case FighterEvent.DEFENSE:
            onEnemyBeHit(f);
            break;
//				case FighterEvent.DEAD:
//					MusouLogic.I.removeHitTarget(f);
//					onEnemyDead(f);
//					break;
        case FighterEvent.IDLE:
        case FighterEvent.HURT_RESUME:
        case FighterEvent.HURT_DOWN:
            MusouLogic.I.removeHitTarget(f);
            break;
        }
    }

    private function onHitTarget(e:FighterEvent):void {
        addHits(e.fighter as FighterMain, e.params.target);
    }

    /**
     * 改变角色事件
     * @param e 角色事件
     */
    private function changeFighter(e:FighterEvent):void {
        var fighter:FighterMain = e.fighter as FighterMain;
        if (!TeamID.isTeam1(fighter)) {
            return;
        }

        changeNextFighter();
    }

    /**
     * 角色死亡事件
     * @param e 角色事件
     */
    private function onDie(e:FighterEvent):void {
        var fighter:FighterMain = e.fighter as FighterMain;

        if (TeamID.isTeam1(fighter)) {
            GameCtrl.I.getMosouCtrl().onSelfDie(fighter);
        }
        if (TeamID.isTeam2(fighter)) {
            MusouLogic.I.removeHitTarget(fighter);

            var isBoss:Boolean = fighter.mosouEnemyData && fighter.mosouEnemyData.isBoss;
            if (isBoss) {
                GameCtrl.I.getMosouCtrl().onBossDie(fighter);
            }
        }
    }

    /**
     * 角色死透状态
     * @param e 角色事件
     */
    private function onDead(e:FighterEvent):void {
        var fighter:FighterMain = e.fighter as FighterMain;

        if (TeamID.isTeam1(fighter)) {
            GameCtrl.I.getMosouCtrl().onSelfDead(fighter);
        }
        if (TeamID.isTeam2(fighter)) {
//            MosouLogic.I.removeHitTarget(fighter);
            onEnemyDead(fighter);
        }
    }

}
}
