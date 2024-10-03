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
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	import mx.core.FlexGlobals;

	import spark.components.WindowedApplication;

	/**
	 * 程序进程工具类
	 * 配置文件需要定义：<supportedProfiles>extendedDesktop desktop</supportedProfiles>
	 */
	public class ProcessUtils
	{

		public function ProcessUtils()
		{
		}


		/**
		 * 启动程序
		 * @param path 程序路径
		 * @param arguments 启动参数 Array|String
		 */
		public static function createProcess(path : String , arguments:Object = null) : NativeProcess
		{
			if(!NativeProcess.isSupported)
			{
				trace("NativeProcess is not supported");
				return null;
			}

			var exeFile : File = new File(path);

			if(exeFile.exists)
			{
				var argumentsVec:Vector.<String>;
				if(arguments){
					argumentsVec = new Vector.<String>();
					if(arguments is String){
						argumentsVec.push(arguments);
					}
					if(arguments is Array){
						for(var i:int ; i < arguments.length ; i++){
							argumentsVec.push(arguments[i]);
						}
					}
				}


				var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				nativeProcessStartupInfo.executable = exeFile;
				nativeProcessStartupInfo.arguments = argumentsVec;
				var process:NativeProcess = new NativeProcess();
				process.start(nativeProcessStartupInfo);
				trace("PC process is created");
				return process;
			}

			return null;

		}

		private static function createCMDProcess(param:Object = null , exitBack:Function = null):NativeProcess{
			var process:NativeProcess = createProcess("c:/windows/system32/cmd.exe",param);

			if(!process) return null;

			if(exitBack != null){
				process.addEventListener(NativeProcessExitEvent.EXIT,cmdExitHandler);
			}

			function cmdExitHandler(e:NativeProcessExitEvent):void{
				process.removeEventListener(NativeProcessExitEvent.EXIT,cmdExitHandler);
				if(exitBack != null) exitBack();
			}

			return process;
		}

		/**
		 * 调用CMD
		 * @param cmd CMD命令
		 * @param outputBack CMD输入回调函数
		 * @param outputCheckTimeOut 当多少时间内没有输出信息后，返回OUTPUT
		 * @param processLiveTime 进程存活时间
		 */
		public static function callCMD(cmd:String , processLiveTime:int = 5000, outputBack:Function = null , outputCheckTimeOut:int = 2000):Boolean{
			trace('call cmd ::' , cmd);
			cmd += "\n";
			var process:NativeProcess = createCMDProcess();
			if(process){
				process.standardInput.writeUTFBytes(cmd);

				if(outputBack != null){

					var outputFinTimer:Timer = new Timer(outputCheckTimeOut , 1);
					var output:String = "";
					outputFinTimer.addEventListener(TimerEvent.TIMER_COMPLETE,function():void{
//						trace('============================cmd output start======================================================');
//						trace(output);
//						trace('============================cmd output end========================================================');

						outputBack(output);

						setTimeout(closeProcess , processLiveTime);
					},false,0,true);

					process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,function(e:ProgressEvent):void{
						output += process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable);
						outputFinTimer.reset();
						outputFinTimer.start();
					},false,0,true);
				}else{
					setTimeout(closeProcess , processLiveTime);
				}
				return true;
			}

			function closeProcess():void{
				try{
					process.exit();
				}catch(e:Error){}
			}

			return false;

		}

		/**
		 * 关闭进程
		 * @param processName 进程名称(qq.exe)
		 */
		public static function closeProcess(processName:String):Boolean{
			var cmd:String = 'taskkill /f /t /im "'+processName+'"';
			return callCMD(cmd);
		}

		/**
		 * 检查进程是否存在
		 * @param processName 进程名称(qq.exe)
		 */
		public static function processExist(processName:String , back:Function):Boolean{

			function outputHandler(result:String):void{
				var exist:Boolean = result.indexOf(processName) != -1;
				back(exist);
			}

			var cmd:String = "tasklist";
			return callCMD(cmd,2000,outputHandler);
		}

		/**
		 * 打开应用程序
		 * @param path 完整路径
		 */
		public static function openProgram(path:String , initParam:String = null):Boolean{
			var initp:String = initParam ? ' '+initParam : '';
			return callCMD('"'+path+'"'+initp);
		}

		/**
		 * 调用资源管理器，打开指定目录
		 * @param floder 完整路径
		 */
		public static function openExplorer(floder:String):Boolean{
			return callCMD('explorer "'+floder+'"');
		}

		public static function runBAT(filePath:String , exitBack:Function = null):Boolean{
			trace('run bat :: '+filePath);
			return createCMDProcess(["/c",filePath],exitBack) != null;
		}

	}
}
