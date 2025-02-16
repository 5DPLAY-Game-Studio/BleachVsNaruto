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
import net.play5d.game.bvn.fighter.Bullet;
import net.play5d.game.bvn.fighter.FighterAttacker;
import net.play5d.game.bvn.fighter.events.FighterEvent;
import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
import net.play5d.game.bvn.views.effects.FollowEffectView;

public class BaseFighterEventCtrl {
    include '../../../../../../../include/_INCLUDE_.as';

    public function BaseFighterEventCtrl() {
    }
    private var _attackers:Array = [];

    public function initlize():void {
        FighterEventDispatcher.removeAllListeners();

        FighterEventDispatcher.addEventListener(FighterEvent.FIRE_BULLET, fireBullet);
        FighterEventDispatcher.addEventListener(FighterEvent.ADD_ATTACKER, addAttacker);
        FighterEventDispatcher.addEventListener(FighterEvent.ADD_EFFECT, addFollowEffect);
    }

    public function getAttacker(name:String, team:int):FighterAttacker {
        for each(var i:FighterAttacker in _attackers) {
            if (i.name == name && i.team.id == team) {
                return i;
            }
        }
        return null;
    }

    public function destory():void {
        FighterEventDispatcher.removeAllListeners();
    }

    /**
     * 移除子弹 , 通过bullet.onRemove传入
     */
    private function removeBullet(bullet:Bullet):void {
        GameCtrl.I.removeGameSprite(bullet);
    }

    private function removeAttacker(attacker:FighterAttacker):void {
        GameCtrl.I.removeGameSprite(attacker);
        var id:int = _attackers.indexOf(attacker);
        if (id != -1) {
            _attackers.splice(id, 1);
        }
    }

    /**
     * 移除效果
     * @param effect 角色特效元件
     */
    private function removeEffect(effect:FollowEffectView):void {
        GameCtrl.I.removeGameSprite(effect);
    }

    /**
     * 发射子弹 ，通过事件帧听
     */
    private function fireBullet(event:FighterEvent):void {
        var params:Object = event.params;
        if (!params || !params.mc) {
            return;
        }

        var bullet:Bullet = new Bullet(params.mc, params);
        bullet.onRemove   = removeBullet;
        bullet.setHitVO(params.hitVO);

        GameCtrl.I.addGameSprite(event.fighter.team.id, bullet);
    }

    private function addAttacker(event:FighterEvent):void {
        var params:Object = event.params;
        if (!params || !params.mc) {
            return;
        }

        var attacker:FighterAttacker = new FighterAttacker(params.mc, params);
        attacker.onRemove            = removeAttacker;
        attacker.setOwner(event.fighter);
        attacker.init();

        _attackers.push(attacker);

        GameCtrl.I.addGameSprite(event.fighter.team.id, attacker);
    }

    /**
     * 增加跟随效果视图
     * @param event 事件
     */
    private function addFollowEffect(event:FighterEvent):void {
        var params:Object = event.params;
        if (!params || !params.mc) {
            return;
        }

        var effect:FollowEffectView = new FollowEffectView(params.mc);
        effect.onRemove   = removeEffect;
        effect.setTarget(event.fighter);

        var isUnderBody:Boolean = params.isUnderBody;
        GameCtrl.I.addGameSprite(event.fighter.team.id, effect, isUnderBody ? 0 : -1);
    }

}
}
