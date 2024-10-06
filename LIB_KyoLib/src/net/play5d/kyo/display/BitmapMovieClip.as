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

package net.play5d.kyo.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.IBitmapDrawable;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import net.play5d.kyo.utils.KyoUtils;

	public class BitmapMovieClip extends Sprite
	{
		public var currentFrame:int;
		public var currentFrameLabel:String;
		public var totalFrames:int;
		public var gapFrame:int;
		public var loopGapFrame:int;
		public var lockSize:Boolean;
		public var autoPlay:Boolean;
		public var fixRegPoint:Boolean = true;
		public var fixSize:Point;
		public var loopPlay:Boolean = true;
		public var playComplete:Boolean;
		public var fixPoint:Point;

		public var onPlayComplete:Function;

		private var _insArray:Array;
		protected var _bp:Bitmap;
		private var _scripts:Object;
		private var _maxFrames:int;
		private var _currentGapFrame:int = 0;
		private var _listenFunctions:Array;

//		private var _scaleX:Number = 1;
//		private var _scaleY:Number = 1;

		/**
		 * @param autoPlay 自动播放
		 * @param drawFrames 最大帧数，MC帧数超过此值则不创建超过的帧 [-1 不限制]
		 * @param lockWidthHeight 当Marix的scale改变时，是否不改变Width,Height (默认不改变)
		 */
		public function BitmapMovieClip(autoPlay:Boolean = true , drawFrames:int = -1 , lockSize:Boolean = false)
		{
			this.autoPlay = autoPlay;
			this.lockSize = lockSize;
			_maxFrames = drawFrames;
		}

		/**
		 * 把一个MC逐帧绘制成BitmapData
		 * @param source
		 * @param matrix
		 * @param colorTransform
		 * @param blendMode
		 * @param clipRect
		 * @param smoothing
		 *
		 */
		public function draw(source:DisplayObject, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:String = null, clipRect:Rectangle = null, smoothing:Boolean = false):void
		{
			beforeDraw(matrix, colorTransform, blendMode, clipRect, smoothing);
			var drawVar:DrawVar = new DrawVar(source, matrix, colorTransform, blendMode, clipRect, smoothing);
			if(drawVar.source is MovieClip){
				var mc:MovieClip = drawVar.source as MovieClip;
				var e:int = _maxFrames == -1 ? mc.totalFrames : Math.min(_maxFrames , mc.totalFrames);
				for(var i:int = 1 ; i <= e ; i++) createFrame(drawVar , i);
			}else{
				createFrame(drawVar , 1);
			}
			drawVar.destory();
			drawVar = null;
			initBMC();
		}

		/**
		 * 把多个MC逐帧绘制成BitmapData
		 * @param source
		 * @param matrix
		 * @param colorTransform
		 * @param blendMode
		 * @param clipRect
		 * @param smoothing
		 * @param baseFrameMc 基帧图像,其他的层按照此MC作动画
		 * @param hideFrameout 隐藏掉超过基帧的图像
		 */
		public function drawMulti(source:Array, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:String = null, clipRect:Rectangle = null, smoothing:Boolean = false , baseFrameMc:MovieClip = null , hideFrameout:Boolean = true):void
		{
			beforeDraw(matrix, colorTransform, blendMode, clipRect, smoothing);
			var mcGroup:McGroup = new McGroup(source,baseFrameMc,hideFrameout);
			var drawVar:DrawVar = new DrawVar(mcGroup, matrix, colorTransform, blendMode, clipRect, smoothing);
			var e:int = _maxFrames == -1 ? mcGroup.totalFrames : Math.min(_maxFrames , mcGroup.totalFrames);
			for(var i:int = 1 ; i <= e ; i++) createFrame(drawVar , i);
			mcGroup.destory();
			mcGroup = null;
			drawVar.destory();
			drawVar = null;
			initBMC();
		}

		/**
		 * 所有的BitmapData对象，赋值将根据此数组中BitmapData对象创建BitmapMovieClip
		 */
		public function get insArray():Array
		{
			return _insArray;
		}
		public function set insArray(value:Array):void
		{
			if(!value) return;
			_insArray = value;
			initBMC();
		}
		public function set bitmapDataArray(value:Array):void{
			if(!value) return;
			var f:int;
			_insArray = [];
			for each(var i:BitmapData in value){
				f ++;
				var vo:BitmapMCFrameVO = new BitmapMCFrameVO();
				vo.bd = i;
				_insArray[f] = vo;
			}
			initBMC();
		}

		public function clone():BitmapMovieClip{
			var bmc:BitmapMovieClip = new BitmapMovieClip();
			bmc.insArray = _insArray;
			return bmc;
		}

		private function initBMC():void{
			if(!_insArray || _insArray.length < 1){
				throw Error('bitMapDatas has no data');
			}
			if(!_bp){
				_bp = new Bitmap();
				addChild(_bp);
			}
			playComplete = false;
			currentFrame = 1;
			totalFrames = _insArray.length - 1;
			render();
			if(autoPlay) play();
		}

		private function createFrame(drawVar:DrawVar , frame:int):void{
			var sc:DisplayObject = drawVar.source;
			var mc:MovieClip = sc is MovieClip ? sc as MovieClip : null;
			var gmc:McGroup = sc is McGroup ? sc as McGroup : null;

			var ins:BitmapMCFrameVO = new BitmapMCFrameVO();

			if(mc){
				mc.gotoAndStop(frame);
				initListenFunctions(mc,frame);
				ins.frameLabel = mc.currentFrameLabel;
			}
			if(gmc){
				gmc.gotoAndStop(frame);
				initListenFunctions(gmc,frame);
				ins.frameLabel = gmc.currentFrameLabel;
			}

			var sp:Sprite = new Sprite();

			if(fixRegPoint){
				var bounds:Rectangle = sc.getBounds(sc);
				sc.x = -(bounds.x * sc.scaleX) << 0;
				sc.y = -(bounds.y * sc.scaleY) << 0;
			}

			if(fixPoint) sc.x += fixPoint.x;

			sp.addChild(sc);

			ins.x = sc.x;
			ins.y = sc.y;

			var size:Point = fixSize ? fixSize : new Point(sp.width , sp.height);

			if(size.x > 0 && size.y > 0){
				if(fixPoint){
					size.x += fixPoint.x;
					size.y += fixPoint.y;
				}

				ins.bd = new BitmapData(size.x , size.y , true , 0);
				ins.bd.draw(sp,null,drawVar.colorTransform,drawVar.blendMode,drawVar.clipRect,drawVar.smoothing);
			}
			_insArray[frame] = ins;
			sp = null;
		}
		//////////////////////////////////////////////////////////////////////////////////////////////////////
		public function gotoAndPlay(frame:Object , scene:String = null):void{
			var f:int = getFrame(frame);
			if(f > 0)currentFrame = f;
			play();
		}
		public function gotoAndStop(frame:Object):void{
			var f:int = getFrame(frame);
			removeEventListener(Event.ENTER_FRAME,playing);
			if(currentFrame == f || f < 1) return;
			if(f > totalFrames) frame = totalFrames;
			currentFrame = f;
			render();
		}
		public function nextFrame():void{
			stop();
			playComplete = false;
			currentFrame++;
			render();
		}
		public function prevFrame():void{
			stop();
			playComplete = false;
			currentFrame--;
			render();
		}
		public function play():void{
			if(totalFrames < 2) return;
			if(hasEventListener(Event.ENTER_FRAME)) return;
			addEventListener(Event.ENTER_FRAME,playing);
		}

		public function stop():void{
			removeEventListener(Event.ENTER_FRAME,playing);
		}

		/**
		 * 在某帧调用方法
		 * @param frame 帧
		 * @param script 函数
		 * @param params 参数
		 */
		public function addFrameScript(frame:int,script:Function,params:Array = null):void{
			var insf:InsFunction = new InsFunction(script,params);

			_scripts ||= {};
			_scripts[frame] ||= [];
			KyoUtils.array_push_notHas(_scripts[frame],insf);
		}

		/**
		 * 帧调用函数参数名
		 * @param name Array名称
		 * 用法：在MC中声明一个Array，在需要调用函数的帧中，将这个Array赋值需要调用的函数；
		 * 		Array中可以是Function,也可以是Object{f:Function,p:Array}
		 * 		Array格式 = [Function,{f:函数[Function],p:参数[Array]}]
		 */
		public function addFunctionListener(name:String):void{
			KyoUtils.array_push_notHas(_listenFunctions,name);
		}

		private function playing(e:Event):void{
			renderNextFrame();
		}

		public function renderNextFrame():void{
			if(_currentGapFrame == 0) {
				_currentGapFrame = gapFrame;
				currentFrame++;
				playComplete = false;
				render();
			} else {
				_currentGapFrame --;
			}
		}

		public function destory(clearBitmap:Boolean = false):void{
			stop();
			if(clearBitmap){
				for each(var i:BitmapMCFrameVO in _insArray){
					if(i.bd) i.bd.dispose();
					i = null;
				}
			}
			_insArray = null;
		}

		private function render():void{
			if(!_insArray) return;

			if(currentFrame > totalFrames){
				if(currentFrame - totalFrames > loopGapFrame){
					if(loopPlay){
						currentFrame = 1;
					}else{
						playComplete = true;
						if(onPlayComplete != null) onPlayComplete();
						stop();
						return;
					}
				}else{
					return;
				}
			}
			if(currentFrame < 1) currentFrame = totalFrames;
			var ins:BitmapMCFrameVO = _insArray[currentFrame];
			currentFrameLabel = ins.frameLabel;
			_bp.bitmapData = ins.bd;
			_bp.x = -ins.x;
			_bp.y = -ins.y;

			renderScript();
		}

		private function renderScript():void{
			if(_scripts && _scripts[currentFrame] != null){
				for each(var o:Object in _scripts[currentFrame]){
					if(o is Function){
						o();
					}else{
						(o.fun as Function).call(null,o.params);
					}
				}
			}
		}

		private function getFrame(frame:Object):int{
			playComplete = false;

			if(frame is String){
				for(var i:int = 1 ; i <= totalFrames ; i++){
					if(_insArray[i].frameLabel == frame) return i;
				}
			}
			if(frame is int) return frame as int;
			return -1;
		}

		private function beforeDraw(matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:String = null, clipRect:Rectangle = null, smoothing:Boolean = false):void{
			_insArray = [];
			if(lockSize && matrix){
//				_scaleX = matrix.a;
//				_scaleY = matrix.d;
				matrix.a = 1;
				matrix.d = 1;
			}
		}

		private function initListenFunctions(mc:Object,frame:int):void{
			if(!_listenFunctions) return;

			var fs:Array = [];
			var oo:Object;
			for each(var n:String in _listenFunctions){
				if(mc is MovieClip){
					var mm:MovieClip = mc as MovieClip;
					if(mm[n]) for each(var ff:Object in mm[n]) fs.push(ff);
				}
				if(mc is McGroup){
					var gmc:McGroup = mc as McGroup;
					fs = gmc.getFrameFunctions(n);
				}
			}
			for each(var f:Object in fs){
				if(f is Function){
					addFrameScript(frame,f as Function);
				}else{
					addFrameScript(frame,f.f,f.p);
				}
			}
		}
	}
}
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import net.play5d.kyo.utils.KyoUtils;

