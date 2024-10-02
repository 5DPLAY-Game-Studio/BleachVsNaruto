package net.play5d.game.bvn.ui.dialog
{
	
	import flash.display.SimpleButton;
	import flash.text.TextFormatAlign;
	
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.debug.DebugUtil;
	import net.play5d.game.bvn.ui.Text;
	import net.play5d.game.bvn.utils.BtnUtils;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.display.bitmap.BitmapFontText;
	
	public class ConfrimUI extends BaseDialog
	{
		private var _cnTxt:Text;
		
		public var yesBack:Function;
		public var noBack:Function;
		
		private var _ui:dialog_confrim;
		
		protected var _noBtn:SimpleButton;
		protected var _yesBtn:SimpleButton;
		
		public function ConfrimUI()
		{
			super();
			
			width = 495;
			height = 240;
			
			_ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.dialog, 'dialog_confrim');
			_dialogUI= _ui;
			
			build();
		}
		
		protected override function onDestory():void{
			super.onDestory();
			if(_cnTxt){
				_cnTxt.destory();
				_cnTxt = null;
			}
			BtnUtils.destoryBtn(_noBtn);
			BtnUtils.destoryBtn(_yesBtn);
		}
		
		protected function build():void{
			_cnTxt = new Text();
			_cnTxt.leading = 12;
			_cnTxt.x = 15;
			_cnTxt.y = 35;
			_cnTxt.width = 460;
			_cnTxt.height = 140;
			_cnTxt.multiLine(true);
			_cnTxt.align = TextFormatAlign.CENTER;
			_ui.addChild(_cnTxt);
			
			_noBtn = _ui.getChildByName('no') as SimpleButton;
			_yesBtn = _ui.getChildByName('yes') as SimpleButton;
			
			BtnUtils.initBtn(_noBtn, okHandler);
			BtnUtils.initBtn(_yesBtn, okHandler);
		}
		
		private function okHandler(e:SimpleButton):void{
			switch(e){
				case _yesBtn:
					if(yesBack != null) yesBack();
					break;
				case _noBtn:
					if(noBack != null) noBack();
					break;
			}
		}
		
		public function setMsg(en:String = null , cn:String = null):void{
			setTitle(en);
			
			if(!cn) return;
			
			_cnTxt.text = cn;
			_cnTxt.visible = true;
		}
		
	}
}