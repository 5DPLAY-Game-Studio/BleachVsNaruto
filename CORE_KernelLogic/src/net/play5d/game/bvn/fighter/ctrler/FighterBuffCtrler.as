package net.play5d.game.bvn.fighter.ctrler
{
	import net.play5d.game.bvn.ctrl.EffectCtrl;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.fighter.vos.FighterBuffVO;

	public class FighterBuffCtrler
	{
		private var _fighter:FighterMain;

		private var _speed:Number = 0;
		private var _attackRate:Number = 0;
		private var _buffObj:Object = {};



		public function FighterBuffCtrler(fighter:FighterMain)
		{
			_fighter = fighter;
		}

		public function destory():void{
			_fighter = null;
		}

		public function speedUp(upVal:Number = 0, hold:Number = 5):void{
			var buff:FighterBuffVO = addBuff('speed', upVal, hold);
			if(!buff) return;
//			_fighter.getCtrler().getEffectCtrl().
			EffectCtrl.I.doEffectById("buff_effect_speed",_fighter.x, _fighter.y);
			EffectCtrl.I.doBuffEffect("buff_speed", _fighter, buff);
		}

		public function attackUp(rateVal:Number = 0, hold:Number = 5):void{
			var buff:FighterBuffVO = addBuff('attackRate', rateVal, hold);
			if(!buff) return;
			EffectCtrl.I.doEffectById("buff_effect_power",_fighter.x, _fighter.y);
			EffectCtrl.I.doBuffEffect("buff_power", _fighter, buff);
		}

		public function defenseUp(upVal:Number = 0, hold:Number = 5):void{
			var buff:FighterBuffVO = addBuff('defenseRate', upVal, hold);
			if(!buff) return;
			EffectCtrl.I.doEffectById("buff_effect_defense",_fighter.x, _fighter.y);
			EffectCtrl.I.doBuffEffect("buff_defense", _fighter, buff);
		}

		public function speedDown(downVal:Number = 0, hold:Number = 5):void{
			addBuff('speed', -downVal, hold);
		}

		public function attackDown(rateVal:Number = 0, hold:Number = 5):void{
			addBuff('attackRate', rateVal, hold);
		}

		public function defenseDown(downVal:Number = 0, hold:Number = 5):void{
			addBuff('defense', -downVal, hold);
		}

		private function addBuff(param:String, value, hold:Number):FighterBuffVO{
			try{
				var buff:FighterBuffVO = _buffObj[param];
				if(!buff){
					buff = new FighterBuffVO(param, hold);
					_buffObj[param] = buff;
					buff.resumeValue = _fighter[param];
				}else{
					buff.setHold(hold);
				}
				_fighter[param] = buff.resumeValue + value;
				return buff;
			}catch(e:Error){
				trace(e);
				return null;
			}

			return null;
		}

		public function render():void{
			for(var i:String in _buffObj){
				var b:FighterBuffVO = _buffObj[i];
				if(b.render()){
					_fighter[b.param] = b.resumeValue;
					delete _buffObj[i];
				}
			}
		}



	}
}
