package net.play5d.game.bvn.win.views.lan
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.events.SetBtnEvent;
	import net.play5d.game.bvn.ui.SetBtnGroup;
	import net.play5d.game.bvn.win.utils.UIAssetUtil;
	import net.play5d.kyo.stage.Istage;
	
	public class LANGameState implements Istage
	{
		private var _ui:Sprite;
		private var _btnGroup:SetBtnGroup;
		private var _hostList:HostListDialog;
		
		public function LANGameState()
		{
			super();
		}
		
		public function get display():DisplayObject{
			return _ui;
		}
		
		public function build():void{
			_ui = UIAssetUtil.I.createDisplayObject("spr_lan");
			
			_btnGroup = new SetBtnGroup();
			_btnGroup.setBtnData([
				{label:"JOIN GAME",cn:"加入游戏"},
				{label:"BUILD GAME",cn:"创建游戏"},
				{label:"PROFILE",cn:"个人信息"},
				{label:"EXIT",cn:"退出"}
			]);
			
			_btnGroup.addEventListener(SetBtnEvent.SELECT,btnHandler);
			
			_ui.addChild(_btnGroup);
			
			SoundCtrl.I.BGM(AssetManager.I.getSound('continue'));
//			
//			_hostList.ui.x = 20;
//			_hostList.ui.y = 50;
//			
//			_ui.addChild(_hostList.ui);
		}
		
		public function showHostList():void{
			_btnGroup.keyEnable = false;
			_hostList = new HostListDialog();
			_hostList.onClose = onDialogClose;
			MainGame.stageCtrl.addLayer(_hostList,10,10);
		}
		
		private function btnHandler(e:SetBtnEvent):void{
			switch(e.selectedLabel){
				case "JOIN GAME":
					showHostList();
					break;
				case "BUILD GAME":
					_btnGroup.keyEnable = false;
					var dialog:LANHostCreateDialog = new LANHostCreateDialog();
					dialog.onCreate = onCreateHost;
					dialog.onClose = onDialogClose;
					MainGame.stageCtrl.addLayer(dialog,0,0);
					break;
				case "PROFILE":
					_btnGroup.keyEnable = false;
					var dialog2:ProfileDialog = new ProfileDialog();
					dialog2.onClose = onDialogClose;
					MainGame.stageCtrl.addLayer(dialog2,0,0);
					break;
				case "EXIT":
					MainGame.I.goMenu();
					break;
			}
		}
		
		private function onDialogClose():void{
			if(_btnGroup) _btnGroup.keyEnable = true;
		}
		
		private function onCreateHost():void{
			var room:LANRoomState = new LANRoomState();
			MainGame.stageCtrl.goStage(room);
			room.hostMode();
		}
		
		public function afterBuild():void{
			
		}
		
		public function destory(back:Function = null):void{
			if(_btnGroup){
				_btnGroup.destory();
				_btnGroup = null;
			}
		}
		
		
	}
}