internal class DrawVar{
	public var source:DisplayObject , matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:String = null, clipRect:Rectangle = null, smoothing:Boolean = false;
	public function DrawVar(source:DisplayObject, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:String = null, clipRect:Rectangle = null, smoothing:Boolean = false){
		this.source = source;
		this.matrix = matrix;
		this.colorTransform = colorTransform;
		this.blendMode = blendMode;
		this.clipRect = clipRect;
		this.smoothing = smoothing;
		initlize();
	}
	public function destory():void{
		if(source is MovieClip) (source as MovieClip).gotoAndStop(1);
		source = null;
		matrix = null;
		colorTransform = null;
		clipRect = null;
	}

	private function initlize():void{
		if(matrix){
			source.scaleX *= matrix.a;
			source.scaleY *= matrix.d;
		}
	}
}

internal class McGroup extends Sprite{
	private var _ins:Array = [];
	public var totalFrames:int;
	public var hideFrameout:Boolean;
	private var _baseMc:MovieClip;

	public function McGroup(mcs:Array,baseFrameMc:MovieClip = null,hideFrameout:Boolean = true){
		this.hideFrameout = hideFrameout;
		_baseMc = baseFrameMc;

		var countFrame:Boolean = true;

		if(baseFrameMc){
			totalFrames = baseFrameMc.totalFrames;
			countFrame = false;
		}
		for(var i:int ; i < mcs.length ; i++){
			var d:DisplayObject = mcs[i] as DisplayObject;
			if(!d) continue;
			addDisplay(d);
			if(!countFrame) continue;
			if(d is MovieClip){
				(d as MovieClip).gotoAndStop(1);
				var tf:int = (d as MovieClip).totalFrames;
				if(totalFrames < tf) totalFrames = tf;
			}
		}
	}
	public function addDisplay(d:DisplayObject):void{
		addChild(d);
		_ins.push(d);
	}

