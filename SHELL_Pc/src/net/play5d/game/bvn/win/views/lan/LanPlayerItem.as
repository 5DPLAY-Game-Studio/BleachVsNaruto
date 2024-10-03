package net.play5d.game.bvn.win.views.lan
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import net.play5d.game.bvn.win.data.ClientVO;
	import net.play5d.game.bvn.win.data.LanGameModel;
	import net.play5d.game.bvn.win.utils.UIAssetUtil;

	public class LanPlayerItem
	{
		public var ui:MovieClip;
		
		public var onOut:Function;
		
		private var _client:ClientVO;
		
		public function LanPlayerItem()
		{
			ui = UIAssetUtil.I.createDisplayObject("player_item_mc");
			ui.btn_out.visible = false;
			ui.btn_out.addEventListener(MouseEvent.CLICK , outHandler);
		}
		
		public function setOwner():void{
			ui.txt.text = LanGameModel.I.playerName;
			ui.type.gotoAndStop(1);
		}
		
		public function setPlayer(cv:ClientVO):void{
			_client = cv;
			ui.txt.text = cv.name;
			ui.type.gotoAndStop(2);
			ui.btn_out.visible = true;
		}
		
		public function setLooker(cv:ClientVO):void{
			_client = cv;
			ui.txt.text = cv.name;
			ui.type.gotoAndStop(3);
			ui.btn_out.visible = true;
		}
		
		private function outHandler(e:MouseEvent):void{
			
			if(onOut != null) onOut(this);
		}
		
	}
}