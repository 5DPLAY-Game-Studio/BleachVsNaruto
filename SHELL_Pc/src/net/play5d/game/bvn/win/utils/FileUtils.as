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

package net.play5d.game.bvn.win.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	import net.play5d.game.bvn.utils.GameLogger;

	public class FileUtils
	{
		public function FileUtils()
		{
		}

		/**
		 * 写文件（如果文件不存在将新建，如果存在则替换）
		 * @param url 完整路径（C:\abc）
		 * @param content 文件数据,支持String,ByteArray
		 */
		public static function writeFile(url:String , content:* , fileMode:String = null):void{
			fileMode ||= FileMode.WRITE;

			try{
				var file:File = new File(url);
				var fs:FileStream = new FileStream();
				fs.open(file,fileMode);

				if(content is String){
					fs.writeUTFBytes(content);
				}
				if(content is ByteArray){
					var byte:ByteArray = (content as ByteArray);
					fs.writeBytes(byte,0,byte.bytesAvailable);
				}

				fs.close();
			}catch(e:Error){
				GameLogger.log('FileUtils.writeFile' + e);
			}
		}

		/**
		 * 写主程序目录下的文件（如果文件不存在将新建，如果存在则替换）
		 * @param nativeUrl 相对路径（abc/123/1.txt）
		 * @param content 文件数据,支持String,ByteArray
		 */
		public static function writeAppFloderFile(nativeUrl:String , content:* , fileMode:String = null):void{
			var url:String = getAppFloderFileUrl(nativeUrl);
			writeFile(url , content , fileMode);
		}

		public static function getAppFloderFileUrl(nativeUrl:String):String{
			var path:File = File.applicationDirectory;
			var pathUrl:String = path.nativePath;
			var url:String = pathUrl+"/"+nativeUrl;
			return url;
		}

		/**
		 * 创建目录
		 * @param url 完整路径（C:\abc）
		 */
		public static function createFloder(url:String):void{
			try{
				var dir:File = new File(url);
				dir.createDirectory();
			}catch(e:Error){
				GameLogger.log('FileUtils.createFloder' + e);
			}
		}

		public static function readTextFile(url:String):String{
			var text:String;
			try{
				var file:File = new File(url);
				var fs:FileStream = new FileStream();
				fs.open(file,FileMode.READ);
				text = fs.readUTFBytes(fs.bytesAvailable);
				fs.close();
			}catch(e:Error){
				GameLogger.log('FileUtils.readTextFile , ' + e);
			}
			return text;
		}

		public static function del(url:String):void{
			var file:File = new File(url);
			try{
				file.deleteFile();
			}catch(e:Error){
				GameLogger.log('FileUtils.del' + e);
			}

		}

	}
}
