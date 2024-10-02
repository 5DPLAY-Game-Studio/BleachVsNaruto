package net.play5d.game.bvn.utils
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;

	public class KeyBoarder
	{
		private static var _inited:Boolean;
		
		private static var _stage:Stage;
		
		private static var _keyHandlers:Vector.<Function> = new Vector.<Function>();
		
		public function KeyBoarder()
		{
		}
		
		public static function initlize(stage:Stage):void{
			if(_inited) return;
			
			_inited = true;
			
			_stage = stage;
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyBoardHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP,keyBoardHandler);
			
		}
		
		public static function focus():void{
			if(!_inited) return;
			_stage.focus = _stage;
		}
		
		public static function listen(handler:Function):void{
			if(!_inited) return;
			if(_keyHandlers.indexOf(handler) == -1) _keyHandlers.push(handler);
		}
		
		public static function unListen(handler:Function):void{
			if(!_inited) return;
			if(_keyHandlers.indexOf(handler) != -1) _keyHandlers.splice( _keyHandlers.indexOf(handler) , 1 );
		}
		
		private static function keyBoardHandler(e:KeyboardEvent):void{
			if(!_inited) return;
			var i:int = 0;
			for(i = 0 ; i < _keyHandlers.length ; i++){
				_keyHandlers[i](e);
			}
		}
		
	}
}