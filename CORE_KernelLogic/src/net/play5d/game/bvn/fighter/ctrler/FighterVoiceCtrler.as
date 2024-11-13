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

package net.play5d.game.bvn.fighter.ctrler
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;

	import net.play5d.game.bvn.data.GameData;
	import net.play5d.kyo.utils.KyoRandom;

	public class FighterVoiceCtrler
	{
		include "_INCLUDE_.as";

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
