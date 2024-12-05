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

package net.play5d.game.bvn.views.effects
{
	import flash.geom.ColorTransform;

	import net.play5d.game.bvn.data.EffectVO;
	import net.play5d.game.bvn.fighter.data.FighterActionState;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.interfaces.IGameSprite;

	/**
	 * 火、冰、雷 击中后续效果
	 */
	public class SpecialEffectView extends EffectView
	{
		include '../../../../../../../include/_INCLUDE_OVERRIDE_.as';

		private var _fighter:FighterMain;
		private var _finished:Boolean;

		public function SpecialEffectView(data:EffectVO)
		{
			super(data);
		}

		public override function setTarget(v:IGameSprite):void{
			super.setTarget(v);

			if(v is FighterMain){
				_fighter = v as FighterMain;
				if(_data.targetColorOffset){
					var ct:ColorTransform = new ColorTransform();
					ct.redOffset = _data.targetColorOffset[0];
					ct.greenOffset = _data.targetColorOffset[1];
					ct.blueOffset = _data.targetColorOffset[2];
					_fighter.changeColor(ct);
				}
			}
		}

		public override function start(x:Number=0, y:Number=0, direct:int=1, playSound:Boolean = true):void{
			super.start(x, y, direct, playSound);
			_finished = false;
		}

		public override function render():void{
			super.render();

			if(_finished) return;
			if(!_fighter) return;

			switch(_fighter.actionState){
				case FighterActionState.HURT_DOWN:
				case FighterActionState.HURT_DOWN_TAN:
				case FighterActionState.NORMAL:
					gotoAndPlay("finish");
					_finished = true;
					if(_data.targetColorOffset) _fighter.resumeColor();
					break;
				default:
					setPos(_fighter.x , _fighter.y);
			}

		}

	}
}
