package net.play5d.kyo.sound
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	
	import net.play5d.kyo.utils.KyoRandom;
	import net.play5d.kyo.utils.KyoUtils;

	public class KyoMp3Player
	{
		public static const MODE_ALL_LOOP:String = 'all_loop_mode';
		public static const MODE_ONE_LOOP:String = 'one_loop_mode';
		public static const MODE_ALL_ONCE:String = 'all_once_mode';
		public static const MODE_ONE_ONCE:String = 'one_once_mode';
		public static const MODE_RANDOM:String = 'random_mode';
		
		public var playMode:String;
		
		public var list:Array = [];
		private var _sound:Sound;
		private var _channel:SoundChannel;
		private var _current:String;
		private var _pausedPos:int;
		
		public function KyoMp3Player()
		{
		}
		
		public function play(v:String = null):void{
			if(!v){
				if(_pausedPos > 0){
					_channel = _sound.play(_pausedPos);
					return;
				}
				if(list && list.length > 0){
					v = list[0];
				}else{
					throw new Error('mp3 list 为空，不能播放音乐');
				}
			}
			
			
			stop();
			_pausedPos = 0;
			_current = v;
			KyoUtils.array_push_notHas(list,v);
			
			_sound = new Sound(new URLRequest(v));
			_channel = _sound.play();
			_channel.addEventListener(Event.SOUND_COMPLETE,onSoundComplete);
			
		}
		
		public function stop():void{
			if(_channel){
				_channel.removeEventListener(Event.SOUND_COMPLETE,onSoundComplete);
				_channel.stop();
				_channel = null;
				_sound = null;
			}
		}
		
		public function pause():void{
			_pausedPos = _channel.position;
			_channel.stop();
		}
		
		public function next(loop:Boolean = true):void{
			if(!list) return;
			var id:int = list.indexOf(_current) + 1;
			if(id >= list.length){
				if(loop){
					id = 0;
				}else{
					stop();
					return;
				}
			} 
			play(list[id]);
		}
		
		public function prev(loop:Boolean = true):void{
			if(!list) return;
			var id:int = list.indexOf(_current) - 1;
			if(id < 0){
				if(loop){
					id = list.length - 1;
				}else{
					stop();
					return;
				}
			} 
			play(list[id]);
		}
		
		
		private function onSoundComplete(e:Event):void{
			_channel.removeEventListener(Event.SOUND_COMPLETE,onSoundComplete);
			
			switch(playMode){
				case MODE_ALL_LOOP:
					next();
					break;
				case MODE_ALL_ONCE:
					next(false);
					break;
				case MODE_ONE_LOOP:
					play(_current);
					break;
				case MODE_ONE_ONCE:
					stop();
					break;
				case MODE_RANDOM:
					play(KyoRandom.getRandomInArray(list));
					break;
			}
		}
		
		

	}
}