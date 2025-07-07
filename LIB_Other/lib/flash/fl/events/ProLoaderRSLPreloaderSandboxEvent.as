package fl.events
{
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.events.Event;

	[ExcludeClass]

	public class ProLoaderRSLPreloaderSandboxEvent extends Event {

		public static const PROLOADER_RSLPRELOADER_SANDBOX:String = "__proLoaderRSLPreloaderSandbox";

		public var loaderInfo:LoaderInfo;
		public var shape:Shape;

		public function ProLoaderRSLPreloaderSandboxEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, li:LoaderInfo=null, s:Shape=null)
		{
			super(type, bubbles, cancelable);
			loaderInfo = li;
			shape = s;
		}

		override public function clone():Event
		{
			return new ProLoaderRSLPreloaderSandboxEvent(type, bubbles, cancelable, loaderInfo, shape);
		}

		override public function toString():String
		{
			return formatToString("ProLoaderRSLPreloaderSandboxEvent", "type", "bubbles", "cancelable", "eventPhase", "loaderInfo", "shape");
		}
	}

}