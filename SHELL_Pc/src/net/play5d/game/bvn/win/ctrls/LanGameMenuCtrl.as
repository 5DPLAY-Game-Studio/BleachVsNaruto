package net.play5d.game.bvn.win.ctrls
{
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.game.bvn.utils.KeyBoarder;
	import net.play5d.game.bvn.win.views.lan.LANExitDialog;

	public class LanGameMenuCtrl
	{
		
		private static var _i:LanGameMenuCtrl;
		
		public static function get I():LanGameMenuCtrl{
			_i ||= new LanGameMenuCtrl();
			return _i;
		}
		
		private var _isKeyDown:Boolean;
		
		private var _exitDialog:LANExitDialog;
		
		public function LanGameMenuCtrl()
		{
		}
		
		public function init():void{
			
			_exitDialog = new LANExitDialog();
			_exitDialog.hide();
			KeyBoarder.listen(keyHandler);
		}
		
		public function dispose():void{
			if(_exitDialog){
				try{
					MainGame.I.root.removeChild(_exitDialog);
				}catch(e:Error){
					trace(e);
				}
				_exitDialog.destory();
				_exitDialog = null;
			}
			
			KeyBoarder.unListen(keyHandler);
			
			_isKeyDown = false;
			
		}
		
		private function keyHandler(e:KeyboardEvent):void{
			
			if(e.type == KeyboardEvent.KEY_DOWN){
				if(_isKeyDown) return;
				if(!_exitDialog) return;
				if(e.keyCode == Keyboard.ESCAPE){
					_isKeyDown = true;
					if(_exitDialog.isShowing()){
						_exitDialog.hide();
					}else{
						MainGame.I.root.addChild(_exitDialog);
						_exitDialog.show();
					}
				}
			}
			
			if(e.type == KeyboardEvent.KEY_UP){
				if(e.keyCode == Keyboard.ESCAPE){
					_isKeyDown = false;
				}
			}
			
		}
		
	}
}