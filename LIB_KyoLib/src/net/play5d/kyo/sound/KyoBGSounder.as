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
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;

	/**
	 * 背景音乐播放类
	 * @author Kyo
	 */
	public class KyoBGSounder
	{
		private static var _i:KyoBGSounder;
		public static function get I():KyoBGSounder{
			_i ||= new KyoBGSounder();
			return _i;
		}

		/**
		 * 音乐URL链接或者声音CLASS对象
		 */
		public var sound:Object;
		public var playing:Boolean;

		private var _snd:Sound;
		private var _channel:SoundChannel;
		private var _soundTransform:SoundTransform = new SoundTransform();
		private var _channelPausePosition:int;

		public function get volume():Number
		{
			return _soundTransform.volume;
		}

		public function set volume(value:Number):void
		{
			_soundTransform.volume = value;
			if(_channel) _channel.soundTransform = _soundTransform;
		}


		/**
		 * 播放背景音乐
		 * @param snd 为空时，播放sound对象
		 * @param isLoop 循环播放
		 */
		public function play(snd:Object = null, isLoop:Boolean = true):void{
			trace('bgm play');
			if(_snd) return;

			if(!snd){
				snd = sound;
			}
			if(snd){
				sound = snd;
			}else{
				trace('没有可播放的音乐');
				return;
			}
			if(sound is String) _snd = new Sound(new URLRequest(sound as String));
			if(sound is Class) _snd = new sound();
			if(sound is Sound) _snd = sound as Sound;

			playsnd(0, isLoop);
			playing = true;
		}

		/**
		 * 停止音乐
		 */
		public function stop():void{
			trace('bgm stop');
			if(_channel){
				_channel.stop();
				_channel = null;
			}
			if(_snd){
				try{
					_snd.close();
				}catch(e:Error){
					trace("KyoBGSounder",e);
				}
				_snd = null;
			}
			playing = false;
		}

		public function pause():void{
			trace('bgm pause');
			if(_channel){
				_channelPausePosition = _channel.position;
				_channel.stop();
			}
		}

		public function resume():void{
			trace('bgm resume');
			if(_channel){
//				_channel = _snd.play(_channelPausePosition, int.MAX_VALUE, _soundTransform);
				playsnd(_channelPausePosition);
			}
		}

		/**
		 * 关闭时打开；打开时关闭
		 */
		public function toogle():void{
			if(playing){
				stop();
			}else{
				play();
			}
		}

		private function playsnd(position:int = 0, isLoop:Boolean = true):void{
			if(!_snd) return;
			_channel = _snd.play(position, 1, _soundTransform);

			_channel.removeEventListener(Event.SOUND_COMPLETE, playCompleteHandler);

			if(isLoop){
				_channel.addEventListener(Event.SOUND_COMPLETE, playCompleteHandler);
			}
		}

		private function playCompleteHandler(e:Event):void{
			if(_channel){
				_channel.removeEventListener(Event.SOUND_COMPLETE, playCompleteHandler);
				_channel = null;
			}
			playsnd(0);
		}

	}
}
