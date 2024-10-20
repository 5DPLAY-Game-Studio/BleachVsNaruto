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

package net.play5d.game.bvn.ctrl
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.media.Sound;

	//import net.play5d.utils;
	import net.play5d.game.bvn.data.AssisterModel;
	import net.play5d.game.bvn.data.FighterModel;
	import net.play5d.game.bvn.data.FighterVO;
	import net.play5d.game.bvn.data.MapModel;
	import net.play5d.game.bvn.data.MapVO;
	import net.play5d.game.bvn.interfaces.IAssetLoader;
	import net.play5d.game.bvn.utils.BitmapAssetLoader;
	import net.play5d.game.bvn.utils.ExtendAssetLoader;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.display.bitmap.BitmapFont;
	import net.play5d.kyo.display.bitmap.BitmapFontLoader;
	import net.play5d.kyo.loader.KyoClassLoader;
	import net.play5d.kyo.loader.KyoSoundLoader;
	import net.play5d.kyo.utils.KyoUtils;

	public class AssetManager
	{
		private static var _i:AssetManager;
		public static function get I():AssetManager{
			_i ||= new AssetManager();
			return _i;
		}
		private var _swfLoader:KyoClassLoader = new KyoClassLoader();
		private var _soundLoader:KyoSoundLoader = new KyoSoundLoader();
		private var _bitmapLoader:BitmapAssetLoader = new BitmapAssetLoader();
		private var _bitmapFontLoader:BitmapFontLoader = new BitmapFontLoader();
//		private var _assetLoader:IAssetLoader = new AssetLoader();
//		private var _assetLoader:IAssetLoader = ResUtils.I.callSwfFunction(ResUtils.I.extend, "getAssetLoader");
		private var _assetLoader:IAssetLoader = null;

		private const _effectSwfPath:String = "effect.swf";

		private var _fighterFaceCache:Object = {};

		public function AssetManager()
		{
		}

		public function init():void{
//			if(!_assetLoader){
//				var extend:* = ResUtils.I.getItemProperty(ResUtils.I.extend, "assetLoader");
//				_assetLoader = new ExtendAssetLoader(extend);
//				trace(_assetLoader);
//			}
		}

		public function getFont(id:String):BitmapFont{
			return _bitmapFontLoader.getFont(id);
		}

		public function setAssetLoader(v:IAssetLoader):void{
			_assetLoader = v;
		}

		public function loadBasic(back:Function , process:Function = null):void{

			var loadStep:int = 0;
			var loadCount:int = 4;
			var type:String;

			function loadProcess(p:Number):void{
				if(process != null) process(p , type , loadStep , loadCount);
			}

			function loadNext():void{

				switch(loadStep){
					case 0:
						loadPreLoadSounds(loadNext , loadProcess);
						type = GetLangText('txt.load_step.sound');
						loadProcess(0);
						break;
					case 1:
						loadGraphics([_effectSwfPath] , loadNext , loadProcess);
						type = GetLangText('txt.load_step.effect');
						loadProcess(0);
						break;
					case 2:
						loadFonts(loadNext , loadProcess);
						type = GetLangText('txt.load_step.font');
						loadProcess(0);
						break;
					case 3:
						loadBitmaps(loadNext , loadProcess);
						type = GetLangText('txt.load_step.bitmap');
						loadProcess(0);
						break;
					case 4:
						initAssets();
						if(back != null) back();
				}
				loadStep++;
			}

			loadNext();
		}

		private function loadPreLoadSounds(back:Function , process:Function):void{
			_assetLoader.loadXML("config/preload.xml",function(xml:XML):void{
				var sounds:Array = [];
				var bgmPath:String = xml.bgm.@path;
				var soundPath:String = xml.sound.@path;
				for each(var i:XML in xml.bgm.item){
					sounds.push(bgmPath+'/'+i.toString());
				}
				for each(var j:XML in xml.sound.item){
					sounds.push(soundPath+'/'+j.toString());
				}
//				_soundLoader.loadSounds(sounds , back , process);
				loadSnds(sounds , back , process);
			});

		}

		private function loadSnds(sounds:Array , back:Function , process:Function):void{
			var snds:Array = sounds.concat();
			var sndLen:int = snds.length;
			var curUrl:String;

			loadNext();

			function loadNext():void{

				if(snds.length < 1){
					if(back != null) back();
					return;
				}

				curUrl = snds.shift();
				_assetLoader.loadSound(curUrl , loadCom , loadErr , loadProcess);
			}

			function loadCom(snd:Sound):void{
				_soundLoader.addSound(curUrl , snd);
				_assetLoader.dispose(curUrl);
				loadNext();
			}

			function loadErr():void{
				TraceLang(GetLangText('debug.trace.data.load_sound_fail'), curUrl);
				loadNext();
			}

			function loadProcess(v:Number):void{
				if(process != null){
					var cur:Number = sndLen - snds.length-1 + v;
					var p:Number = cur / sndLen;
					process(p);
				}
			}

		}

		private function initAssets():void{
			var font1:BitmapFont = getFont('font1');
			if(font1){
				font1.charGap = -8;
				font1.spaceGap = 10;
				font1.offsetY = -5;
			}
		}

		public function getClass(className:String, swfPath:String):Class {
			var cls:Class = _swfLoader.getClass(className , swfPath);
			return cls;
		}

		public function getEffect(className:String):*{
			var cls:Class = _swfLoader.getClass(className , _effectSwfPath);
			return new cls();
		}

		public function getSound(name:String):Sound{
			return _soundLoader.getSound(name);
		}

		public function getFighterFace(fv:FighterVO , size:Point = null):DisplayObject{
			var bp:Bitmap = _bitmapLoader.getBitmap(fv.faceUrl);
			if(!bp) return null;

			size ||= new Point(50,50);

			bp.width = size.x;
			bp.height = size.y;

			return bp;
		}



		public function getFighterFaceBig(fv:FighterVO , size:Point = null):DisplayObject{
			var bp:Bitmap = _bitmapLoader.getBitmap(fv.faceBigUrl);
			if(!bp) return null;

			size ||= new Point(245,62);

			bp.width = size.x;
			bp.height = size.y;

			return bp;
		}

		public function getFighterFaceBar(fv:FighterVO , size:Point = null):DisplayObject{
			var bp:Bitmap = _bitmapLoader.getBitmap(fv.faceBarUrl);
			if(!bp) return null;

			size ||= new Point(102,64);

			bp.width = size.x;
			bp.height = size.y;

			return bp;
		}

		public function getFighterFaceWin(fv:FighterVO , size:Point = null):DisplayObject{
			if(!fv) return null;
			if(!fv.faceWinUrl) return null;
			var bp:Bitmap = _bitmapLoader.getBitmap(fv.faceWinUrl);
			if(!bp) return null;

			size ||= new Point(300,250);

			bp.width = size.x;
			bp.height = size.y;

			return bp;
		}

		public function getMapPic(mv:MapVO , size:Point = null):DisplayObject{
			var bp:Bitmap = _bitmapLoader.getBitmap(mv.picUrl);
			if(!bp) return null;
			size ||= new Point(450,240);

			bp.width = size.x;
			bp.height = size.y;

			return bp;
		}

		public function loadXML(url:String , back:Function , fail:Function):void{
			_assetLoader.loadXML(url , back , fail);
		}

		public function loadJSON(url:String , back:Function , fail:Function):void{
			_assetLoader.loadJSON(url , back , fail);
		}

		public function loadSWF(url:String , back:Function , fail:Function  = null , process:Function = null):void{
			_assetLoader.loadSwf(url , back , fail , process);
		}

		public function loadSound(url:String , back:Function , fail:Function  = null , process:Function = null):void{
			_assetLoader.loadSound(url , back , fail , process);
		}

		public function loadBitmap(url:String , back:Function , fail:Function  = null , process:Function = null):void{
			_assetLoader.loadBitmap(url , back , fail , process);
		}

		public function disposeAsset(url:String):void{
			_assetLoader.dispose(url);
		}

		public function loadSWFs(loadarray:Array , back:Function = null,process:Function = null):void{
			loadGraphics(loadarray , back,process)

		}

		private function loadGraphics(loadarray:Array , back:Function = null,process:Function = null):void{

			var loads:Array = loadarray.concat();
			var loadedAmount:int;
			var curUrl:String;

			loadNext();

			function loadNext():void{
				if(loads.length < 1){
					if(back != null) back();
					return;
				}
				curUrl = loads.shift();
				_assetLoader.loadSwf(curUrl , loadCom , loadFail , process);
			}

			function loadCom(loader:Loader):void{
				loadedAmount++;
				_swfLoader.addSwf(curUrl , loader);
				_assetLoader.dispose(curUrl);
				loadNext();
			}

			function loadFail():void{
				TraceLang('debug.trace.data.load_swf_fail', curUrl);
				loadNext();
			}

		}

		private function loadBitmaps(back:Function = null,process:Function = null):void{

			var bps:Array = getFighterFaceUrls(FighterModel.I.getAllFighters(), true, true);
			bps = bps.concat(getFighterFaceUrls(AssisterModel.I.getAllAssisters()));
			bps = bps.concat(getMapPicUrls(MapModel.I.getAllMaps()));

			KyoUtils.array_deleteSames(bps);

			_bitmapLoader.loadQueue(bps , back , process);
		}

		private function loadFonts(back:Function = null , process:Function = null):void{

			var url:String = 'font/font1.xml';
			var fontXML:XML;
			var fontBitmapUrl:String;

			_assetLoader.loadXML(url,loadXMLCom , loadXMLFail);

			function loadXMLCom(xml:XML):void{

				fontXML = xml;

				var bpurl:String = xml.pages.page.@file;
				var floder:String = url.substr(0,url.lastIndexOf('/')+1);
				fontBitmapUrl = floder + bpurl;

				_assetLoader.loadBitmap(fontBitmapUrl , bitmapCom , bitmapFail);
			}

			function bitmapCom(d:DisplayObject):void{
				var bp:Bitmap = d as Bitmap;
				_bitmapFontLoader.addFont(fontXML,bp.bitmapData);
				_assetLoader.dispose(fontBitmapUrl);
				if(back != null) back();
			}

			function bitmapFail():void{
				trace(GetLangText('debug.package.ctrl.AssetManager.loadFonts.bitmapFail.load_font_bitmap_fail.txt') , url);
			}

			function loadXMLFail():void{
				trace(GetLangText('debug.package.ctrl.AssetManager.loadFonts.loadXMLFail.load_font_xml_fail.txt')  , url);
			}
		}

		private function getFighterFaceUrls(fighters:Object , loadBar:Boolean = false, loadWin:Boolean = false):Array{
			var ra:Array = [];
			for each(var i:FighterVO in fighters){
				if(i.faceUrl) ra.push(i.faceUrl);
				if(i.faceBigUrl) ra.push(i.faceBigUrl);
				if(loadBar && i.faceBarUrl) ra.push(i.faceBarUrl);
				if(loadWin && i.faceWinUrl) ra.push(i.faceWinUrl);
			}
			return ra;
		}

		private function getMapPicUrls(maps:Object):Array{
			var ra:Array = [];
			for each(var i:MapVO in maps){
				ra.push(i.picUrl);
			}
			return ra;
		}

		public function needPreLoad():Boolean{
			return _assetLoader.needPreLoad();
		}

		public function loadPreLoad(back:Function , fail:Function = null , process:Function = null):void{
			_assetLoader.loadPreLoad(back , fail , process);
		}

	}
}
