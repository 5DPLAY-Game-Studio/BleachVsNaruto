/*
 * Copyright (C) 2021-2024, 5DPLAY Game Studio
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package net.play5d.kyo.sound
{
	import flash.display.Stage;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.getTimer;

	import net.play5d.kyo.utils.KyoRandom;

	public class KyoSoundPlayer
	{
		private static var _i:KyoSoundPlayer;
		public static function get I():KyoSoundPlayer{
			_i ||= new KyoSoundPlayer();
			return _i;
		}

		private var _sounds:Object = {};
		private var _defaultValue:Number = 1;
		private var _lastPlay:int;

		public function KyoSoundPlayer()
		{
		}

		/**
		 * 播放声音
		 * @param s 声音对象或者对象Class
		 * @param channelId 声道ID，在同一声道ID中，只能有一个声音在播放，-1则没有限制
		 * @param gap 播放间隔(毫秒)，仅当 channelId = -1 时有效
		 * @param loops 循环次数
		 * @param volume 音量，-1时，使用全局 / 声道音量
		 * @param merge 是否覆盖声道中的声音
		 */
		public function playSound(s:Object , channelId:int = -1 , gap:int = 100 , loops:int = 0 , volume:Number = -1 , merge:Boolean = false , onComplete:Function = null):void{
			var snd:Sound = getSound(s);
			if(!snd) return;
			if(channelId == -1){
				if(getTimer() - _lastPlay < gap) return;
				if(volume == -1) volume = _defaultValue;
				snd.play(0,loops,new SoundTransform(volume));
				_lastPlay = getTimer();
				return;
			}
			if(_sounds[channelId]){
				var c:InsSound = _sounds[channelId] as InsSound;
				if(!merge && c.playing) return;
				if(volume == -1) volume = c.volume;
				c.stop();
			}
			var ins:InsSound = new InsSound(snd);
			ins.play(loops , volume);
			ins.onComplete = onComplete;
			_sounds[channelId] = ins;
		}

		/**
		 * 停止声音
		 * @param channelId 声道ID，停止此声道的声音
		 */
		public function stopSound(channelId:int = -1):void{
			var c:InsSound = _sounds[channelId] as InsSound;
			if(c)c.stop();
		}

		/**
		 * 停止所有声音
		 * @param clean 是否清空声道
		 */
		public function stopAllSounds(clean:Boolean = false):void{
			for each(var i:InsSound in _sounds) i.stop();
			if(clean) _sounds = null;
		}

		/**
		 * 是否正在播放声音
		 * @param channelId 声道ID
		 */
		public function playingSound(channelId:int = -1):Boolean{
			var c:InsSound = _sounds[channelId] as InsSound;
			if(c) return c.playing;
			return false;
		}

		/**
		 * 设置音量
		 * @param volume 音量：0 ~ 1
		 * @param channelId 声道，-1时，设置所有音量
		 */
		public function setVolume(volume:Number , channelId:int = -1):void{
			if(channelId == -1){
				_defaultValue = volume;
				for each(var i:InsSound in _sounds){
					i.volume = volume;
				}
				return;
			}
			if(_sounds[channelId]) (_sounds[channelId] as InsSound).volume = volume;
		}

		private function getSound(s:Object):Sound{
			var snd:Sound;
			if(s is Array) s = KyoRandom.getRandomInArray(s as Array);
			if(s is Class) snd = new s();
			if(s is Sound) snd = s as Sound;
			return snd;
		}

	}
}
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

internal class InsSound{
	private var _channel:SoundChannel;
	private var _volume:Number;
	private var _sound:Sound;
	private var _loop:int;
	public var playing:Boolean;
	public var onComplete:Function;
	public function InsSound(sound:Sound):void{
		_sound = sound;
	}

	public function play(loop:int , volume:Number):void{
		_volume = volume;
		_loop = loop;
		playsound();
	}
	public function stop():void{
		if(_channel) _channel.stop();
		playing = false;
	}

	public function get volume():Number{
		return _volume;
	}
	public function set volume(v:Number):void{
		_volume = v;
		var pos:Number = _channel.position;
		playsound(pos);
	}

	private function playsound(startTime:Number = 0):void{
		stop();
		playing = true;
		_channel = _sound.play(startTime , _loop , new SoundTransform(_volume));
		_channel.addEventListener(Event.SOUND_COMPLETE , soundComplete);
	}

	private function soundComplete(e:Event):void{
		_channel.removeEventListener(Event.SOUND_COMPLETE , soundComplete);
		playing = false;
		if(onComplete != null) onComplete();
	}
}
