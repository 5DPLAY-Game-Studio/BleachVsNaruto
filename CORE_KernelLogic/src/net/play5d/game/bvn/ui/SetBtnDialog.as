package net.play5d.game.bvn.ui
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.display.bitmap.BitmapFontText;

	public class SetBtnDialog
	{
		public var ui:key_set_dialog_mc;
		public var isShow:Boolean = true;
		
		private var _pushTxt:BitmapFontText;
		private var _keyNameTxt:BitmapFontText;
		private var _cntxt:TextField;
		
		public function SetBtnDialog()
		{
			ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.setting , 'key_set_dialog_mc');
			ui.visible = false;
			
			_pushTxt = new BitmapFontText(AssetManager.I.getFont('font1'));
			_keyNameTxt = new BitmapFontText(AssetManager.I.getFont('font1'));
			
			_pushTxt.y = _keyNameTxt.y = -30;
			
			_pushTxt.text = 'PUSH A KEY FOR'
			_pushTxt.x = -_pushTxt.width/2;
			ui.ct_msg.addChild(_pushTxt);
			
			ui.ct_keyname.addChild(_keyNameTxt);
			
			_cntxt = ui.txt;
			_cntxt.defaultTextFormat = new TextFormat('楷体',20);
		}
		
		public function show(name:String , cn:String):void{
			ui.visible = true;
			
			_keyNameTxt.text = name;
			_keyNameTxt.x = -_keyNameTxt.width/2;
			_cntxt.text = '请按下一个键设置【'+cn+'】';
			
			isShow = true;
		}
		
		public function hide():void{
			ui.visible = false;
			isShow = false;
		}
		
	}
}