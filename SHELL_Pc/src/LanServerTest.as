package
{
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import net.play5d.game.bvn.debug.Debugger;
	import net.play5d.game.bvn.GameQuailty;
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.GameMode;
	import net.play5d.game.bvn.interfaces.GameInterface;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.game.bvn.utils.GameLoger;
	import net.play5d.game.bvn.utils.URL;
	import net.play5d.game.bvn.win.GameInterfaceManager;
	import net.play5d.game.bvn.win.ctrls.LANClientCtrl;
	import net.play5d.game.bvn.win.ctrls.LANGameCtrl;
	import net.play5d.game.bvn.win.ctrls.LANServerCtrl;
	import net.play5d.game.bvn.win.data.HostVO;
	import net.play5d.game.bvn.win.utils.Loger;
	import net.play5d.game.bvn.win.utils.UIAssetUtil;
	
	[SWF(width="800", height="600", frameRate="30", backgroundColor="#000000")]
	public class LanServerTest extends Sprite
	{
		private var _mainGame:MainGame;
		
		public function LanServerTest()
		{
			if(stage){
				initlize();
			}else{
				addEventListener(Event.ADDED_TO_STAGE,initlize);
			}
		}
		
		private function initlize(e:Event = null):void{
			
			GameLoger.setLoger(new Loger());
			
			GameLoger.log("init...");
			
			removeEventListener(Event.ADDED_TO_STAGE,initlize);
			
			GameInterface.instance = new GameInterfaceManager();
			
			GameInterfaceManager.config.isFullScreen = false;
			
//			if(GameInterfaceManager.config.isFullScreen){
//				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
//			}
			
			GameUI.BITMAP_UI = true;
			
			GameData.I.config.AI_level = 1;
			GameData.I.config.quality = GameQuailty.MEDIUM;
			GameData.I.config.keyInputMode = 0;
			
			URL.MARK = 'bvn_win'+MainGame.VERSION;
			
			buildGame();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
			
			setWindowTemp();
			
		}
		
		private function buildGame():void{
			
			GameLoger.log("buildGame");
			
			_mainGame = new MainGame();
			_mainGame.initlize(this , stage , initBackHandler , initFailHandler);
			if(Debugger.DEBUG_ENABLED) Debugger.initDebug(stage);
			
		}
		
		private function initBackHandler():void{
			
			GameLoger.log("init ok");
			
			UIAssetUtil.I.initalize(testServer);
			//			_mainGame.goMenu();
			//			_mainGame.goCongratulations();
		}
		
		private function initFailHandler(msg:String):void{
			GameLoger.log("init fail");
		}
		
		private function keyDownHandler(e:KeyboardEvent):void{
			if(e.keyCode == Keyboard.ESCAPE){
				e.preventDefault();
			}
//			if(e.keyCode == Keyboard.F11){
//				if(stage.displayState == StageDisplayState.NORMAL){
//					stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
//				}else{
//					stage.displayState = StageDisplayState.NORMAL;
//				}
//			}
		}
		
		private function setWindowTemp():void{
			setTimeout(function():void{
				
//				NativeApplication.nativeApplication.activeWindow.width = 400;
//				NativeApplication.nativeApplication.activeWindow.height = 300;
//				NativeApplication.nativeApplication.activeWindow.x = 10;
//				NativeApplication.nativeApplication.activeWindow.y = 500;
				
				NativeApplication.nativeApplication.activeWindow.width = 800;
				NativeApplication.nativeApplication.activeWindow.height = 600;
				NativeApplication.nativeApplication.activeWindow.x = 0;
				NativeApplication.nativeApplication.activeWindow.y = 100;
			},200);
		}
		
		private function testServer():void{
			var host:HostVO = new HostVO();
			host.ip = "127.0.0.1";
			host.tcpPort = LANGameCtrl.PORT_TCP;
			host.udpPort = LANGameCtrl.PORT_UDP_SERVER;
			LANServerCtrl.I.startServer(host);
			LANServerCtrl.I.onPlayerJoinSuccess = onJoinSucc;
		}
		
		private function onJoinSucc():void{
			LANServerCtrl.I.gameStart();
			GameMode.currentMode = GameMode.TEAM_VS_PEOPLE;
			MainGame.I.goSelect();
		}
		
	}
}