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
import flash.geom.Rectangle;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.data.TeamMap;
import net.play5d.game.bvn.data.vos.TeamVO;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.map.MapMain;
import net.play5d.game.bvn.stage.GameStage;

/**
 * 游戏主逻辑控制类
 */
public class GameMainLogicCtrler {

    public function GameMainLogicCtrler() {
    }
    public var renderHit:Boolean = true;

    /** @private 身体重叠粗测距离（像素） */
    private static const BODY_SKIP_DIST:Number = 200;
    /** @private 攻击判定粗测距离（像素） */
    private static const HIT_SKIP_DIST:Number  = 600;

    /** @private */
    private var _bodyHitRect:Rectangle = new Rectangle();
    /** @private */
    private var _hitRectA:Rectangle    = new Rectangle();
    /** @private */
    private var _hitRectB:Rectangle    = new Rectangle();
    /** @private getVec 复用 */
    private var _vecOut:Object         = {A: 0, B: 0};
    /** @private */
    private var _hitResultA:Object     = {hitVO: null, hitRect: null};
    /** @private */
    private var _hitResultB:Object     = {hitVO: null, hitRect: null};
    private var _gameState:GameStage;
    private var _leftSide:Number  = 0;
    private var _rightSide:Number = 0;
    private var _teamMap:TeamMap;
    private var _renderAnimate:Boolean;

    public function initlize(gameState:GameStage, teamMap:TeamMap):void {
        _gameState = gameState;
        _teamMap   = teamMap;

        var map:MapMain = gameState.getMap();

        _leftSide  = map.left + GameConfig.X_SIDE_OFFSET;
        _rightSide = map.right - GameConfig.X_SIDE_OFFSET;
    }

    public function setSpeedPlus(v:Number):void {
        GameConfig.SPEED_PLUS = v;
        var i:int, team:TeamVO;
        var l:int             = _teamMap.teams.length;
        var j:int, cl:int, sp:IGameSprite;

        for (i = 0; i < l; i++) {
            team = _teamMap.teams[i];
            cl   = team.children.length;
            for (j = 0; j < cl; j++) {
                sp = team.children[j];
                if (sp && !sp.isDestroyed()) {
                    sp.setSpeedRate(v);
                }
            }
        }

    }

    public function destroy():void {

    }

    public function render():void {
        renderMainLogic();
    }

    public function renderAnimate():void {
        _renderAnimate = true;
    }

    /**
     * 暂停时，需要运行的
     *
     */
    public function renderPause():void {

    }

    /**
     * 游戏主逻辑
     */
    private function renderMainLogic():void {

        var teams:Vector.<TeamVO>         = _teamMap.teams;
        var i:int, j:int, k:int, l:int;
        var sp:IGameSprite, sp2:IGameSprite;
        var team:TeamVO, team2:TeamVO;
        var children:Vector.<IGameSprite>, children2:Vector.<IGameSprite>;
        var teamLen:int                   = teams.length;
        var childLen:int;
        var displays:Vector.<IGameSprite> = _gameState.getGameSprites();

        //			if(_renderAnimate) gameState.renderAnimate();


        for (i = 0; i < displays.length; i++) {
            renderGameSprite(displays[i]);
        }


        for (i = 0; i < teamLen; i++) {

            team     = teams[i];
            children = team.children;
            for (j = 0; j < children.length; j++) {

                sp = children[j];

                if (sp == null || sp.isDestroyed()) {
                    continue;
                }

//					renderGameSprite(sp);


                //两两匹配，比如有3个：1与2,3比较，2与3比较
                for (k = i + 1; k < teamLen; k++) {

                    team2     = teams[k];
                    children2 = team2.children;
                    childLen  = children2.length;

                    for (l = 0; l < childLen; l++) {
                        sp2 = children2[l];

                        if (sp2 == null || sp2.isDestroyed()) {
                            continue;
                        }

                        if (!farApart(sp, sp2, BODY_SKIP_DIST)) {
                            checkBodyHit(sp, sp2);
                        }
                        if (_renderAnimate && !farApart(sp, sp2, HIT_SKIP_DIST)) {
                            checkHit(sp, sp2);
                        }
                    }

                }


            }

        }

        _renderAnimate = false;

    }

