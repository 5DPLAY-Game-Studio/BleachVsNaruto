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

/**
 * 无双对局的角色事件：连击、换人和敌人死亡。
 *
 * <p>必杀在这里用来换人，只处理 1 队。没有下一个存活角色时什么都不做。连击只统计 1 队打中角色的情况。敌人死透时，小兵等消散回调再移出，头目在这里直接结束，不走消散。</p>
 *
 * @see BaseFighterEventCtrl
 * @see MusouCtrl
 */
public class MusouFighterEventCtrl extends BaseFighterEventCtrl {

    /**
     * 在基类监听之外接上命中、敌人状态、换人和死亡。
     */
    public override function initialize():void {
        super.initialize();

        FighterEventDispatcher.addEventListener(FighterEvent.HIT_TARGET, onHitTarget);

        FighterEventDispatcher.addEventListener(FighterEvent.BIRTH, onEnemyEvent);
        FighterEventDispatcher.addEventListener(FighterEvent.HURT, onEnemyEvent);
        FighterEventDispatcher.addEventListener(FighterEvent.DEFENSE, onEnemyEvent);
        FighterEventDispatcher.addEventListener(FighterEvent.IDLE, onEnemyEvent);
        FighterEventDispatcher.addEventListener(FighterEvent.HURT_RESUME, onEnemyEvent);
        FighterEventDispatcher.addEventListener(FighterEvent.HURT_DOWN, onEnemyEvent);

        FighterEventDispatcher.addEventListener(FighterEvent.DO_SPECIAL, changeFighter);
        FighterEventDispatcher.addEventListener(FighterEvent.DIE, onDie);
        FighterEventDispatcher.addEventListener(FighterEvent.DEAD, onDead);
    }

    private function onEnemyBeHit(f:FighterMain):void {

        GameCtrl.I.getMusouCtrl().updateEnemy(f);
    }

    private function onEnemyBirth(f:FighterMain):void {
        if (f.musouEnemyData.isBoss) {
            GameCtrl.I.getMusouCtrl().onBossBirth(f);
        }
        GameCtrl.I.getMusouCtrl().updateEnemy(f);
    }

    private function onEnemyDead(f:FighterMain):void {
        GameCtrl.I.getMusouCtrl().gameRunData.koNum++;
        GameUI.I.updateMusouKONum();

        GameData.I.musouData.addMoney(f.musouEnemyData.getMoney());
        GameData.I.musouData.addFighterExp(f.musouEnemyData.getExp());

        if (f.musouEnemyData.isBoss) {
            GameCtrl.I.getMusouCtrl().onBossDead(f);
            GameUI.I.updateMusouBossHp();

            return;
        }

        EffectCtrl.I.removeEnemyEffect(f, function ():void {
            GameCtrl.I.getMusouCtrl().removeEnemy(f);
        });
    }

    private function changeNextFighter():Boolean {
        var group:GameRunFighterGroup = GameCtrl.I.gameRunData.p1FighterGroup;
        var nextFighter:FighterMain   = group.getNextAliveFighter();
        if (!nextFighter) {
            return false;
        }

        GameCtrl.I.getMusouCtrl().changeFighter(group.currentFighter, nextFighter);

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
        if (TeamID.TEAM_1 != fighter.team.id) {
            return;
        }

        MusouLogic.I.addHits(target as FighterMain);
    }

    private function onEnemyEvent(event:FighterEvent):void {
        var f:FighterMain = event.fighter as FighterMain;
        if (!f.musouEnemyData) {
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
        if (TeamID.TEAM_1 != fighter.team.id) {
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

        if (TeamID.TEAM_1 == fighter.team.id) {
            GameCtrl.I.getMusouCtrl().onSelfDie(fighter);
        }
        if (TeamID.TEAM_2 == fighter.team.id) {
            MusouLogic.I.removeHitTarget(fighter);

            var isBoss:Boolean = fighter.musouEnemyData && fighter.musouEnemyData.isBoss;
            if (isBoss) {
                GameCtrl.I.getMusouCtrl().onBossDie(fighter);
            }
        }
    }

    /**
     * 角色死透状态
     * @param e 角色事件
     */
    private function onDead(e:FighterEvent):void {
        var fighter:FighterMain = e.fighter as FighterMain;

        if (TeamID.TEAM_1 == fighter.team.id) {
            GameCtrl.I.getMusouCtrl().onSelfDead(fighter);
        }
        if (TeamID.TEAM_2 == fighter.team.id) {
            onEnemyDead(fighter);
        }
    }

}
}
