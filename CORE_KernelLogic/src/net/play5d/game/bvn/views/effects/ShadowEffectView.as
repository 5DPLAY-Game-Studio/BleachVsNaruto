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
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;

	import net.play5d.kyo.utils.KyoUtils;

	public class ShadowEffectView
	{
		include '../../../../../../../include/_INCLUDE_.as';

		public var target:DisplayObject;
		public var r:int = 0;
		public var g:int = 0;
		public var b:int = 0;

		public var container:Sprite;

		private var _bps:Vector.<Bitmap> = new Vector.<Bitmap>();
		private var _alphaLose:Number = 0.1;
		private var _alphaStart:Number = 0.8;
		private var _addBpGap:int = 1;
		private var _addBpFrame:int = 0;

		public var stopShadow:Boolean;
		public var onRemove:Function;

		public function ShadowEffectView(target:DisplayObject , r:int = 0 , g:int = 0 , b:int = 0)
		{
			this.target = target;
			this.r = r;
			this.g = g;
			this.b = b;

			_addBpFrame = 0;
		}

		public function destory():void{
			target = null;
			for(var i:int ; i < _bps.length ; i++){
				var bp:Bitmap = _bps[i];
				bp.bitmapData.dispose();
				try
				{
					container.removeChild(bp);
				}
				catch(error:Error)
				{

				}
			}
			_bps = null;
		}

		public function render():void{

			if(stopShadow){
				if(_bps.length <= 0) removeSelf();
			}else{
				if(_addBpFrame++ > _addBpGap){
					addShadowBp();
					_addBpFrame = 0;
				}
			}

			for(var i:int ; i < _bps.length ; i++){
				var bp:Bitmap = _bps[i];
				bp.alpha -= _alphaLose;
				if(bp.alpha <= 0){
					removeBitmap(bp);
				}
			}

		}

		private function addShadowBp():void{
			var ct:ColorTransform;
			if(r != 0 || g != 0 || b != 0){
				ct = new ColorTransform();
				ct.redOffset = r;
				ct.greenOffset = g;
				ct.blueOffset = b;
			}

			var bds:Rectangle = target.getBounds(target);
			var bp:Bitmap = KyoUtils.drawDisplay(target,true,true,0,ct);
			if(bp == null) return;
			bp.alpha = _alphaStart;
			bp.x = target.x + bds.x * target.scaleX;
			bp.y = target.y + bds.y;
			bp.scaleX = target.scaleX;
			bp.scaleY = target.scaleY;
			container.addChildAt(bp,0);
			_bps.push(bp);

		}

		private function removeBitmap(bp:Bitmap):void{
			var id:int = _bps.indexOf(bp);
			if(id != -1) _bps.splice(id,1);

			try{
				container.removeChild(bp);
			}catch(e:Error){}

			bp.bitmapData.dispose();
		}

		private function removeSelf():void{
			if(onRemove != null) onRemove(this);
		}

	}
}
