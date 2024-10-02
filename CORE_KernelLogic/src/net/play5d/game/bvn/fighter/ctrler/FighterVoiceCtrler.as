package net.play5d.game.bvn.fighter.ctrler
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.kyo.utils.KyoRandom;

	public class FighterVoiceCtrler
	{
		public function FighterVoiceCtrler()
		{
			_soundTransform = new SoundTransform();
			_soundTransform.volume = GameData.I.config.soundVolume;
		}
		
		private var _voiceObj:Object = {};
		
		private var _channel:SoundChannel;
		private var _curLength:int;
		private var _soundTransform:SoundTransform;
		
		public function destory():void{
			if(_voiceObj){
				_voiceObj = null;
			}
			if(_channel){
				_channel.stop();
				_channel = null;
			}
		}
		
		public function setVoice(id:int , sounds:Array):void{
			_voiceObj[id] = sounds;
		}
		
		public function playVoice(id:int , rate:Number = 1):void{
			
			if(_channel && _channel.position < _curLength) return;
			if(Math.random() > rate) return;
			
			var sounds:Array = _voiceObj[id];
			if(sounds && sounds.length > 0){
				var snd:Class = sounds.length > 1 ? KyoRandom.getRandomInArray(sounds) : sounds[0];
				
				if(snd){
					var sound:Sound = new snd();
					_curLength = sound.length;
					_channel = sound.play(0, 0, _soundTransform);
				}
				
			}
		}
		
	}
}