    //身体之间的碰撞处理
    private function checkBodyHit(A:IGameSprite, B:IGameSprite):void {

        if (!renderHit) {
            return;
        }

        if (!(
                A is BaseGameSprite
        )) {
            return;
        }
        if (!(
                B is BaseGameSprite
        )) {
            return;
        }

        var ba:BaseGameSprite = A as BaseGameSprite;
        var bb:BaseGameSprite = B as BaseGameSprite;

        if (ba.isCross || bb.isCross) {
            return;
        }

        var bodyA:Rectangle = A.getBodyArea();
        var bodyB:Rectangle = B.getBodyArea();

        if (bodyA == null) {
            return;
        }
        if (bodyB == null) {
            return;
        }

        if (!intersectInto(bodyA, bodyB, _bodyHitRect) || _bodyHitRect.isEmpty()) {
            return;
        }

//			var displayA:DisplayObject = A.getDisplay();
//			var displayB:DisplayObject = B.getDisplay();

        var vecA:Number = ba.getVecX();
        var vecB:Number = bb.getVecX();

        var overVec:Object;

        if (ba.x < bb.x) {
            if ((
                        vecA < 0 && vecA < vecB
                ) || (
                        vecB > 0 && vecB > vecA
                )) {
                return;
            }
            if (_bodyHitRect.width > 2) {
                overVec ||= fillVec(5 * GameConfig.SPEED_PLUS, ba, bb);
                ba.move(-overVec.A);
                bb.move(overVec.B);
            }
        }
        else {
            if ((
                        vecA > 0 && vecA > vecB
                ) || (
                        vecB < 0 && vecB < vecA
                )) {
                return;
            }
            if (_bodyHitRect.width > 2) {
                overVec ||= fillVec(5 * GameConfig.SPEED_PLUS, ba, bb);
                ba.move(overVec.A);
                bb.move(-overVec.B);
            }
        }

        if (vecA != 0) {
            var vo:Object = fillVec(vecA, ba, bb);
            bb.move(vo.B);
            ba.move(-vo.A);
        }

        if (vecB != 0) {
            var vo2:Object = fillVec(vecB, ba, bb);
            ba.move(vo2.A);
            bb.move(-vo2.B);
        }

    }

    /**
     * @private 按双方重量分配位移量，写入复用对象。
     */
    private function fillVec(vec:Number, ba:BaseGameSprite, bb:BaseGameSprite):Object {
        var rate:Number = (
                                  bb.heavy / ba.heavy
                          ) * 0.5;
        if (rate > 0.9) {
            rate = 0.9;
        }
        if (rate < 0.1) {
            rate = 0.1;
        }

        var vecA:Number = vec * rate;
        var vecB:Number = vec * (
                1 - rate
        );

        if (ba.getIsTouchSide() && bb.getIsTouchSide()) {
            vecA = vec;
            vecB = vec;
        }
        else if (ba.getIsTouchSide()) {
            vecA = 0;
            vecB = vec;
        }
        else if (bb.getIsTouchSide()) {
            vecB = 0;
            vecA = vec;
        }

        _vecOut.A = vecA;
        _vecOut.B = vecB;
        return _vecOut;
    }

    //运行游戏元件
    private function renderGameSprite(sp:IGameSprite):void {
        try {
            GameLogic.fixGameSpritePosition(sp);

            if (sp is BaseGameSprite) {
                var bsp:BaseGameSprite = sp as BaseGameSprite;
                var inAir:Boolean      = GameLogic.isInAir(bsp);
                if (inAir) {
                    bsp.applayG(GameConfig.G);
                }
                bsp.setInAir(inAir);
            }

            sp.render();
            if (_renderAnimate && !sp.isDestroyed()) {
                sp.renderAnimate();
            }
        }
        catch (e:Error) {
            Debugger.log(GetLang('debug.log.data.game_main_logic_ctrler.render_game_sprite', {error: e}));
        }

    }

