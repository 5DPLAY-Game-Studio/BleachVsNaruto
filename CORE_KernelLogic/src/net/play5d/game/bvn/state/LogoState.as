package net.play5d.game.bvn.state
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.stage.Istage;
	
	public class LogoState implements Istage
	{
		private var _ui:logo_movie;
		
		public function LogoState()
		{
		}
		
		public function get display():DisplayObject
		{
			return _ui;
		}
		
		public function build():void
		{
			_ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.common_ui , 'logo_movie');
			_ui.addEventListener(Event.COMPLETE,playComplete);
			_ui.gotoAndPlay(2);
		}
		
		private function playComplete(e:Event):void{
			_ui.removeEventListener(Event.COMPLETE,playComplete);
			MainGame.I.goMenu();
		}
		
		public function afterBuild():void
		{
		}
		
		public function destory(back:Function=null):void
		{
			_ui.removeEventListener(Event.COMPLETE,playComplete);
		}
	}
}