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

package net.play5d.game.bvn.stage
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;

	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.debug.Debugger;
	import net.play5d.game.bvn.events.GameEvent;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.stage.IStage;

	public class GameLoadingStage implements IStage
	{
		private var _ui:loading_cover_mc;

		private var _initBack:Function;
		private var _initFail:Function;

		public function GameLoadingStage()
		{
		}

		/**
		 * 显示对象
		 */
		public function get display():DisplayObject
		{
			return _ui;
		}

		/**
		 * 构建
		 */
		public function build():void
		{
			_ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.loading , 'loading_cover_mc');
		}

		public function loadGame(succ:Function , fail:Function):void{
			_initBack = succ;
			_initFail = fail;

			if(AssetManager.I.needPreLoad()){
				AssetManager.I.loadPreLoad(loadPreloadBack, loadPreloadFail, loadPreloadProcess);
				msg("游戏初始化：准备游戏资源");
			}else{
				loadPreloadBack();
			}
		}

		private function loadPreloadBack():void{
			GameData.I.loadConfig(loadConfigBack , loadConfigFail);
			msg("游戏初始化：正在加载配置文件");
		}

		private function loadPreloadFail(errorStr:String = null):void{
			Debugger.log("游戏初始化失败：准备游戏资源失败：",errorStr);
			msg("游戏初始化失败：准备游戏资源失败!");
			if(_initFail != null) _initFail(errorStr);
		}

		private function loadPreloadProcess(p:Number):void{
			if(p > 1) p = 1;
			_ui.bar.bar.scaleX = p;
		}

		private function loadConfigFail(errorStr:String):void{
			Debugger.log("游戏初始化失败：加载配置文件失败：",errorStr);
			msg("游戏初始化失败：加载配置文件失败!");
			if(_initFail != null) _initFail(errorStr);
		}

		private function loadConfigBack():void{
			AssetManager.I.loadBasic(loadAssetBack,loadAssetProcess);
			msg("游戏初始化：正在加载游戏资源");
		}

		private function loadAssetProcess(p:Number , message:String , step:int , totalStep:int):void{
			if(p > 1){
				trace(message+"::进度超过100%");
				p = 1;
			}
			_ui.bar.bar.scaleX = p;

			var txt:String = "游戏初始化：正在加载"+message+"资源("+step+"/"+totalStep+")";
			msg(txt);
			GameEvent.dispatchEvent(GameEvent.LOADING_GAME, {msg: txt, process: p, step: step, totalStep: totalStep});
		}

		private function loadAssetBack():void{
			if(_initBack != null){
				_initBack();
				_initBack = null;
			}
			_initFail = null;
		}

		/**
		 * 稍后构建
		 */
		public function afterBuild():void
		{
		}

		/**
		 * 销毁
		 * @param back 回调函数
		 */
		public function destroy(back:Function =null):void
		{

		}

		private function msg(v:String):void{
			_ui.bar.txt.text = v;
		}

	}
}
