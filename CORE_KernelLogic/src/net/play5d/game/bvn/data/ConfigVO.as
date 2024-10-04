package net.play5d.game.bvn.data
{
	import flash.display.StageQuality;
	import flash.ui.Keyboard;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.GameQuailty;
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.EffectCtrl;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.interfaces.GameInterface;
	import net.play5d.game.bvn.interfaces.IExtendConfig;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.kyo.utils.KyoUtils;

	public class ConfigVO implements ISaveData
	{
		public const key_menu:KeyConfigVO = new KeyConfigVO(0);
		public const key_p1:KeyConfigVO = new KeyConfigVO(1);
		public const key_p2:KeyConfigVO = new KeyConfigVO(2);

		public var select_config:SelectStageConfigVO = new SelectStageConfigVO();

		public var AI_level:int = 1;
		public var fighterHP:Number = 1; //HP比例
		public var fightTime:int = 60;
		public var quality:String = StageQuality.LOW;

		public var soundVolume:Number = 0.7; // SOUND音量
		public var bgmVolume:Number = 0.7; // BGM音量

		public var keyInputMode:int = 1; //0标准, 1经典（长按式）

		/**
		 * 扩展设置
		 */
		public var extendConfig:IExtendConfig;

		public function ConfigVO()
		{
			if(GameInterface.instance) extendConfig = GameInterface.instance.getConfigExtend();

			setDefaultConfig(key_menu);
			setDefaultConfig(key_p1);
			setDefaultConfig(key_p2);
		}

		public function setDefaultConfig(keyConfig:KeyConfigVO):void{
			switch(keyConfig.id){
				case 0: //MENU
					keyConfig.setKeys(
						Keyboard.W,Keyboard.S,Keyboard.A,Keyboard.D,
						Keyboard.J,Keyboard.K,Keyboard.L,
						Keyboard.U,Keyboard.I,Keyboard.O
					);
					keyConfig.selects = [Keyboard.J,Keyboard.K,Keyboard.L,Keyboard.U,Keyboard.I,Keyboard.O];
					break;
				case 1:
					keyConfig.setKeys(
						Keyboard.W,Keyboard.S,Keyboard.A,Keyboard.D,
						Keyboard.J,Keyboard.K,Keyboard.L,
						Keyboard.U,Keyboard.I,Keyboard.O
					);
					break;
				case 2:
					keyConfig.setKeys(
						Keyboard.UP,Keyboard.DOWN,Keyboard.LEFT,Keyboard.RIGHT,
						Keyboard.NUMPAD_1,Keyboard.NUMPAD_2,Keyboard.NUMPAD_3,
						Keyboard.NUMPAD_4,Keyboard.NUMPAD_5,Keyboard.NUMPAD_6
					);
					break;
			}
		}

		public function toSaveObj():Object{
			var o:Object = {};
			o.key_p1 = key_p1.toSaveObj();
			o.key_p2 = key_p2.toSaveObj();

			o.AI_level = AI_level;
			o.fighterHP = fighterHP;
			o.fightTime = fightTime;
			o.quality = quality;
			o.keyInputMode = keyInputMode;
			o.soundVolume = soundVolume;
			o.bgmVolume = bgmVolume;

			if(extendConfig) o.extend_config = extendConfig.toSaveObj();

			return o;
		}

		public function readSaveObj(o:Object):void{
			key_p1.readSaveObj(o.key_p1);
			key_p2.readSaveObj(o.key_p2);

			if(o.extend_config && extendConfig){
				extendConfig.readSaveObj(o.extend_config);
			}

			delete o['key_p1'];
			delete o['key_p2'];

			KyoUtils.setValueByObject(this,o);
		}

		public function getValueByKey(key:String):*{
			if(this.hasOwnProperty(key)){
				return this[key];
			}
			if(extendConfig){
				try{
					return extendConfig[key];
				}catch(e:Error){
					trace(e);
				}
			}
			return null;
		}

		public function setValueByKey(key:String , value:*):void{
			if(this.hasOwnProperty(key)){
				this[key] = value;

				switch(key){
					case 'bgmVolume':
						SoundCtrl.I.setBgmVolumn(bgmVolume);
						break;
					case 'soundVolume':
						SoundCtrl.I.setSoundVolumn(soundVolume);
						break;
				}

				return;
			}
			if(extendConfig){
				try{
					extendConfig[key] = value;
				}catch(e:Error){
					trace(e);
				}
			}
		}


//		/**
//		 * 扩展设置
//		 * @param key
//		 * @param value
//		 */
//		public function setExtend(key:String , value:Object):void{
//			extendObj ||= {};
//			extendObj[key] = value;
//		}

		public function applyConfig():void{
			switch(quality)
			{
				case GameQuailty.LOW:
					GameConfig.QUALITY_GAME = StageQuality.LOW;
					GameConfig.setGameFps(30);
					GameConfig.FPS_SHINE_EFFECT = 15;
					EffectCtrl.EFFECT_SMOOTHING = false;
					break;
				case GameQuailty.MEDIUM:
					GameConfig.QUALITY_GAME = StageQuality.LOW;
					GameConfig.setGameFps(60);
					GameConfig.FPS_SHINE_EFFECT = 30;
					EffectCtrl.EFFECT_SMOOTHING = false;
					break;
				case GameQuailty.HIGH:
					GameConfig.QUALITY_GAME = StageQuality.MEDIUM;
					GameConfig.setGameFps(60);
					GameConfig.FPS_SHINE_EFFECT = 30;
					EffectCtrl.EFFECT_SMOOTHING = false;
					break;
				case GameQuailty.HIGHER:
					GameConfig.QUALITY_GAME = StageQuality.HIGH;
					GameConfig.setGameFps(60);
					GameConfig.FPS_SHINE_EFFECT = 30;
					EffectCtrl.EFFECT_SMOOTHING = true;
					break;
				case GameQuailty.BEST:
					GameConfig.QUALITY_GAME = StageQuality.HIGH;
					GameConfig.setGameFps(60);
					GameConfig.FPS_SHINE_EFFECT = 60;
					EffectCtrl.EFFECT_SMOOTHING = true;
					break;
			}

			GameInterface.instance.applyConfig(this);
			SoundCtrl.I.setBgmVolumn(bgmVolume);
			SoundCtrl.I.setSoundVolumn(soundVolume);

		}



	}
}
