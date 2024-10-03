package net.play5d.game.bvn.win.views.lan
{
	import flash.display.MovieClip;
	
	import net.play5d.game.bvn.win.ctrls.LANServerCtrl;
	import net.play5d.game.bvn.win.utils.UIAssetUtil;
	import net.play5d.kyo.utils.KyoBtnUtils;

	public class LANRoomPlayerItem
	{
		public var ui:MovieClip;
		public var id:String;
		public function LANRoomPlayerItem(id:String , name:String)
		{
			
			this.id = id;
			
			ui = UIAssetUtil.I.createDisplayObject("player_item_mc");
			ui.txt.text = name;
			ui.type.gotoAndStop(2);
			ui.btn_out.visible = false;
		}
		
		public function enableOut():void{
			ui.btn_out.visible = true;
			KyoBtnUtils.initBtn(ui.btn_out,outClickHandler);
		}
		
		public function destory():void{
			if(ui.btn_out && ui.btn_out.visible) KyoBtnUtils.disposeBtn(ui.btn_out);
		}
		
		private function outClickHandler():void{
			LANServerCtrl.I.kickOut(id);
		}
		
	}
}