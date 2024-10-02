package net.play5d.game.bvn.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	
	import net.play5d.game.bvn.ctrl.AssetManager;

	public class BitmapAssetLoader
	{
		public function BitmapAssetLoader()
		{
		}
		
		private var _queueLength:int;
		private var _urls:Array;
		private var _cacheObj:Object = {};
		private var _successBack:Function;
		private var _processBack:Function;
		
		public function getBitmap(id):Bitmap{
//			var r:DisplayObject = _cacheObj[id];
//			
//			if(r == null) return null;
//			
//			if(r is BitmapData){
//				return new Bitmap(r as BitmapData);
//			}
			
			var bd:BitmapData = _cacheObj[id];
			if(bd == null) return null;
			return new Bitmap(bd);
		}
		
		public function loadQueue(urls:Array , success:Function , process:Function = null):void{
			_successBack = success;
			_processBack = process;
			
			_urls = urls.concat();
			_queueLength = urls.length;
			loadNext();
		}
		
		private function load(url:String , back:Function = null , process:Function = null):void{
			AssetManager.I.loadBitmap(url , loadCom , loadFail , process);
			
			function loadCom(bp:DisplayObject):void{
				cacheBitmap(url , bp);
				if(back != null) back();
			}
			
			function loadFail():void{
				trace("BitmapAssetLoader.loadFail ::", url);
				if(back != null) back();
			}
			
		}
		
		private function cacheBitmap(id:String , bp:DisplayObject):void{
			var content:Bitmap = bp as Bitmap;
			
			if(!content){
				trace("BitmapAssetLoader.cacheBitmap Error");
				return;
			}
			
			var cache:BitmapData;
			
			if(content){
				try{
					cache = content.bitmapData;
				}catch(e:Error){
					trace("BitmapAssetLoader.cacheBitmap::",e);
//					cache = content;
				}
			}else{
//				cache = loader;
			}
			
			if(cache){
				_cacheObj[id] = cache;
			}
			
			AssetManager.I.disposeAsset(id);
			
		}
		
		private function loadNext():void{
			if(_urls.length < 1){
				if(_successBack != null){
					_successBack();
					_successBack = null;
				}
				return;
			}
			var url:String = _urls.shift();
			load(url , loadNext, loadProcess);
			
			function loadProcess(v:Number):void{
				if(_processBack != null){
					var cur:Number = _queueLength - _urls.length-1 + v;
					var p:Number = cur / _queueLength;
					_processBack(p);
				}
			}
			
		}
		
	}
}