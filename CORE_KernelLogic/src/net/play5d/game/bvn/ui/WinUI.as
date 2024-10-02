package net.play5d.game.bvn.ui
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	import net.play5d.game.bvn.data.FighterVO;

	public class WinUI
	{
		private var _ui:winmc;
		private var _team:int;
		
		public function get ui():DisplayObject{
			return _ui;
		}
		
		public function WinUI(ui:winmc , team:int)
		{
			_ui = ui;
			_team = team;
		}
		
		public function show(fighter:FighterVO , wins:int):void{
			if(!fighter) return;
			
			var playmc:MovieClip;
			
			switch(wins){
				case 1:
					playmc = _team == 1 ? _ui.w1 : _ui.w2;
					break;
				case 2:
					playmc = _team == 1 ? _ui.w2 : _ui.w1;
					break;
			}
			
			if(!playmc) return;
			
			switch(fighter.comicType){
				case 0:
					playmc.gotoAndPlay('in_bleach');
					break;
				case 1:
					playmc.gotoAndPlay('in_naruto');
					break;
			}
			
		}
		
	}
}