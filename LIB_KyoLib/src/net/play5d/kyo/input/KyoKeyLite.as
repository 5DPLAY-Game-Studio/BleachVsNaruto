package net.play5d.kyo.input
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;

	public class KyoKeyLite
	{
		public static var debug:Boolean = false;
		
		public function KyoKeyLite()
		{
		}
		
		private static var _stage:Stage;
		public static function active(stage:Stage):void{
			_stage = stage;
			
			if(!_stage){
				throw new Error('stage is null!');
				return;
			}
			
			_keyDowning = {};
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP,keyHandler);
		}
		
		public static function off():void{
			if(!_stage) return;
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyHandler);
			_stage.removeEventListener(KeyboardEvent.KEY_UP,keyHandler);
		}
		
		public static function isDown(code:uint):Boolean{
			if(!_keyDowning){
				throw new Error('此类尚未激活，需要先调用active方法!');
				return false;
			}
			return _keyDowning[code] != null;
		}
		
		private static var _keyDowning:Object;
		private static function keyHandler(e:KeyboardEvent):void{
			var code:uint = e.keyCode;
			if(e.type == KeyboardEvent.KEY_DOWN){
				_keyDowning[code] = 1;
			}
			if(e.type == KeyboardEvent.KEY_UP){
				delete _keyDowning[code];
			}
			if(debug) trace(e.type + ' : ' + code);
		}
		
	}
}