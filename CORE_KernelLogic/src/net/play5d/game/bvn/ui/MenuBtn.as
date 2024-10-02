package net.play5d.game.bvn.ui
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Elastic;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.display.BitmapText;
	import net.play5d.kyo.display.bitmap.BitmapFontText;

	public class MenuBtn extends EventDispatcher
	{
		public var ui:mc_wzbtn;
		public var cn:String;
		public var label:String;
		public var func:Function;
		
		public var height:Number = 75;
		
		public var index:int;
		
		public var children:Array;
		
		private var _bitmapText:BitmapFontText;
		
		private var _cnTxt:BitmapText;
		
		public function MenuBtn(label:String , cn:String = "" , func:Function = null)
		{
			this.cn = cn;
			this.label = label;
			this.func = func;
			
			ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.common_ui , 'mc_wzbtn');
			
			ui.buttonMode = true;
			ui.mouseChildren = false;
			
			_bitmapText = new BitmapFontText(AssetManager.I.getFont('font1'));
			_bitmapText.text = label;
			_bitmapText.x = -_bitmapText.width/2;
			ui.addChild(_bitmapText);
			
			
			ui.bg.mouseChildren = ui.bg.mouseEnabled = false;
			ui.bg.visible = false;
			
			if(GameUI.SHOW_CN_TEXT){
				_cnTxt = new BitmapText();
				UIUtils.formatText(_cnTxt.textfield , {font:"黑体",size:18});
				_cnTxt.text = cn;
				_cnTxt.x = 10;
				_cnTxt.y = 45;
				ui.bg.addChild(_cnTxt);
			}
			
		}
		
		private var _listeners:Object = {};
		public override function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void{
			if(ui.hasEventListener(type)) return;
			ui.addEventListener(type,selfHandler,useCapture,priority,useWeakReference);
			_listeners[type] = listener;
		}
		public function removeAllEventListener():void{
			for(var i:String in _listeners){
				ui.removeEventListener(i,_listeners[i]);
			}
			_listeners = {};
		}
		private function selfHandler(e:Event):void{
			_listeners[e.type](e.type , this);
		}
		
		public function isHover():Boolean{
			return ui.bg.visible;
		}
		
		public function hover():void{
			if(_isOpen) return;
			if(ui.bg.visible) return;
			ui.bg.visible = true;
			var sx:Number = ui.bg.scaleX;
			ui.bg.scaleX = 0.01;
			TweenLite.to(ui.bg,0.2,{scaleX:sx});
			SoundCtrl.I.sndSelect();
		}
		public function normal():void{
			if(_isOpen) return;
			ui.bg.visible = false;
//			TweenLite.to(ui.bg,0.1,{scaleX:0.01,onComplete:function():void{
//				ui.bg.visible = false;
//			}});
		}
		
		public function select(back:Function = null):void{
			ui.alpha = -1;
			TweenLite.to(ui,1,{alpha:1,ease:Elastic.easeOut,onComplete:back});
			SoundCtrl.I.sndConfrim();
		}
		
		private var _isOpen:Boolean;
		public function openChild():void{
			if(_isOpen) return;
			_isOpen = true;
			ui.bg.gotoAndStop(2);
			var ct:ColorTransform = new ColorTransform();
			ct.redOffset = 50;
			ct.greenOffset = -30;
			ct.blueOffset = -30;
			_bitmapText.colorTransform(ct);
		}
		
		public function closeChild():void{
			if(!_isOpen) return;
			_isOpen = false;
			ui.bg.gotoAndStop(1);
			
			_bitmapText.colorTransform(null);
		}
		
		public function dispose():void{
			if(_bitmapText){
				_bitmapText.dispose();
				_bitmapText = null;
			}
			removeAllEventListener();
			
			if(children){
				for each(var b:MenuBtn in children){
					b.dispose();
				}
				children = null;
			}
			
			if(_cnTxt){
				_cnTxt.destory();
				_cnTxt = null;
			}
			
		}
		
		public function childMode():void{
			var ct:ColorTransform = new ColorTransform();
			ct.redOffset = 50;
			ct.greenOffset = -30;
			ct.blueOffset = -30;
			
			_bitmapText.colorTransform(ct);
			_bitmapText.scaleX = _bitmapText.scaleY = 0.75;
			_bitmapText.x = -_bitmapText.width/2;
			
			ui.bg.scaleY = 0.75;
			ui.bg.scaleX = 0.9;
			ui.bg.gotoAndStop(2);
			height = 55;
		}
		
		
	}
}