	public function get currentFrameLabel():String{
		if(_baseMc) if(_baseMc.currentFrameLabel) return _baseMc.currentFrameLabel;
		for each(var d:DisplayObject in _ins){
			if(!d is MovieClip) continue;
			if(d == _baseMc) continue;
			var mc:MovieClip = d as MovieClip;
			if(mc.currentFrameLabel) return mc.currentFrameLabel;
		}
		return null;
	}

	public function gotoAndStop(frame:int):void{
		for each(var d:DisplayObject in _ins){
			if(d is MovieClip){
				var mc:MovieClip = d as MovieClip;
				if(mc.totalFrames >= frame){
					mc.visible = true;
					mc.gotoAndStop(frame);
					continue;
				}
			}
			if(hideFrameout) d.visible = false;
		}
	}

	public function getFrameFunctions(name:String):Array{
		var fs:Array = [];
		for each(var d:DisplayObject in _ins){
			if(d[name]){
				for each(var f:Function in d[name]){
					fs.push(f);
				}
				d[name] = null;
			}
		}
		return fs;
	}
	public function destory():void{
		KyoUtils.removeAllChildren(this);
		_ins = null;
	}
}

internal class InsFunction{
	private var _fun:Function;
	private var _params:Array;
	public function InsFunction(fun:Function , params:Array = null){
		_fun = fun;
		_params = params;
	}
	public function call():void{
		_fun.call(null,_params);
	}
}
