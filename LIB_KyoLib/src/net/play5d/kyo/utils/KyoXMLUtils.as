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

package net.play5d.kyo.utils
{
	public class KyoXMLUtils
	{
		public function KyoXMLUtils()
		{
		}

		public static function encodeToVO(xml:Object , voClass:Class , KeyId:String = null , childrenKey:String = null , childrenMatches:Array = null):Object{
			var o:Object = KeyId ? {} : [];
			var x:XMLList = xml is XMLList ? xml as XMLList : (xml as XML).children();

			for each(var i:XML in x){
				var att:XMLList = i.attributes();
				var vo:* = new voClass();
				for(var j:int = 0 ; j < att.length() ; j++){
					var k:String = att[j].name();
					var v:String = att[j];
					try{
						if(vo[k] is Boolean && (v=='0'||v=='1')){
							vo[k] = int(v) == 1;
						}else{
							vo[k] = v;
						}
					}catch(e:Error){
						trace(e);
					}
				}

				if(childrenKey){
					vo[childrenKey] = i.children();
				}

				if(childrenMatches){
					for each(var l:String in childrenMatches){
						var vv:XMLList = i.child(l);
						if(vv) vo[l] = vv;
					}
				}

				if(o is Array){
					(o as Array).push(vo);
				}else{
					var kk:String = i.attribute(KeyId);
					o[kk] = vo;
				}
			}



			return o;
		}

		public static function encodeToString(x:XML):Array{
			var o:Array = [];
			for each(var i:XML in x.children()){
				o.push(i);
			}
			return o;
		}

		public static function getUint(x:XMLList , defaultNumber:uint = 0):uint{
			var v:int = int(x);
			if(v > 0) return v;
			return defaultNumber;
		}

		public static function getNumber(x:XMLList , defaultNumber:Number = 0):Number{
			var v:Number = Number(x);
			if(!isNaN(v)) return v;
			return defaultNumber;
		}

	}
}
