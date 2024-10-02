package net.play5d.kyo.utils
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class KyoLog
	{
		public static var tracelog:Boolean = true;
		
		private static var _log:String = '';
		public static function log(...params):void{
			var logstr:String = params.join(' ');
			_log += logstr + "\n";
			updateLogTxt();
			
			if(tracelog) trace(logstr);
		}
		
		public static function getlog():String{
			return _log;
		}
		
		public static function toogleLog(ct:Sprite):void{
			var sp:DisplayObject = ct.getChildByName('kyo_log_sprite');
			if(!sp){
				showLog(ct);
			}else{
				hideLog(ct);
			}
		}
		
		private static var _logtxt:TextField;
		public static function showLog(ct:Sprite):void{
			hideLog(ct);
			
			if(!_logtxt){
				_logtxt = new TextField();
				_logtxt.textColor = 0xFFFFFF;
				_logtxt.multiline = true;
				var wh:Number = ct.stage ? ct.stage.stageWidth : ct.width;
				_logtxt.width = wh / 2;
			}
			
			var sp:Sprite = new Sprite();
			sp.name = 'kyo_log_sprite';
			sp.addChild(_logtxt);
			ct.addChild(sp);
			
			updateLogTxt();
		}
		
		public static function hideLog(ct:Sprite):void{
			var sp:DisplayObject = ct.getChildByName('kyo_log_sprite');
			if(!sp) return;
			
			ct.removeChild(sp);
			sp = null;
		}
		
		private static function updateLogTxt():void{
			if(!_logtxt) return;
			_logtxt.text = _log;
			_logtxt.height = _logtxt.textHeight + 10;
			
			var sp:Sprite = _logtxt.parent as Sprite;
			if(sp){
				sp.graphics.clear();
				sp.graphics.beginFill(0,0.5);
				sp.graphics.drawRect(0,0,_logtxt.width,_logtxt.height);
				sp.graphics.endFill();
			}
		}
		
	}
}