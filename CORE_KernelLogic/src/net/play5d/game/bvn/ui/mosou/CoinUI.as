package net.play5d.game.bvn.ui.mosou
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.events.GameEvent;
	import net.play5d.game.bvn.interfaces.GameInterface;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.game.bvn.ui.Text;
	import net.play5d.game.bvn.utils.BtnUtils;

	public class CoinUI
	{
		public static var ADD_ABLE:Boolean = true;
		private var _ui:MovieClip;
		private var _moneyTxt:Text;
		public function CoinUI(ui:MovieClip)
		{
			_ui = ui;
			_moneyTxt = new Text(0xFFFFFF, 16);
			_moneyTxt.x = 45;
			_moneyTxt.y = 12;
			_moneyTxt.width = 70;
			_moneyTxt.align = TextFormatAlign.CENTER;
			
			if(ADD_ABLE){
				_ui.gotoAndStop(1);
				BtnUtils.btnMode(_ui);
				BtnUtils.initBtn(_ui, clickHandler);
			}else{
				_ui.gotoAndStop(2);
			}
			
			GameEvent.addEventListener(GameEvent.MONEY_UPDATE, update);
			
			update();
		}
		
		public function destory():void{
			GameEvent.removeEventListener(GameEvent.MONEY_UPDATE, update);
		}
		
		private function update(...param):void{
			_ui.addChild(_moneyTxt);
			_moneyTxt.text = GameData.I.mosouData.getMoney().toString();
		}
		
		private function clickHandler(b:*):void{
			GameInterface.addMoney(addMoneyBack);
		}
		
		private function addMoneyBack(money:int):void{
			GameUI.alert('MONEY', '获得金币 ' + money +' !');
			GameData.I.mosouData.addMoney(money);
		}
		
	}
}