package fl.rsl {

	// AdobePatentID="B1103"

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;

	import fl.events.ProLoaderRSLPreloaderSandboxEvent;
	import fl.events.RSLEvent;
	import fl.events.RSLErrorEvent;
	
	/**
	 * Dispatched by RSLPreloader when all RSLs have completed loading. 
	 * @eventType fl.events.RSLEvent.RSL_LOAD_COMPLETE
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
	 */
	[Event(name="rslLoadComplete", type="fl.events.RSLEvent")]
	/**
	 * Dispatched by RSLPreloader to indicate progress in downloading RSL files. 
	 * @eventType fl.events.RSLEvent.RSL_PROGRESS
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
	 */
	[Event(name="rslProgress", type="fl.events.RSLEvent")]
	/**
	 * Dispatched by RSLPreloader when all RSLs have finished downloading and one or more have failed.
	 * @eventType fl.events.RSLErrorEvent.RSL_LOAD_FAILED
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
	 */
	[Event(name="rslLoadFailed", type="fl.events.RSLErrorEvent")]
	
	/**
	 * The RSLPreloader class manages preloading of RSLs (Runtime Shared Libraries) before playing other
	 * content. It handles both SWF (unsigned) and SWZ (signed and cached) files.
	 * RSLPreloader dispatches events (<code>RSLEvent.RSL_LOAD_COMPLETE</code>, 
	 * <code>RSLErrorEvent.RSL_LOAD_FAILED</code> or
	 * <code>RSLEvent.RSL_PROGRESS</code>) to indicate the status of RSL file loading.
	 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
 	 * @keyword RSLPreloader
 	 * @see fl.events.RSLEvent
 	 * @see fl.events.RSLErrorEvent
	 */
	public class RSLPreloader extends EventDispatcher
	{
		/**
		 * @private
		 */
		protected var mainTimeline:MovieClip;

		/**
		 * @private
		 */
		protected var contentClassName:String;

		/**
		 * @private
		 */
		protected var loaderAnim:Loader;

		/**
		 * @private
		 */
		protected var contentLoader:Loader;

		/**
		 * @private
		 */
		protected var _rslInfoList:Array;

		/**
		 * @private
		 */
		protected var loaderList:Array;

		/**
		 * @private
		 */
		protected var numRSLComplete:int;

		/**
		 * @private
		 */
		protected var numRSLFailed:int;

		/**
		 * @private
		 */
		protected var failedURLs:Array;

		/**
		 * @private
		 */
		protected var enterFrameClip:MovieClip;

		/**
		 * @private
		 */
		protected var _debugWaitTime:int;

		/**
		 * @private
		 */
		protected var debugWaitStart:int;

		/**
		 * Constructor. When authoring outputs code
		 * automatically to preload SWZ files, it passes in the main
		 * timeline class as an argument. This is not generally useful for
		 * end-user written code.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
 	 	 * @keyword RSLPreloader
		 */
		public function RSLPreloader(mainTimeline:MovieClip=null)
		{
			this.mainTimeline = mainTimeline;
			_rslInfoList = new Array();
			loaderList = new Array();
			debugWaitStart = -1;
			contentLoader = new Loader();
			contentLoader.contentLoaderInfo.addEventListener(Event.INIT, contentInit, false, 0, true);
			if (mainTimeline != null) {
				mainTimeline.loaderInfo.sharedEvents.dispatchEvent(new ProLoaderRSLPreloaderSandboxEvent(ProLoaderRSLPreloaderSandboxEvent.PROLOADER_RSLPRELOADER_SANDBOX, false, false, contentLoader.contentLoaderInfo));
				if (contentLoader.contentLoaderInfo.hasOwnProperty("childSandboxBridge")) {
					var obj:Object;
					try {
						obj = mainTimeline.loaderInfo["childSandboxBridge"];
						if (obj != null) {
							contentLoader.contentLoaderInfo["childSandboxBridge"] = obj;
						}
					} catch (se:SecurityError) {
					}
					try {
						obj = mainTimeline.loaderInfo["parentSandboxBridge"];
						if (obj != null) {
							contentLoader.contentLoaderInfo["parentSandboxBridge"] = obj;
						}
					} catch (se:SecurityError) {
					}
				}
			}
		}

		public function set debugWaitTime(t:int):void
		{
			_debugWaitTime = t;
		}

		/**
		 * Set this value to the number of milliseconds to wait before
		 * downloading the first RSL file. This is one way to
		 * simulate the end-user experience and test the
		 * preload loop. It is especially useful in testing signed cache
		 * RSLs (SWZ files), to build in a loading delay
		 * without flushing the SWZ cache.
		 *
		 * Disable any code that sets this value to
		 * greater than 0 before deploying. Use a debug
		 * config constant (such as <code>CONFIG::DEBUG</code>) to call the code.
		 * Another suggestion is to set the delay to a relatively LARGE
		 * value, such as 5000 (equivalent to 5 seconds), as a reminder to 
		 * remove the debug code.
		 *
		 * For RSLLoader instances that are automatically
		 * generated by authoring, the dalay can be set by defining a
		 * <code>setRSLPreloader(value:RSLPreloader):void</code> method in the
		 * loading animation SWF or in the main timeline code.
		 *
		 * <listing>
		 * import fl.rsl.RSLPreloader;
		 * function setRSLPreloader(preloader:RSLPreloader):void {
		 * preloader.debugWaitTime = 10000;
		 * }
		 * </listing>
		 *
		 *
		 * @default 0
		 * @playerversion Flash 10.1
		 * @playerversion AIR 2
		 * @productversion Flash CS5
		 * @langversion 3.0
 	 	 * @keyword debugWaitTime
		 */
		public function get debugWaitTime():int
		{
			return _debugWaitTime;
		}

		/**
		 * The number of RSLInfo instances added via <code>addRSLInfo()</code>.
		 *
		 * <listing>
		 * for(var i:int = 0; i &lt; myPreloader.numRSLInfos; i++) {
		 *    trace('rsl ' + i);
		 *    var urls:Array = myPreloader.getRSLInfoAt(i).rslURLs;
		 *    for(var j:int = 0; j &lt; urls.length; j++) {
		 *       trace(' url: ' + urls[j]);
		 *    }
		 * }
		 * </listing>
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
 	 	 * @keyword numRSLInfos
 	 	 * @see #addRSLInfo()
		 */
		public function get numRSLInfos():int
		{
			return _rslInfoList.length;
		}

		/**
		 * Gets the RSLInfo record added via <code>addRSLInfo()</code> at the specified index. The index
		 * corresponds to the order in which the records were added via
		 * <code>addRSLInfo()</code>.
		 *
		 * <listing>
		 * for (var i:int = 0; i &lt; myPreloader.numRSLInfos; i++) {
		 *    trace('rsl ' + i);
		 *    var urls:Array = myPreloader.getRSLInfoAt(i).rslURLs;
		 *    for (var j:int = 0; j &lt; urls.length; j++) {
		 *       trace(' url: ' + urls[j]);
		 *    }
		 * }
		 * </listing>
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
 	 	 * @keyword getRSLInfoAt
 	 	 * @see #addRSLInfo()
		 */
		public function getRSLInfoAt(index:int):RSLInfo
		{
			return _rslInfoList[index];
		}

		/**
		 * Adds a descriptive
		 * RSLInfo record to the SWF or SWZ file being downloaded.
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
 	 	 * @keyword addRSLInfo()
		 */
		public function addRSLInfo(info:RSLInfo):void
		{
			_rslInfoList.push(info);
		}

		/**
		 * Starts downloading the RSL files. This function should not be called until
		 * all RSLInfo records have been added via <code>addRSLInfo()</code>.
		 * Two optional arguments may be used when authoring outputs code automatically.
		 * The first is a ByteArray subclass to load a preloader SWF
		 * animation. The second is the name of a ByteArray subclass for the
		 * content SWF, These arguments are not generally used in
		 * end-user written code.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
 	 	 * @keyword start, RSLPreloader
 	 	 * @see #addRSLInfo()
		 */
		public function start(preloaderAnimClass:Class=null, contentClassName:String=null):void
		{
			this.contentClassName = contentClassName;
			var loaderBytes:ByteArray;
			try {
				if (mainTimeline != null && preloaderAnimClass != null) {
					loaderBytes = new preloaderAnimClass() as ByteArray;
				}
			} catch (err:Error) {
			}
			if (loaderBytes == null) {
				loadRSLFiles();
			} else {
				loaderAnim = new Loader();
				mainTimeline.addChild(loaderAnim);
				loaderAnim.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderAnimLoaded, false, 0, true);
				loaderAnim.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loaderAnimError, false, 0, true);
				var lc:LoaderContext = new LoaderContext(false, new ApplicationDomain());
				if (lc.hasOwnProperty("allowLoadBytesCodeExecution")) {
					lc["allowLoadBytesCodeExecution"] = true;
				}
				loaderAnim.loadBytes(loaderBytes, lc);
			}
		}

		/**
		 * The loadContent method is called from frame 2 of the wrapper SWF when a content class
		 * name is supplied to the start() method. It is not generally used with end-user written
		 * code.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
 	 	 * @keyword loadContent
 	 	 * @see #start
		 */
		public function loadContent():void
		{
			var contentClass:Class = Class(mainTimeline.loaderInfo.applicationDomain.getDefinition(contentClassName));
			var contentBytes:ByteArray = ByteArray(new contentClass());
			mainTimeline.addChild(contentLoader);
			var lc:LoaderContext = new LoaderContext(false, mainTimeline.loaderInfo.applicationDomain);
			if (lc.hasOwnProperty("allowLoadBytesCodeExecution")) {
				lc["allowLoadBytesCodeExecution"] = true;
			}
			if (lc.hasOwnProperty("requestedContentParent")) {
				try {
					var targetParent:DisplayObjectContainer = mainTimeline.parent as DisplayObjectContainer;
					if (targetParent == null || targetParent is Loader) {
						targetParent = mainTimeline;
					}
				} catch (se:SecurityError) {
					targetParent = mainTimeline;
				}
				lc["requestedContentParent"] = targetParent;
			}
			if (lc.hasOwnProperty("parameters")) {
				lc["parameters"] = mainTimeline.loaderInfo.parameters;
			}
			contentLoader.loadBytes(contentBytes, lc);
		}

		/**
		 * @private
		 */
		protected function loaderAnimLoaded(e:Event):void
		{
			// pass pointer to self to the loader animation
			try {
				var fn:Function = loaderAnim.content["setRSLPreloader"] as Function;
				if (fn != null) {
					fn(this);
				}
			} catch (err:Error) {
			}
			loadRSLFiles();
		}

		/**
		 * @private
		 */
		protected function loaderAnimError(e:IOErrorEvent):void
		{
			try {
				mainTimeline.removeChild(loaderAnim);
			} catch (err:Error) {
			}
			loaderAnim = null;
			loadRSLFiles();
		}

		/**
		 * @private
		 */
		protected function loadRSLFiles(e:Event=null):void
		{
			// if debugWaitTime has been set to > 0, use enterFrame events to wait
			if (_debugWaitTime > 0) {
				if (debugWaitStart < 0) {
					debugWaitStart = getTimer();
					enterFrameClip = (mainTimeline == null) ? new MovieClip() : mainTimeline;
					enterFrameClip.addEventListener(Event.ENTER_FRAME, loadRSLFiles);
					return;
				}
				if ((getTimer() - debugWaitStart) < _debugWaitTime) {
					return;
				}
				enterFrameClip.removeEventListener(Event.ENTER_FRAME, loadRSLFiles);
				enterFrameClip = null;
			}

			for (var i:int = 0; i < _rslInfoList.length; i++) {
				var rslInfo:RSLInfo = _rslInfoList[i];
				rslInfo.addEventListener(ProgressEvent.PROGRESS, handleProgress, false, 0, true);
				rslInfo.addEventListener(Event.COMPLETE, loadComplete, false, 0, true);
				rslInfo.addEventListener(IOErrorEvent.IO_ERROR, loadFailed, false, 0, true);
				rslInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadFailed, false, 0, true);
				_rslInfoList[i].load();
			}
		}

		/**
		 * @private
		 */
		protected function loadComplete(e:Event):void
		{
			var rslInfo:RSLInfo = e.target as RSLInfo;
			if (rslInfo == null) return;

			e.target.removeEventListener(ProgressEvent.PROGRESS, handleProgress);
			e.target.removeEventListener(Event.COMPLETE, loadComplete);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, loadFailed);
			e.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loadFailed);
			numRSLComplete++;
			loaderList.push(rslInfo.loader);
			if (numRSLComplete + numRSLFailed >= _rslInfoList.length) finish();
		}

		/**
		 * @private
		 */
		protected function loadFailed(e:ErrorEvent):void
		{
			var rslInfo:RSLInfo = e.target as RSLInfo;
			if (rslInfo == null) return;

			if (rslInfo.failed) {
				e.target.removeEventListener(ProgressEvent.PROGRESS, handleProgress);
				e.target.removeEventListener(Event.COMPLETE, loadComplete);
				e.target.removeEventListener(IOErrorEvent.IO_ERROR, loadFailed);
				e.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loadFailed);
				failedURLs = (failedURLs == null) ? rslInfo.rslURLs : failedURLs.concat(rslInfo.rslURLs);
				numRSLFailed++;
				if (numRSLComplete + numRSLFailed >= _rslInfoList.length) finish();
			}
		}

		/**
		 * @private
		 */
		protected function handleProgress(e:ProgressEvent):void
		{
			var bytesLoaded:int, bytesTotal:int;
			for (var i:int = 0; i < _rslInfoList.length; i++) {
				var rslInfo:RSLInfo = _rslInfoList[i];
				if (!rslInfo.failed) {
					bytesLoaded += rslInfo.bytesLoaded;
					bytesTotal += rslInfo.bytesTotal;
				}
			}
			if (bytesTotal > 0) {
				dispatchEvent(new RSLEvent(RSLEvent.RSL_PROGRESS, false, false, numRSLComplete, numRSLFailed, _rslInfoList.length, bytesLoaded, bytesTotal));
			}
		}

		/**
		 * @private
		 */
		protected function finish():void
		{
			// signal load is done
			var calledFn:Boolean;
			try {
				if (loaderAnim != null) {
					var fn:Function;
					if (numRSLFailed > 0) {
						fn = loaderAnim.content["handleRSLError"] as Function;
						if (fn != null) {
							fn(completeCallback, numRSLComplete, numRSLFailed, failedURLs);
							calledFn = true;
						}
					} else {
						fn = loaderAnim.content["handleRSLComplete"] as Function;
						if (fn != null) {
							fn(completeCallback);
							calledFn = true;
						}
					}
				}
			} catch (err:Error) {
				calledFn = false;
			}

			// if signal function in loaderAnim was not called, finish now
			if (!calledFn) completeCallback();
		}

		/**
		 * @private
		 */
		protected function completeCallback():void
		{
			if (mainTimeline == null || contentClassName == null) {
				if (numRSLFailed > 0) {
					dispatchEvent(new RSLErrorEvent(RSLErrorEvent.RSL_LOAD_FAILED, false, false, numRSLComplete, numRSLFailed, _rslInfoList.length, failedURLs));
				} else {
					dispatchEvent(new RSLEvent(RSLEvent.RSL_LOAD_COMPLETE, false, false, numRSLComplete, numRSLFailed, _rslInfoList.length));
				}
			} else {
				// goto frame 2. Once frame 2 is loaded, it will call loadContent()
				mainTimeline.play();
			}
		}

		/**
		 * @private
		 */
		protected function contentInit(e:Event):void
		{
			// remove loaderAnim if necessary
			if (loaderAnim != null) {
				// remove background shape
				try {
					mainTimeline.removeChild(mainTimeline.getChildAt(0));
				} catch (err:Error) {
				}
				// unload and remove loaderAnim
				try {
					mainTimeline.removeChild(loaderAnim);
				} catch (err:Error) {
				}
				if (loaderAnim.hasOwnProperty("unloadAndStop")) {
					loaderAnim.unloadAndStop(true);
				} else {
					loaderAnim.unload();
				}
			}

			// hand loaderList to real content to avoid garbage collection
			contentLoader.content["__rslLoaders"] = loaderList;

			// give ProLoader chance to reparent parent first. We cannot really know if our parent
			// is who it should be, so we always do this, generating some extra added and removed
			// events and possibly confusing content that is overriding addChild to do some fancy
			// mojo, unfortunately.
			try {
				var container:DisplayObjectContainer = DisplayObjectContainer(contentLoader.content);
				var specialShape:Shape = new Shape();
				container.addChild(specialShape);
				mainTimeline.loaderInfo.sharedEvents.dispatchEvent(new ProLoaderRSLPreloaderSandboxEvent(ProLoaderRSLPreloaderSandboxEvent.PROLOADER_RSLPRELOADER_SANDBOX, false, false, null, specialShape));
				container.removeChild(specialShape);
			} catch (err:Error) {
			}

			// replace mainTimeline on stage if it is on a Stage, otherwise put within mainTimeline
			var contentParent:DisplayObject = null;
			try {
				contentParent = contentLoader.content.parent
			} catch (se:SecurityError) {
				contentParent = null;
			}
			if (contentParent == contentLoader) {
				var myStage:Stage;
				try {
					myStage = mainTimeline.parent as Stage;
				} catch (se:SecurityError) {
					myStage = null;
				}
				if (myStage == null) {
					mainTimeline.addChild(contentLoader.content);
				} else {
					myStage.addChildAt(contentLoader.content, myStage.getChildIndex(mainTimeline));
					try {
						myStage.removeChild(mainTimeline);
					} catch (err:Error) {
					}
				}
			} else {
				try {
					mainTimeline.parent.removeChild(mainTimeline);
				} catch (err:Error) {
				}
			}

			// cleanup myself
			try {
				if (mainTimeline["__rslPreloader"] == this) {
					mainTimeline["__rslPreloader"] = null;
				}
			} catch (err:Error) {
			}
		}

	}

}

