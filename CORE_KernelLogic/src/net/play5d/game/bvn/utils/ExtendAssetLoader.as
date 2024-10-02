package net.play5d.game.bvn.utils
{
	import net.play5d.game.bvn.interfaces.IAssetLoader;
	
	public class ExtendAssetLoader implements IAssetLoader
	{
		
		private var _extend:*;
		public function ExtendAssetLoader(extend:*)
		{
			if(!extend){
				throw new Error("extend is null !");
			}
			_extend = extend;
		}
		
		public function loadXML(url:String, back:Function, fail:Function=null):void
		{
			_extend.loadXML(url, back, fail);
		}
		
		public function loadJSON(url:String, back:Function, fail:Function=null):void
		{
			_extend.loadJSON(url, back, fail);
		}
		
		public function loadSwf(url:String, back:Function, fail:Function=null, process:Function=null):void
		{
			_extend.loadSwf(url, back, fail, process);
		}
		
		public function loadSound(url:String, back:Function, fail:Function=null, process:Function=null):void
		{
			_extend.loadSound(url, back, fail, process);
		}
		
		public function loadBitmap(url:String, back:Function, fail:Function=null, process:Function=null):void
		{
			_extend.loadBitmap(url, back, fail, process);
		}
		
		public function dispose(url:String):void
		{
			_extend.dispose(url);
		}
		
		public function needPreLoad():Boolean
		{
			return _extend.needPreLoad();
		}
		
		public function loadPreLoad(back:Function, fail:Function=null, process:Function=null):void
		{
			_extend.loadPreLoad(back, fail, process);
		}
	}
}