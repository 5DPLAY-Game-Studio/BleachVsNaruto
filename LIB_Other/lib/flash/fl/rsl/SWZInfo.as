package fl.rsl {

	// AdobePatentID="B1103"

	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.utils.ByteArray;

	/**
	 * The SWZInfo class indicates how to download a SWZ file, which is 
	 * a signed Runtime Shared Library (RSL). Specify the digest (an SHA-256 hashed string value) in
	 * the constructor, and add a series of URLs (both for the SWZ
	 * file itself and for a necessary policy file) with addEntry().
	 * If any of the URLs in the list end with ".swf", they
	 * will be downloaded as normal, For a non-cached SWF RSL, the
	 * digest will NOT be checked.
	 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
	 * @langversion 3.0
     	 * @keyword SWZInfo
     	 * @see fl.rsl.RSLInfo#addEntry
	 */
	public class SWZInfo extends RSLInfo
	{
		/**
		 * @private
		 */
		protected var _digest:String;

		/**
		 * Constructor. Pass in digest value.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
		 */
		public function SWZInfo(digest:String)
		{
			_digest = digest;
		}

		/**
		 * Returns the read-only digest that was set in the constructor.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
     	 	 * @keyword digest, SWZ
		 */
		public function get digest():String
		{
			return _digest;
		}

		/**
		 * @private
		 */
		protected override function getNextRequest():URLRequest
		{
			var req:URLRequest = super.getNextRequest();
			if (req != null && _digest != null && _digest.length > 0 && req.url.substr(-4).toLowerCase() != ".swf" && req.hasOwnProperty("digest")) {
				req.digest = _digest;
			}
			return req;
		}

	}
}
