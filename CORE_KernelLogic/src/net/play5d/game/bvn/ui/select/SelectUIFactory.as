package net.play5d.game.bvn.ui.select
{
	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.input.GameInputType;
	import net.play5d.game.bvn.utils.ResUtils;

	public class SelectUIFactory
	{
		public function SelectUIFactory()
		{
		}
		
		public static function createSelecter(playerType:int = 1):SelecterItemUI{
			var ui:SelecterItemUI = new SelecterItemUI(playerType);
			
			ui.inputType = playerType == 1 ? GameInputType.P1 : GameInputType.P2;
			ui.selectVO = playerType == 1 ? GameData.I.p1Select : GameData.I.p2Select;
			
			var groupClassName:String = playerType == 1 ? 'selected_item_p1_mc' : 'selected_item_p2_mc';
			
			var groupClass:Class = ResUtils.I.getItemClass(ResUtils.swfLib.select , groupClassName);
			
			var group:SelectedFighterGroup = new SelectedFighterGroup(groupClass);
			group.x = playerType == 1 ? 10 : GameConfig.GAME_SIZE.x - 265;
			group.y = GameConfig.GAME_SIZE.y - 80;
			
			group.addFighter(null);
			
			ui.group = group;
			
			return ui;
		}
		
		
	}
}