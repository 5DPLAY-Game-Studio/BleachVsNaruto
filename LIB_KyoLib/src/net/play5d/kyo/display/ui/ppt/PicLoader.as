package net.play5d.kyo.display.ui.ppt
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.controls.Alert;

	public class PicLoader extends Sprite
	{
		private var _loader:*;
		private var _size:Point;
		private var url:String;
		
		public var id:int;
		
		public function PicLoader(size:Point , url:String = null)
		{
			this._size = size;
			this.url = url;
		}
		
		public function get loader():*{
			return _loader;
		}
		public function set loader(v:*):void{
			_loader = v;
			addChild(_loader);
		}
		
		public function clear():void{
			try{
				removeChild(_loader);
			}catch(e:*){}
		}
		
		public final function unload():void{
			removeLoader();
		}
		
		public final function unloadLoader(l:*):void{
			if(l is ImageLoader) (l as ImageLoader).unloadAndDispose();
			if(l is SwfLoader) (l as SwfLoader).unload();
		}
		
		public final function destory():void{
			removeLoader();
		}
		
		private var _isComplete:Boolean;
		private var _succBack:Function;
		private var _failBack:Function;
		private var _processBack:Function;
		public final function load(success:Function = null , fail:Function = null , process:Function = null):void{
			
			if(_isComplete){
				if(success != null) success(this);
				return;
			}
			
			_succBack = success;
			_failBack = fail;
			_processBack = process;
			
			if(url.indexOf("|") != -1){
				var us:Array = url.split("|");
				var url2:String = us[0];
				var prefix:String = us[1].toLocaleLowerCase();
				if(prefix == ".swf") 
					loader = new SwfLoader(url2,_size,loadSuccess,loadFail,loadProcess);
				else
					loader = new ImageLoader(url2,_size,loadSuccess,loadFail,loadProcess);
			}else{
				loader = new ImageLoader(url,_size,loadSuccess,loadFail);
			}
		}
		
		private function loadSuccess(...params):void{
			_isComplete = true;
			if(_succBack != null) _succBack(this);
			
			_succBack = null;
			_failBack = null;
			_processBack = null;
		}
		private function loadFail(...params):void{
//			trace("PicLoader:资源不存在:"+url);
			Alert.show("加载幻灯片资源出错");
			if(_failBack != null) _failBack(this);
			
			_succBack = null;
			_failBack = null;
			_processBack = null;
		}
		
		private function loadProcess(l:*,per:Number):void{
			if(_processBack != null) _processBack(this,per);
		}
		
		private function removeLoader():void{
			if(_loader){
				try{
					removeChild(_loader);
				}catch(e:Error){}
				unloadLoader(_loader);
				_loader = null;
			}
		}
		
	}
}