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

package net.play5d.kyo.display.ui.ppt
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	import net.play5d.kyo.SuperPlayer;

	public class PicLoaderSp extends Sprite
	{
		private var _player:SuperPlayer;
		private var _size:Point;
		private var _url:String;
		public var onFinish:Function;
		public var isBitmap:Boolean;

		public function PicLoaderSp(size:Point)
		{
			this._size = size;
		}

		public function initlize(v:String):void{
			_url = v;
			var pfx:String = getPrefix(v);
			var pa:Array = ['jpg','jpeg','gif','png'];
			isBitmap = pa.indexOf(pfx) != -1;
		}

		private function getPrefix(v:String):String{
			var x:int = v.indexOf('.');
			var pf:String = v.substr(x+1);
			return pf.toLocaleLowerCase();
		}

		public final function unload():void{
			removeLoader();
		}

		public final function destory():void{
			removeLoader();
		}

		public final function load(back:Function = null , isCurrent:Boolean = false):void{
			if(!_url){
				trace('PicLoader : url is null!');
				return;
			}
			removeLoader();
			loadurl(_url,back,isCurrent);
		}

		public function finish():Boolean{
			if(_player && _player.type == SuperPlayer.TYPE_VIDEO){
				return _player.videoPlaying == false;
			}
			return true;
		}

		private function loadurl(url:String , back:Function , isCurrent:Boolean):void{
			if(!isCurrent){
				if(isBitmap){
					graphics.beginFill(0,1);
					graphics.drawRect(0,0,_size.x,_size.y);
					graphics.endFill();

					if(back != null) back();
					return;
				}
			}


			_player = new SuperPlayer(_size.x,_size.y);
			_player.addEventListener(SuperPlayer.EVENT_LOAD_COMPLETE,loadBack);
			_player.addEventListener(SuperPlayer.EVENT_LOAD_FAIL,loadBack);
			_player.addEventListener(SuperPlayer.EVENT_PLAY_COMPLETE,playBack);
			_player.play(url);
			addChild(_player);

			function loadBack(e:Event):void{
				_player.removeEventListener(SuperPlayer.EVENT_LOAD_COMPLETE,loadBack);
				_player.removeEventListener(SuperPlayer.EVENT_LOAD_FAIL,loadBack);

				if(back != null) back();
			}
		}

		private function playBack(e:Event):void{
			if(onFinish != null) onFinish();
		}

		private function removeLoader():void{
			if(!_player) return;

			graphics.clear();

			try{
				removeChild(_player);
			}catch(e:Error){}

			_player.removeEventListener(SuperPlayer.EVENT_PLAY_COMPLETE,playBack);

			_player.destory();
			_player = null;
		}

	}
}
