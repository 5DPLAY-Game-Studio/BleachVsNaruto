package net.play5d.game.bvn.ui.fight
{
	import flash.display.DisplayObject;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextFormatAlign;
	
	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.fighter.FighterActionState;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.kyo.display.BitmapText;

	public class FighterHpBar
	{
		private var _ui:hpbar_barmc;
		private var _bar:DisplayObject;
		private var _redbar:DisplayObject;
		
		
		private var _fighter:FighterMain;
		private var _hprate:Number = 1;
//		private var _fighterData:FighterVO;
		private var _redBarMoving:Boolean;
		private var _redBarMoveDelay:int;
		private var _justHurtFly:Boolean;
		
		private var _hpText:BitmapText;
		private var _damageText:BitmapText;
		
		private var _direct:int;
		
		public function get ui():DisplayObject{
			return _ui;
		}
		
		public function FighterHpBar(ui:hpbar_barmc)
		{
			_ui = ui;
			_bar = _ui.bar;
			_redbar = _ui.redbar;
			
			if(GameUI.SHOW_HP_TEXT){
				_hpText = new BitmapText(true, 0xffffff, [new DropShadowFilter()]);
				_hpText.font = "Arial";
				_hpText.x = 120;
				_hpText.y = 2;
				ui.addChild(_hpText);
				
				_damageText = new BitmapText(true, 0xffff00, [new DropShadowFilter()]);
				_damageText.font = "Arial";
				_damageText.x = 10;
				_damageText.y = 2;
				_damageText.visible = false;
				ui.addChild(_damageText);
				
			}
			
		}
		
		public function setDirect(v:int):void{
			_direct = v;
			if(v < 0){
				if(_hpText) _hpText.scaleX = -1;
				if(_damageText){
					_damageText.scaleX = -1;
					_damageText.x = 40;
				}
			}
		}
		
		public function destory():void{
			_fighter = null;
			
			if(_hpText){
				_hpText.destory();
				_hpText = null;
			}
			
			if(_damageText){
				_damageText.destory();
				_damageText = null;
			}
		}
		
		public function setFighter(v:FighterMain):void{
			_fighter = v;
//			_fighterData = v.data;
		}
		
		public function render():void{
			var rate:Number = _fighter.hp / _fighter.hpMax;
			
			if(_redBarMoving && rate != _hprate){
				_redbar.scaleX = _hprate;
				_redBarMoving = false;
			}
			
			_hprate = rate;
			var diff:Number = _hprate - _bar.scaleX;
			var addRate:Number = diff < 0 ? 0.4 : 0.04;
			
			if(Math.abs(diff) < 0.01){
				_bar.scaleX = _hprate;
			}else{
				_bar.scaleX += diff * addRate;//0.4;
			}
			
			switch(_fighter.actionState){
				case FighterActionState.HURT_ING:
					_redBarMoveDelay = 100; //持续不减
					break;
				case FighterActionState.HURT_FLYING:
				case FighterActionState.HURT_DOWN:
					if(_redBarMoveDelay > 0){
						if(!_justHurtFly){
							_redBarMoveDelay = 1.5 * GameConfig.FPS_GAME;
							_justHurtFly = true;
						}else{
							if(_redBarMoveDelay > 0) _redBarMoveDelay--; //延时恢复
						}
					}
					break;
				default:
					_redBarMoveDelay = 0;
					_justHurtFly = false;
			}
			
			if(_redBarMoveDelay <= 0){
				var diff2:Number = _hprate - _redbar.scaleX;
				var addRate2:Number = diff2 < 0 ? 0.1 : 0.02;
				if(Math.abs(diff2) < 0.01){
					_redbar.scaleX = _hprate;
					_redBarMoving = false;
				}else{
					_redbar.scaleX += diff2 * addRate2;
					_redBarMoving = true;
				}
			}
			
			if(_hpText){
				_hpText.text = _fighter.hp.toString();
			}
			
			if(_damageText){
				if(_fighter.currentHurtDamage() > 0){
					_damageText.text = "-" + _fighter.currentHurtDamage().toString();
					_damageText.visible = true;
				}else{
					_damageText.visible = false;
				}
			}
			
		}
		
	}
}