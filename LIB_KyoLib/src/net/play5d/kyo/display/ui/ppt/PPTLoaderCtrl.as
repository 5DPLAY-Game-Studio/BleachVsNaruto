package net.play5d.kyo.display.ui.ppt
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class PPTLoaderCtrl extends EventDispatcher
	{
		public function PPTLoaderCtrl()
		{
		}
		
		private var _loaders:Array;
		
		public var curIndex:int;
		public var totalIndex:int;
		
		public function loadQueue(loaders:Array):void{
			_loaders = loaders;
			
			curIndex = 0;
			totalIndex = loaders.length;
			
			loadNext();
		}
		
		private function loadNext():void{
			if(_loaders.length < 1){
				dispatchEvent(new PicPointerEvent(PicPointerEvent.LOAD_COMPLETE));
				return;
			}
			
			curIndex ++;
			
			var l:PicLoader = _loaders.shift();
			l.load(loadSuccess,loadFail,loadProcess);
			
		}
		
		private function loadSuccess(l:PicLoader):void{
			loadNext();
		}
		
		private function loadFail(l:PicLoader):void{
			loadNext();
		}
		
		private function loadProcess(l:PicLoader , per:Number):void{
			dispatchEvent(new PicPointerEvent(PicPointerEvent.LOAD_PROCESS,per));
		}
		
	}
}