    //攻击碰撞检测
    private function checkHit(A:IGameSprite, B:IGameSprite):void {

        if (!renderHit) {
            return;
        }

        var hitsA:Array = A.getCurrentHits();
        var hitsB:Array = B.getCurrentHits();

        var bodyA:Rectangle;
        var bodyB:Rectangle;

        if (A is BaseGameSprite && !(
                A as BaseGameSprite
        ).isAllowBeHit) {
            bodyA = null;
        }
        else {
            bodyA = A.getBodyArea();
        }

        if (B is BaseGameSprite && !(
                B as BaseGameSprite
        ).isAllowBeHit) {
            bodyB = null;
        }
        else {
            bodyB = B.getBodyArea();
        }

        if (Debugger.DRAW_AREA) {
            if (bodyA) {
                _gameState.drawGameRect(bodyA, 0xffff00, 0.5);
            }
            if (bodyB) {
                _gameState.drawGameRect(bodyB, 0xffff00, 0.5);
            }
//				if(A is FighterMain){
//					var ckhitA:Rectangle = (A as FighterMain).getHitRange(FighterHitRange.ATTACK);
//					if(ckhitA) _gameState.drawGameRect(ckhitA , 0x00ff00 , 0.5);
//				}
//				if(B is FighterMain){
//					var ckhitB:Rectangle = (B as FighterMain).getHitRange(FighterHitRange.ATTACK);
//					if(ckhitB) _gameState.drawGameRect(ckhitB , 0x00ff00 , 0.5);
//				}

        }

        var AhitB:Object = getHitObj(hitsA, bodyB, _hitResultA, _hitRectA);
        var BhitA:Object = getHitObj(hitsB, bodyA, _hitResultB, _hitRectB);

        if (AhitB) {
            B.beHit(AhitB.hitVO, AhitB.hitRect);
            A.hit(AhitB.hitVO, B);
            if (Debugger.DRAW_AREA) {
                _gameState.drawGameRect(AhitB.hitRect, 0xffffff, 1);
            }
        }

        if (BhitA) {
            A.beHit(BhitA.hitVO, BhitA.hitRect);
            B.hit(BhitA.hitVO, A);
            if (Debugger.DRAW_AREA) {
                _gameState.drawGameRect(BhitA.hitRect, 0xffffff, 1);
            }
        }

    }

    /**
     * 获取攻击到角色的区域
     * @param hitArray 攻击数组[FighterHitVO]
     * @param body 被攻击的角色区域
     * @param out 复用结果 { hitVO , hitRect }
     * @param hitRectOut 复用相交矩形
     * return { hitVO:FighterHitVO , hitRect:Rectangle } 或 null
     */
    private function getHitObj(
            hitArray:Array, body:Rectangle, out:Object, hitRectOut:Rectangle
    ):Object {
        if (!body) {
            return null;
        }
        if (!hitArray || hitArray.length < 1) {
            return null;
        }

        var i:int;
        var hitLen:int = hitArray.length;
        var hitvo:HitVO;
        var hitArea:Rectangle;

        for (i = 0; i < hitLen; i++) {
            hitvo = hitArray[i];
            if (hitvo == null) {
                continue;
            }

            hitArea = hitvo.currentArea;
            if (hitArea == null) {
                continue;
            }

            if (Debugger.DRAW_AREA) {
                _gameState.drawGameRect(hitArea);
            }

            if (intersectInto(hitArea, body, hitRectOut) && !hitRectOut.isEmpty()) {
                out.hitVO   = hitvo;
                out.hitRect = hitRectOut;
                return out;
            }
        }

        return null;
    }

    /**
     * @private 粗测：双方锚点距离是否超出阈值，超出则可跳过细测。
     */
    private static function farApart(A:IGameSprite, B:IGameSprite, maxDist:Number):Boolean {
        var dx:Number = A.x - B.x;
        if (dx > maxDist || dx < -maxDist) {
            return true;
        }
        var dy:Number = A.y - B.y;
        return dy > maxDist || dy < -maxDist;
    }

    /**
     * @private 将 a∩b 写入 out，避免 Rectangle.intersection 分配。
     * @return 有交集时为 <code>true</code>。
     */
    private static function intersectInto(a:Rectangle, b:Rectangle, out:Rectangle):Boolean {
        var x:Number = a.x > b.x ? a.x : b.x;
        var y:Number = a.y > b.y ? a.y : b.y;
        var r:Number = a.right < b.right ? a.right : b.right;
        var bot:Number = a.bottom < b.bottom ? a.bottom : b.bottom;
        if (r <= x || bot <= y) {
            out.setTo(0, 0, 0, 0);
            return false;
        }
        out.setTo(x, y, r - x, bot - y);
        return true;
    }

}
}
