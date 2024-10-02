package net.play5d.game.bvn.ui.mosou
{
	import flash.display.Sprite;
	
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
	import net.play5d.kyo.display.bitmap.BitmapFontText;

	public class MousouKOsUI
	{
		private var _ct:Sprite;
		private var _text:BitmapFontText;
		public function MousouKOsUI(ui:Sprite)
		{
			_text = new BitmapFontText(AssetManager.I.getFont('font1'));
			ui.addChild(_text);
		}
		
		public function update():void{
			_text.text = GameCtrl.I.getMosouCtrl().gameRunData.koNum.toString();
		}
		
	}
}