package net.play5d.game.bvn.win.views.lan
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.game.bvn.win.ctrls.LANGameCtrl;
	import net.play5d.game.bvn.win.ctrls.LANServerCtrl;
	//import net.play5d.game.bvn.win.ctrls.UDPHostCtrl;
	import net.play5d.game.bvn.win.data.HostVO;
	import net.play5d.game.bvn.win.data.LanGameModel;
	import net.play5d.game.bvn.win.utils.UIAssetUtil;
	import net.play5d.kyo.stage.Istage;
	import net.play5d.kyo.utils.KyoBtnUtils;

	public class LANHostCreateDialog implements Istage
	{
		private var _ui:MovieClip;

		public var onCreate:Function;
		public var onClose:Function;

		public function LANHostCreateDialog()
		{
		}

		public function get display():DisplayObject
		{
			return _ui;
		}

		public function close():void{
			if(onClose != null) onClose();
			MainGame.stageCtrl.removeLayer(this);
		}

		public function build():void
		{
			_ui = UIAssetUtil.I.createDisplayObject("build_win_mc");
			_ui.check_pass.addEventListener(Event.CHANGE , checkHandler);

			KyoBtnUtils.initBtn(_ui.btn_ok , btnHandler);
			KyoBtnUtils.initBtn(_ui.btn_close , close);

			_ui.txt_pass.visible = false;

			_ui.comb_mode.addItem( { label: "TEAM VS - 小队模式", data:1 } );
//			_ui.comb_mode.addItem( { label: "SINGLE VS - 单人模式", data:2 } );
		}

		private function btnHandler():void{

			SoundCtrl.I.sndConfrim();

			var name:String = _ui.txt_hostname.text;
			var pass:String = "";
			var mode:int = _ui.comb_mode.selectedItem.data;

			if(name == ""){
				GameUI.alert("ERROR","请输入主机名称");
				return;
			}

			if(_ui.check_pass.selected){
				pass = _ui.txt_pass.text;
			}

			var hv:HostVO = new HostVO();
			hv.name = name;
			hv.gameMode = mode;
			hv.password = pass;
			hv.ownerName = LanGameModel.I.playerName;
			hv.tcpPort = LANGameCtrl.PORT_TCP;
			hv.udpPort = LANGameCtrl.PORT_UDP_SERVER;

			LANServerCtrl.I.startServer(hv);

			if(onCreate != null) onCreate();

			close();
		}

		private function checkHandler(e:Event):void{
			_ui.txt_pass.visible = _ui.check_pass.selected;
		}

		public function afterBuild():void
		{
		}

		public function destory(back:Function=null):void
		{
			_ui.btn_ok.removeEventListener(MouseEvent.CLICK , btnHandler);
			_ui.check_pass.removeEventListener(Event.CHANGE , checkHandler);

			KyoBtnUtils.disposeBtn(_ui.btn_ok);
			KyoBtnUtils.disposeBtn(_ui.btn_close);

		}
	}
}
