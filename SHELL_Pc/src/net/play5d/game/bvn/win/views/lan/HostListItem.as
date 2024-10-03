package net.play5d.game.bvn.win.views.lan
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.win.data.HostVO;
	import net.play5d.game.bvn.win.utils.LANUtils;
	import net.play5d.game.bvn.win.utils.UIAssetUtil;

	public class HostListItem
	{
		public var ui:MovieClip;
		public var data:HostVO;
		
		private var _mouseListener:Function;
		
		private var _focus:Boolean;
		
		public function HostListItem()
		{
			ui = UIAssetUtil.I.createDisplayObject("hostlist_item");
			ui.mouseChildren = false;
			ui.buttonMode = true;
		}
		
		public function setData(data:HostVO):void{
			
			this.data = data;
			
			ui.txt_name.text = data.getListName();
			ui.txt_mode.text = data.getGameModeStr();
			ui.txt_time.text = LANUtils.getTimeStr(data.updateTime);
			ui.lock.visible = data.password != null && data.password != "";
		}
		
		public function focus(v:Boolean):void{
			if(_focus == v){
				return;
			}
			
			_focus = v;
			
			if(v){
				ui.focusmc.gotoAndPlay("loop");
			}else{
				ui.focusmc.gotoAndStop(1);
			}
		}
		
		public function setMouseListener(listener:Function):void{
			
			_mouseListener = listener;
			
			ui.addEventListener(MouseEvent.MOUSE_OVER,mouseHandler);
			ui.addEventListener(MouseEvent.CLICK,mouseHandler);
		}
		
		public function removeMouseListener():void{
			_mouseListener = null;
			ui.removeEventListener(MouseEvent.MOUSE_OVER,mouseHandler);
			ui.removeEventListener(MouseEvent.CLICK,mouseHandler);
		}
		
		private function mouseHandler(e:Event):void{
			if(_mouseListener != null){
				_mouseListener(e.type , this);
			}
		}
		
	}
}