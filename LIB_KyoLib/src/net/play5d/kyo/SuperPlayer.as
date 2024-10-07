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

package net.play5d.kyo
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;

	/**
	 * 超级播放器,v1.3
	 * @author kyo
	 */
	public class SuperPlayer extends Sprite
	{
		public static const EVENT_LOAD_COMPLETE:String = 'load_complete';
		public static const EVENT_PLAY_COMPLETE:String = 'play_complete';

		public static const EVENT_LOAD_FAIL:String = 'load_fail';

		public static const TYPE_FLASH:String = 'type_is_flash';
		public static const TYPE_VIDEO:String = 'type_is_video';
		public static const TYPE_BITMAP:String = 'type_is_bitmap';

//		public var content:DisplayObject;
		public var type:String;
		public var autoPlay:Boolean = true;
		/**
		 * 锁定宽高比
		 */
		public var lockRatio:Boolean = false;

		public var video_pfxs:Array = ['flv','mp4'];
		public var flash_pfxs:Array = ['swf'];
		public var pic_pfxs:Array = ['jpg','jpeg','gif','png','bmp'];

		private var _url:String;
		private var _size:Point;
		private var _img:Loader;
		private var _swf:Loader;
		private var _video:InsVideo;
		private var _bgColor:uint;

		public function get bgColor():uint
		{
			return _bgColor;
		}

		public function set bgColor(value:uint):void
		{
			_bgColor = value;

			graphics.clear();
			if(value == 1) return;

			graphics.beginFill(value,1);
			graphics.drawRect(0,0,_size.x,_size.y);
			graphics.endFill();
		}

		public function get playingUrl():String{
			return _url;
		}

		public function get content():DisplayObject{
			if(_img) return _img.loaderInfo.content;
			if(_swf) return _swf.loaderInfo.content;
			return null;
		}

		public function get videoPlaying():Boolean{
			return _video && _video.playing;
		}

		/**
		 * 时长等视频信息
		 */
		public function get videoMetaData():Object{
			return _video.metadata;
		}

		public function SuperPlayer(width:Number, height:Number)
		{
			_size = new Point(width,height);
			super();
		}

		private var _loopPlay:Boolean;
		public function play(url:String , loop:Boolean = false):void{
			stop();

			_url = url;
			_loopPlay = loop;

			var dxName:String = url.substr(url.lastIndexOf('.') + 1).toLocaleLowerCase();

			if(video_pfxs.indexOf(dxName) != -1){
				type = TYPE_VIDEO;
				playVideo(url);
			}

			if(flash_pfxs.indexOf(dxName) != -1){
				type = TYPE_FLASH;
				loadSwf(url);
			}

			if(pic_pfxs.indexOf(dxName) != -1){
				type = TYPE_BITMAP;
				loadBitmap(url);
			}

		}

		public function stop():void{
			if(_video){
				_video.destory();
				_video = null;
			}
			if(_img){
				removeChild(_img);
				_img.unload();
				_img = null;
			}
			if(_swf){
				removeChild(_swf);
				_swf.unload();
				_swf = null;
			}
		}

		public function playNow():void{
			if(_video) _video.play();
		}
		public function stopVideo():void{
			if(_video) _video.stop();
		}

		public function toggleMovie():void{
			if(_video.playing){
				_video.pause();
			}else{
				_video.play();
			}
		}

		private function loadBitmap(v:String):void {
			var l:Loader = new Loader();
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, loadPicComplete);
			l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadContentFail);
			l.load(new URLRequest(v));
		}
		private function loadPicComplete(e:Event):void {
			var loaderInfo:LoaderInfo = e.currentTarget as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE, loadPicComplete);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadContentFail);
			_img = loaderInfo.loader;
			if(lockRatio){
				if(_img.width > _img.height){
					_img.width = _size.x;
					_img.scaleY = _img.scaleX;
					_img.y = (_size.y - _img.height) / 2;
				}else{
					_img.height = _size.y;
					_img.scaleX = _img.scaleY;
					_img.x = (_size.x - _img.width) / 2;
				}
			}else{
				_img.width = _size.x;
				_img.height = _size.y;
			}
			addChild(_img);
