package net.play5d.game.bvn.win.views.lan
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.game.bvn.win.ctrls.LANClientCtrl;
	import net.play5d.game.bvn.win.data.HostVO;
	import net.play5d.game.bvn.win.utils.LANUtils;
	import net.play5d.game.bvn.win.utils.UIAssetUtil;
	import net.play5d.kyo.stage.Istage;
	
	public class HostDetailDialog implements Istage
	{
		private var _ui:MovieClip;
		private var _data:HostVO;
		public function HostDetailDialog()
		{
		}
		
		public function get display():DisplayObject
		{
			return _ui;
		}
		
		public function build():void
		{
			_ui = UIAssetUtil.I.createDisplayObject("detail_win_mc");
			_ui.btn_join.addEventListener(MouseEvent.CLICK , joinHandler);
			_ui.btn_close.addEventListener(MouseEvent.CLICK , close);
		}
		
		public function setData(data:HostVO):void{
			_data = data;
			_ui.txt_name.text = data.name;
			_ui.txt_mode.text = "游戏模式："+data.getGameModeStr();
			_ui.txt_time.text = "创建时间："+LANUtils.getTimeStr(data.updateTime);
			
			if(data.password){
				initPass();
			}else{
				_ui.pass.visible = false;
			}
			
		}
		
		private function initPass():void{
			_ui.pass.visible = true;
			_ui.pass.correct.visible = false;
			_ui.pass.txt.addEventListener(Event.CHANGE , passChangeHandler);
		}
		
		private function passChangeHandler(e:Event):void{
			if(_ui.pass.txt.text == _data.password){
				_ui.pass.correct.visible = true;
			}else{
				_ui.pass.correct.visible = false;
			}
		}
		
		private function joinHandler(e:MouseEvent):void{
			
			SoundCtrl.I.sndConfrim();
			
			if(_data.password){
				if(_ui.pass.txt.text != _data.password){
					GameUI.alert('FAIL',"密码不正确");
					return;
				}
			}
			
			close();
			
			LANClientCtrl.I.join(_data,joinHostBack);
		}
		
		private function joinHostBack(succ:Boolean, msg:String):void{
			if(succ){
				var room:LANRoomState = new LANRoomState();
				MainGame.stageCtrl.removeAllLayer();
				MainGame.stageCtrl.goStage(room);
				room.clientMode(_data);
			}else{
				if(msg) GameUI.alert("FAILED", msg);
			}
		}
		
		
		private function close(...params):void{
			MainGame.stageCtrl.removeLayer(this);
		}
		
		public function afterBuild():void
		{
		}
		
		public function destory(back:Function=null):void
		{
			try{
				_ui.btn_join.removeEventListener(MouseEvent.CLICK , joinHandler);
				_ui.btn_close.removeEventListener(MouseEvent.CLICK , close);
			}catch(e:Error){}
		}
	}
}