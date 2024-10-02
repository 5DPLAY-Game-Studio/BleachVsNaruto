package net.play5d.kyo.loader
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.utils.getDefinitionByName;
	
	public class PreLoader extends MovieClip
	{
		public var showLoadbar:Boolean = true;
		protected var _mainClass:String;
		public function PreLoader()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE,onAddStage);
			
			stop();
		}
		
		private function onAddStage(e:Event):void{
			var w:Number = stage.stageWidth - 200;
			var h:Number = stage.stageHeight - 50;
			
			initlize(w,h);
		}
		
		public function initlize(width:Number,height:Number):void{
			if(showLoadbar){
				_loadbar = new LoaderBar(800,15);
				_loadbar.x = 100;
				_loadbar.y = 500;
				_loadbar.color = 0x426F00;
				_loadbar.lineColor = 0x64A600;
				_loadbar.backColor = 0x1C2F00;
				_loadbar.initlize();
				addChild(_loadbar);
			}
			
			loaderInfo.addEventListener(ProgressEvent.PROGRESS,loadProgress);
			loaderInfo.addEventListener(Event.COMPLETE,loadComplete);
		}
		
		protected var _loadbar:LoaderBar;
		private function loadProgress(e:ProgressEvent):void{
			var p:Number = e.bytesLoaded / e.bytesTotal;
			onProgress(p);
		}
		
		protected function onProgress(p:Number):void{
			if(_loadbar) _loadbar.update(p);
		}
		
		protected function loadComplete(e:Event):void{
			if(_loadbar) removeChild(_loadbar);
			
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS,loadProgress);
			loaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
			
			this.gotoAndStop(2);
			var main:Class = getDefinitionByName(_mainClass) as Class;
			addChild(new main());
		}
		
	}
}