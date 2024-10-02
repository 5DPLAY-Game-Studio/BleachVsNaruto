package net.play5d.game.bvn.debug
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import net.play5d.kyo.input.KyoKeyCode;

	public class Debugger
	{
		
		public static var onErrorMsgCall:Function;
		public static const DRAW_AREA:Boolean = false;
		public static const SAFE_MODE:Boolean = false;
		public static const DEBUG_ENABLED:Boolean = false;
		
		public static const HIDE_MAP:Boolean = false;
		public static const HIDE_HITEFFECT:Boolean = false;
		
		public function Debugger()
		{
		}
		
		public static function log(...params):void{
			trace.call(null,params);
		}
		
		public static function errorMsg(msg:String):void{
			trace('Debugger.errorMsg:',msg);
			if(onErrorMsgCall != null) onErrorMsgCall(msg);
		}
		
		
		private static var _stage:Stage;
		public static function initDebug(stage:Stage):void{
			_stage = stage;
			showFPS();
		}
		
		public static function addChild(d:DisplayObject):void{
			_stage.addChild(d);
		}
		
		public static function showFPS():void{
			
			var currentTime:int = 0;
			var n:int = 0;
			var fpsCount:int;
			var fpsText:TextField;
			
			fpsText = new TextField();
			fpsText.textColor = 0xffff00;
			fpsText.mouseEnabled = false;
			_stage.addChild(fpsText);
			_stage.addEventListener(Event.ENTER_FRAME,countFPS);
			
			var fpsTimer:Timer = new Timer(1000,0);
			fpsTimer.addEventListener(TimerEvent.TIMER,updateFPS);
			fpsTimer.start();
			
			function countFPS(e:Event):void{
				fpsCount++;
			}
			
			function updateFPS(e:TimerEvent):void{
				fpsText.text = 'fps:'+fpsCount;
				fpsCount = 0;
			}
			
		}
		
		public static function runScriect(stage:Stage , success:Function):void{
			var _scriect:Array = [KyoKeyCode.P,KyoKeyCode.L,KyoKeyCode.A,KyoKeyCode.Y];
			var _keyIndex:int;
			var _successed:Boolean;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN,function(e:KeyboardEvent):void{
				
				if(_successed) return;
				
				if(e.keyCode == _scriect[_keyIndex].code){
					_keyIndex++;
					
					if(_keyIndex >= _scriect.length){
						_successed = true;
						success();
					}
					
				}else{
					_keyIndex = 0;
				}
				
			},false,0,true);
			
			
		}
		
		
	}
}