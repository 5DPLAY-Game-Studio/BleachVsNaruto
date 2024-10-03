package net.play5d.game.bvn.win {
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
	import net.play5d.game.bvn.data.GameData;
	
	public class MosouDebugger {
		
		
		public function MosouDebugger() {
			super();
		}
		
		public static function init(param1:Stage) : void {
			param1.addEventListener("keyUp",keyHandler);
		}
		
		private static function keyHandler(param1:KeyboardEvent) : void {
			switch(int(param1.keyCode) - 112) {
				case 0:
					GameData.I.mosouData.addMoney(100000);
					break;
				case 1:
					GameData.I.mosouData.addFighterExp(100000);
					break;
				case 2:
					GameCtrl.I.getMosouCtrl().anyWaypassMission();
			}
		}
	}
}
