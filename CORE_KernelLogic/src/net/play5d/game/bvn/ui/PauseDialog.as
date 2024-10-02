package net.play5d.game.bvn.ui
{
	import flash.display.Sprite;
	import flash.events.DataEvent;
	
	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
	import net.play5d.game.bvn.events.GameEvent;
	import net.play5d.game.bvn.events.SetBtnEvent;

	public class PauseDialog extends Sprite
	{
		private var _bg:Sprite;
		private var _btnGroup:SetBtnGroup;
		private var _moveList:MoveListSp;
		
		public function PauseDialog()
		{
			_bg = new Sprite();
			_bg.graphics.beginFill(0,0.5);
			_bg.graphics.drawRect(0,0,GameConfig.GAME_SIZE.x , GameConfig.GAME_SIZE.y);
			_bg.graphics.endFill();
			
			addChild(_bg);
			
			_btnGroup = new SetBtnGroup();
			_btnGroup.setBtnData([
				{label:'GAME TITLE',cn:'返回标题'},
				{label:'MOVE LIST',cn:'出招表'},
				{label:'CONTINUE',cn:'继续游戏'}
			],2);
			_btnGroup.addEventListener(SetBtnEvent.SELECT,btnGroupSelectHandler);
			
			addChild(_btnGroup);
		}
		
		public function destory():void{
			if(_btnGroup){
				_btnGroup.removeEventListener(SetBtnEvent.SELECT,btnGroupSelectHandler);
				_btnGroup.destory();
				_btnGroup = null;
			}
			if(_moveList){
				_moveList.destory();
				_moveList = null;
			}
		}
		
		public function isShowing():Boolean{
			return visible;
		}
		
		public function show():void{
			this.visible = true;
			_btnGroup.keyEnable = true;
			_btnGroup.setArrowIndex(2);
		}
		
		public function hide():Boolean{
			if(_moveList && _moveList.isShowing()){
				hideMoveList();
				return false;
			}
			
			
			this.visible = false;
			_btnGroup.keyEnable = false;
//			GameUI.closeConfrim();
			return true;
		}
		
		private function btnGroupSelectHandler(e:SetBtnEvent):void{
			if(GameUI.showingDialog()) return;
			switch(e.selectedLabel){
				case 'GAME TITLE':
					_btnGroup.keyEnable = false;
					GameUI.confrim('BACK TITLE?',"返回到主菜单？", function():void{
						MainGame.I.goMenu();
					},function():void{
						_btnGroup.keyEnable = true;
					});
					break;
				case 'MOVE LIST':
					showMoveList();
					GameEvent.dispatchEvent(GameEvent.PAUSE_GAME_MENU, "movelist");
					break;
				case 'CONTINUE':
					GameCtrl.I.resume(true);
					break;
			}
		}
		
		private function showMoveList():void{
			if(!_moveList){
				_moveList = new MoveListSp();
				_moveList.onBackSelect = hideMoveList;
				addChild(_moveList);
			}
			
			_btnGroup.keyEnable = false;
			_moveList.show();
		}
		
		private function hideMoveList():void{
			_moveList.hide();
			_btnGroup.keyEnable = true;
			GameEvent.dispatchEvent(GameEvent.PAUSE_GAME_MENU, "movelist-back");
		}
		
	}
}