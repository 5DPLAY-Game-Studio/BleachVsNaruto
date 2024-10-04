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
	import flash.utils.ByteArray;

	import net.play5d.kyo.loader.KyoLoaderLite;

	public class GameSafeKeeper
	{
		private static var _i:GameSafeKeeper;
		public static function get I():GameSafeKeeper{
			_i ||= new GameSafeKeeper();
			return _i;
		}
		public function GameSafeKeeper()
		{
		}

		private var _fileSaveMap:Object;
		private var _configFailed:Boolean;

		private var _failFileMap:Object = {};
		private var _fileFailed:Boolean;

		private const KEY:String = "Wo&Ye@bu!Neng(889^Yang%a!Po!xO!bB)_(";
		private const IV:String = "#$@!#%^cscscsDDW*><1998AZSfdxx##(x_x)###2";

		public function loadConfigure(succ:Function, fail:Function = null):void{

			function succBack(data:ByteArray):void{
				try{
					var json:String = GameEncriptUtils.decryptAES(data, KEY, IV);
					var jsonObj:Object = JSON.parse(json);
					_fileSaveMap = jsonObj;
					if(succ != null) succ();
				}catch(e:Error){
					if(fail != null) fail(e);
				}
			}

			function failBack(e:* = null):void{
				trace('loadSafeFile fail:', e);
				_configFailed = true;
				if(fail != null) fail();
			}

			KyoLoaderLite.loadBytes('assets/.md5', succBack, failBack);
		}

		public function getConfigFailed():Boolean{
			return _configFailed;
		}

		public function getFailed():Boolean{
			return _fileFailed;
		}

		public function getConfigOrFileFailed():Boolean{
			return _configFailed || _fileFailed;
		}

		public function checkFile(url:String, fileBytes:ByteArray):Boolean{
			if(_configFailed || !_fileSaveMap) return false;

//			trace('checkFile', url);

			if(_failFileMap[url]){
				trace('checkFile Error :: not match! ', url);
				return false;
			}

			if(url.indexOf('assets') == 0){
				url = url.substr(7);
			}

			var md5:String = _fileSaveMap[url];
			if(!md5){
				trace('checkFile Error :: md5 not found! ', url);
				return false;
			}

			var fileMd5:String = GameEncriptUtils.getFileMD5(fileBytes);

			if(md5 == fileMd5){
				return true;
			}

			trace('checkFile Error :: md5 not match! ', url);

			_failFileMap[url] = 1;
			_fileFailed = true;
			return false;
		}

	}
}