//			content = loaderInfo.content;
			onLoadContentComplete();
		}

		private function loadSwf(v:String):void {
			_swf = new Loader();
			_swf.contentLoaderInfo.addEventListener(Event.COMPLETE, loadSwfComplete);
			_swf.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadContentFail);
			_swf.scrollRect = new Rectangle(0,0,_size.x,_size.y);
			addChild(_swf);
			_swf.load(new URLRequest(v));
		}
		private function loadSwfComplete(e:Event):void {
			var back:Shape = new Shape();
			back.graphics.beginFill(0,1);
			back.graphics.drawRect(0 , 0 , _size.x , _size.y);
			back.graphics.endFill();
			addChild(back);

			var li:LoaderInfo = e.currentTarget as LoaderInfo;

			li.removeEventListener(Event.COMPLETE, loadSwfComplete);
			li.removeEventListener(IOErrorEvent.IO_ERROR, onLoadContentFail);

			var l:Loader = li.loader;
			var bl:Number = _size.x / li.width;
			var hl:Number = _size.y / li.height;
			var ll:Number = Math.max(bl,hl);
			l.scaleX = l.scaleY = ll;
//			l.y = (_size.y - li.height) / 2;
			if(l.y < 0) l.y = 0;
			addChild(l);
//			content = li.content;
			onLoadContentComplete();
		}

		private function playVideo(url:String):void {
			//加载播放视频
			_video = new InsVideo(url , _size);
			addChild(_video);
			if(autoPlay) _video.play();
			_video.addEventListener(InsVideo.PLAY_COMPLETE, onVideComplete);
			_video.addEventListener(InsVideo.PLAY_FAIL, onLoadContentFail);
			_video.addEventListener(InsVideo.META_DATA , onLoadContentComplete);
//			onLoadContentComplete();
		}

		private function onVideComplete(e:Event):void{
			dispatchEvent(new Event(EVENT_PLAY_COMPLETE));
			if(_loopPlay) playNow();
		}

		private function onLoadContentComplete(e:Event = null):void {
			dispatchEvent(new Event(EVENT_LOAD_COMPLETE));
		}

		private function onLoadContentFail(e:Event = null):void {
			dispatchEvent(new Event(EVENT_LOAD_FAIL));
		}

		public function destory():void {
			type = null;
			_url = null;

			if(_img){
				try{
					removeChild(_img);
				}catch(e:Error){}
				_img.unload();
				_img = null;
			}
			if(_swf){
				try{
					removeChild(_swf);
				}catch(e:Error){}
				if(_swf['unloadAndStop'] != undefined){
					_swf['unloadAndStop']();
				}else{
					_swf.unload();
				}
				_swf = null;
			}
			if(_video){
				try{
					removeChild(_video);
				}catch(e:Error){}
				_video.destory();
				_video = null;
			}
		}
	}
}

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.AsyncErrorEvent;
import flash.events.Event;
import flash.events.NetStatusEvent;
import flash.geom.Point;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

internal class InsVideo extends Sprite {
	public static const PLAY_COMPLETE:String = 'insvideo.play.complete';
	public static const PLAY_FAIL:String = 'insvideo.play.fail';
	public static const META_DATA:String = 'insvideo.event.metadata';

	public var loopPlay:Boolean;
	public var playing:Boolean;
	public var metadata:Object;

	private var flvVideo:Video;
	private var flvURL:String;
	private var flvNC:NetConnection;
	private var flvNS:NetStream;
	public function InsVideo(url:String,size:Point) {
		var flvObject:Object=new Object();
		flvURL=url;

		flvNC=new NetConnection();
		flvNC.connect(null);

		flvNS=new NetStream(flvNC);
		flvNS.addEventListener(AsyncErrorEvent.ASYNC_ERROR,videoFail);
		flvNS.addEventListener(NetStatusEvent.NET_STATUS,videoState);
		flvNS.client=flvObject;
		flvNS.play(flvURL);

		flvVideo=new Video(size.x,size.y);
		flvVideo.attachNetStream(flvNS);

		flvNS.pause();

		var obj:Object = {};
		obj.onMetaData = onMetaData;
		flvNS.client = obj;

		addChild(flvVideo);
	}
	private function videoFail(evt:AsyncErrorEvent):void {
		dispatchEvent(new Event(PLAY_FAIL));
	}
	private function videoState(evt:NetStatusEvent):void {
		var code:String = evt.info.code;
		switch(code){
			case "NetStream.Play.StreamNotFound":
				dispatchEvent(new Event(PLAY_FAIL));
				break;
			case "NetStream.Play.Complete":
			case "NetStream.Buffer.Empty":
				if(loopPlay) resume();
				playing = false;
				dispatchEvent(new Event(PLAY_COMPLETE));
				break;
		}
	}
	private function onMetaData(obj:Object):void{
		metadata = obj;
		dispatchEvent(new Event(META_DATA));
	}

	public function play():void {
		playing = true;

		clearTimeout(_siint);

		flvNS.play(flvURL);
		flvNS.seek(0);

	}
	public function pause():void {
		playing = false;
		flvNS.pause();
	}
	public function resume():void {
		playing = true;
		flvNS.resume();
	}
	private var _siint:int;
	public function stop():void {
		playing = false;
		flvNS.pause();
		flvNS.seek(0);
		clearTimeout(_siint);
		_siint = setTimeout(flvNS.close , 1000);
	}
	public function destory():void{
		stop();

		if(flvNC){
			flvNC.close();
			flvNC = null;
		}

		if(flvNS){
			flvNS.removeEventListener(AsyncErrorEvent.ASYNC_ERROR,videoFail);
			flvNS.removeEventListener(NetStatusEvent.NET_STATUS,videoState);
			flvNS = null;
		}

		if(flvVideo){
			try{
				removeChild(flvVideo);
			}catch(e:Error){}

			flvVideo.clear();
			flvVideo = null;
		}

	}
}
