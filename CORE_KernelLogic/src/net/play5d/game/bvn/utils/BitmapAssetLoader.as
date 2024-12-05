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

package net.play5d.game.bvn.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;

	import net.play5d.game.bvn.cntlr.AssetManager;

	public class BitmapAssetLoader
	{
		include '../../../../../../include/_INCLUDE_.as';

		private var _queueLength:int;
		private var _urls:Array;
		private var _cacheObj:Object = {};
		private var _successBack:Function;
		private var _processBack:Function;

		public function getBitmap(id:String):Bitmap{
//			var r:DisplayObject = _cacheObj[id];
//
//			if(r == null) return null;
//
//			if(r is BitmapData){
//				return new Bitmap(r as BitmapData);
//			}

			var bd:BitmapData = _cacheObj[id];
			if(bd == null) return null;
			return new Bitmap(bd);
		}

		public function loadQueue(urls:Array , success:Function , process:Function = null):void{
			_successBack = success;
			_processBack = process;

			_urls = urls.concat();
			_queueLength = urls.length;
			loadNext();
		}

		private function load(url:String , back:Function = null , process:Function = null):void{
			AssetManager.I.loadBitmap(url , loadCom , loadFail , process);

			function loadCom(bp:DisplayObject):void{
				cacheBitmap(url , bp);
				if(back != null) back();
			}

			function loadFail():void{
				trace("BitmapAssetLoader.loadFail ::", url);
				if(back != null) back();
			}

		}

		private function cacheBitmap(id:String , bp:DisplayObject):void{
			var content:Bitmap = bp as Bitmap;

			if(!content){
				trace("BitmapAssetLoader.cacheBitmap Error");
				return;
			}

			var cache:BitmapData;

			if(content){
				try{
					cache = content.bitmapData;
				}catch(e:Error){
					trace("BitmapAssetLoader.cacheBitmap::",e);
//					cache = content;
				}
			}else{
//				cache = loader;
			}

			if(cache){
				_cacheObj[id] = cache;
			}

			AssetManager.I.disposeAsset(id);

		}

		private function loadNext():void{
			if(_urls.length < 1){
				if(_successBack != null){
					_successBack();
					_successBack = null;
				}
				return;
			}
			var url:String = _urls.shift();
			load(url , loadNext, loadProcess);

			function loadProcess(v:Number):void{
				if(_processBack != null){
					var cur:Number = _queueLength - _urls.length-1 + v;
					var p:Number = cur / _queueLength;
					_processBack(p);
				}
			}

		}

	}
}
