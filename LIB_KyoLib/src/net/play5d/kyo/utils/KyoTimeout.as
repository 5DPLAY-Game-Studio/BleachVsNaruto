package net.play5d.kyo.utils
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;

	public class KyoTimeout
	{
		public function KyoTimeout()
		{
		}
		
		public static var _root:DisplayObject;
		
		private static var _functions:Vector.<Object>;
		
		/**
		 * 使用前需要 init 一次
		 * @param root
		 * 
		 */
		public static function init(root:Sprite):void{
			_root = root;
			_functions = new Vector.<Object>();
		}
		
		/**
		 * 在多少帧之后调用 
		 * @param func
		 * @param frame
		 * @param param
		 * 
		 */
		public static function setFrameout(func:Function, frame:int, ...param):void{
			_functions.push( { func:func, frame:frame, param: param} );
			setLisnter();
		}
		
		/**
		 * 在多少时间后调用（毫秒） 
		 * @param func
		 * @param time
		 * @param param
		 * 
		 */
		public static function setTimeout(func:Function, time:int, ...param):void{
			var frame:int = Math.ceil( (time / 1000) * _root.stage.frameRate );
			var params:Array = [func, frame].concat(param);
			setFrameout.apply(null, params);
		}
		
		private static function setLisnter():void{
			_root.removeEventListener(Event.ENTER_FRAME,onEnterframe);
			_root.addEventListener(Event.ENTER_FRAME,onEnterframe);
		}
		
		private static function onEnterframe(e:Event):void{
			var i:int;
			var n:int = _functions.length;
			
			if(n < 1){
				_root.removeEventListener(Event.ENTER_FRAME,onEnterframe);
				return;
			}
			
			for(i = 0; i < n; i++){
				var fo:Object = _functions[i];
				
				if(!fo){
					_functions.splice(i, 1);
					i = 0;
					n = _functions.length;
					continue;
				}
				
				var func:Function = fo.func;
				var param:Array = fo.param;
				
				if(fo.frame -- <= 0){
					if(param && param.length > 0){
						func.apply(null, param);
					}else{
						func();
					}
					_functions[i] = null;
				}
				
			}
			
		}
		
		
	}
}