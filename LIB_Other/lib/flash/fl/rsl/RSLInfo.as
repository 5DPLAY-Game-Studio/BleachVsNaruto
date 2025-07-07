package fl.rsl {

	// AdobePatentID="B1103"

	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
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
	 * The RSLInfo class allows to you specify the use of RSLs (Runtime Shared Library Files). A series of urls
	 * can be added (both for the SWF file and for a necessary policy file)
	 * with <code>addEntry()</code>.
	 *
	 * The RSLInfo class can dispatch any of these events: <code>Event.COMPLETE</code>, <code>IOErrorEvent.IO_ERROR</code>,
	 * <code>SecurityErrorEvent.SECURITY_ERROR</code> and <code>ProgressEvent.PROGRESS</code>.
	 * Because of the use of failovers, even if SecurityErrorEvents or
	 * IOErrorEvents are dispatched, the RSL download has not failed
	 * until the <code>failed</code> property returns <code>true</code>.
	 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
 	 * @keyword RSLInfo
 	 * @see #addEntry()
	 */
	public class RSLInfo extends EventDispatcher
	{
		/**
		 * @private
		 */
		protected var _rslURLs:Array;

		/**
		 * @private
		 */
		protected var _policyFileURLs:Array;

		/**
		 * @private
		 */
		protected var _index:int;

		/**
		 * @private
		 */
		protected var _urlLoader:URLLoader;

		/**
		 * @private
		 */
		protected var _loader:Loader;

		/**
		 * @private
		 */
		protected var _failed:Boolean;

		/**
		 * @private
		 */
		protected var _complete:Boolean;

		/**
		 * Constructor.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
 	 	 * @keyword RSLInfo
		 */
		public function RSLInfo()
		{
			_index = -1;
			_rslURLs = new Array();
			_policyFileURLs = new Array();
		}

		/**
		 * Returns the loader used to download the RSL. Can be NULL.
		 * The loader instance is created after load() has been called.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
 	 	 * @keyword loader
		 */
		public function get loader():Loader
		{
			return _loader;
		}

		/**
		 * Returns an array of policy file URLs that have been added via <code>addEntry()</code>. 
		 * Treat this array as read-only. Add entries by
		 * calling <code>addEntry()</code>. Editing this array directly will cause
		 * unpredictable results.
		 *
		 * <listing>
		 * import fl.rsl.RSLInfo;
		 * var info:RSLInfo = new RSLInfo();
		 * for (var i:int = 0; i &lt; info.policyFileURLs.length; i++) {
		 *    trace('url: ' + info.policyFileURLs[i]);
		 * }
		 * </listing>
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
 	 	 * @keyword policyFileURLs
 	 	 * @see #addEntry()
		 */
		public function get policyFileURLs():Array
		{
			return _policyFileURLs;
		}

		/**
		 * Returns an array of RSL URLs added via <code>addEntry()</code>. Treat this array
		 * as read-only. Add entries by calling
		 * <code>addEntry()</code>. Editing this array directly will cause
		 * unpredictable results.
		 *
		 * <listing>
		 * import fl.rsl.RSLInfo;
		 * var info:RSLInfo = new RSLInfo();
		 * for (var i:int = 0; i &lt; info.rslURLs.length; i++) {
		 *    trace('url: ' + info.rslURLs[i]);
		 * }
		 * </listing>
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
 	 	 * @keyword rslURLs
 	 	 * @see #addEntry()
		 */
		public function get rslURLs():Array
		{
			return _rslURLs;
		}

		/**
		 * Returns the index of the URL currently attempting to download. When failure
		 * events are received, this index points to the URL that
		 * failed. The index belongs to the rslURLs and policyFileURLs
		 * arrays. Before downloading has begun, the index value is -1, After
		 * downloading has completed, it is equal to the length of
		 * the arrays, so range checking is recommended before using
		 * this value to access a URL array member.
		 *
		 * <listing>
		 * import fl.rsl.RSLInfo;
		 * var info:RSLInfo = new RSLInfo();
		 * info.addEventListener(IOErrorEvent.IO_ERROR, handleErr);
		 * function handleErr(e:Event) {
		 * trace('error: ' + e);
		 * trace('on download of url: ' + info.rslURLs[info.currentAttemptIndex]);
		 * }
		 * </listing>
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
 	 	 * @keyword currentAttemptIndex
		 */
		public function get currentAttemptIndex():int
		{
			return _index;
		}

		/**
		 * Returns a value of <code>true</code> if the download has completed 
		 * successfully and <code>false</code> if
		 * the download is not yet complete or has failed.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
		 * @keyword complete
		 */
		public function get complete():Boolean
		{
			return _complete;
		}

		/**
		 * Returns a value of <code>true</code> if the download has failed and <code>false</code>
		 * if the download is
		 * not yet complete or has completed successfully. The <code>failed</code> property is
		 * not set to <code>true</code> if a single url has failed and there
		 * are additional failover URLs to attempt.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
		 * @keyword failed
		 */
		public function get failed():Boolean
		{
			return _failed;
		}

		/**
		 * Indicates the number of bytes that have been loaded thus far for all files being loaded. 
		 * Because some loads may fail and go to failover URLs, the bytesLoaded value can increase 
		 * or decrease over time. Progress bars must compensate for this to avoid moving backward.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
 	 	 * @keyword bytesLoaded
		 */
		public function get bytesLoaded():int
		{
			return (_urlLoader == null) ? 0 : _urlLoader.bytesLoaded;
		}

		/**
		 * Indicates the total number of bytes that have been loaded thus far for all files being loaded. 
		 * Because some loads may fail and go to failover URLs, the bytesTotal value can increase 
		 * or decrease over time. Progress bars must compensate for this to avoid moving backward.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
 	 	 * @keyword bytesTotal
		 */
		public function get bytesTotal():int
		{
			return (_urlLoader == null) ? 0 : _urlLoader.bytesTotal;
		}

		/**
		 * Adds a series of URLs (RSL files and policy files). The order in which
		 * the URLs are added depends on their download priority. The first
		 * URL is tried first, the second will not be tried
		 * until the first has failed, and so on. Policy files are
		 * added only when the matching RSL file URL is downloaded.
		 *
		 * <listing>
		 * import fl.rsl.RSLInfo;
		 * var info:RSLInfo = new RSLInfo();
		 * info.addEntry('rsl.swf');
		 * myPreloader.addRSLInfo(info);
		 * myPreloader.start();
		 * </listing>
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
		 * @keyword addEntry
		 */
		public function addEntry(url:String, policyFileURL:String=null):void
		{
			_rslURLs.push(url);
			policyFileURLs.push(policyFileURL);
		}

		/**
		 * Starts the RSL download. The first entry added is tried first.
		 * Subsequent entries are tried as backups as failures occur.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
 	 	 * @keyword load
		 */
		public function load():void
		{
			var req:URLRequest = getNextRequest();
			if (req == null) {
				_failed = true;
				dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			}
			while (req != null) {
				try {
					if (Security.sandboxType == Security.LOCAL_WITH_FILE) {
						// check to ensure we don't try to download a remote URL, as it may raise a distracting dialog
						// box when user is trying to debug.
						var colonIndex:int = req.url.indexOf(":");
						if (colonIndex >= 0) {
							var protocol:String = req.url.substring(0, colonIndex);
							// only allow "file:" protocol, which we assume is a local file
							if (protocol != "file") {
								req = getNextRequest();
								continue;
							}
						}
					}
					if (_urlLoader == null) {
						_urlLoader = new URLLoader();
						_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
						_urlLoader.addEventListener(ProgressEvent.PROGRESS, handleProgress);
						_urlLoader.addEventListener(Event.COMPLETE, urlLoaderComplete);
						_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoaderError);
						_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, urlLoaderError);
					}
					_urlLoader.load(req);
				} catch (se:SecurityError) {
					req = getNextRequest();
					if (req == null) _failed = true;
					dispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, se.message));
					continue;
				}
				break;
			}
			if (req == null) {
				if (_loader != null) {
					_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderComplete);
					_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loaderError);
				}
				if (_urlLoader != null) {
					_urlLoader.removeEventListener(ProgressEvent.PROGRESS, handleProgress);
					_urlLoader.removeEventListener(Event.COMPLETE, urlLoaderComplete);
					_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, urlLoaderError);
					_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, urlLoaderError);
				}
			}
		}

		/**
		 * @private
		 */
		protected function getNextRequest():URLRequest
		{
			_index++;
			if (_index >= rslURLs.length) return null;
			var req:URLRequest = new URLRequest();
			req.url = _rslURLs[_index];
			var policyFileURL:String = _policyFileURLs[_index];
			if (policyFileURL != null && policyFileURL.length > 0 && Security.sandboxType != Security.LOCAL_WITH_FILE) {
				Security.loadPolicyFile(policyFileURL);
			}
			return req;
		}

		/**
		 * @private
		 */
		protected function handleProgress(e:ProgressEvent)
		{
			dispatchEvent(e);
		}

		/**
		 * @private
		 */
		protected function urlLoaderComplete(e:Event):void
		{
			_urlLoader.removeEventListener(ProgressEvent.PROGRESS, handleProgress);
			_urlLoader.removeEventListener(Event.COMPLETE, urlLoaderComplete);
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, urlLoaderError);
			_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, urlLoaderError);
			if (_loader == null) {
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderComplete);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loaderError);
			}
			try {
				var lc:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
				if (lc.hasOwnProperty("allowLoadBytesCodeExecution")) {
					lc["allowLoadBytesCodeExecution"] = true;
				}
				_loader.loadBytes((ByteArray)(_urlLoader.data), lc);
			} catch (se:SecurityError) {
				_failed = (_index + 1 >= rslURLs.length);
				dispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, se.message));
				loaderError(null);
			}
		}

		/**
		 * @private
		 */
		protected function urlLoaderError(e:ErrorEvent):void
		{
			_failed = (_index + 1 >= rslURLs.length);
			dispatchEvent(e);
			if (_failed) {
				_urlLoader.removeEventListener(ProgressEvent.PROGRESS, handleProgress);
				_urlLoader.removeEventListener(Event.COMPLETE, urlLoaderComplete);
				_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, urlLoaderError);
				_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, urlLoaderError);
			} else {
				load();
			}
		}

		/**
		 * @private
		 */
		protected function loaderComplete(e:Event):void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderComplete);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loaderError);
			_complete = true;
			dispatchEvent(e);
		}

		/**
		 * @private
		 */
		protected function loaderError(e:IOErrorEvent):void
		{
			_failed = (_index + 1 >= rslURLs.length);
			dispatchEvent(e);
			if (_failed) {
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderComplete);
				_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loaderError);
			} else {
				load();
			}
		}

	}
}
