package fl.display {

	import fl.events.ProLoaderRSLPreloaderSandboxEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.errors.IllegalOperationError;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;

	/**
	 * This class is used by ProLoader in place of LoaderInfo. It mirrors LoaderInfo APIs for 
	 * safe loading of SWF files that use TLF with default RSL preloading
	 * settings. This class is designed to be backwards-compatible to Flash Player 9. 
	 * 
	 * <p>Some members of this class, including <code>childSandboxBridge</code> and <code>parentSandboxBridge</code>,
	 * are not supported in all versions of Flash Player and AIR. Call these properties only
	 * when your published AIR or Flash Player version supports them. Calling these properties in other contexts results in runtime errors.</p>
         *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS5.5
     * @langversion 3.0
     * @playerversion Lite 4
     * @tiptext ProLoader uses ProLoaderInfo instead of LoaderInfo.
     * @see fl.display.ProLoader
     * @see flash.display.Loader
	 */

	/*
	 * If you are using AIR and you need access to the childSandboxBridge or parentSandboxBridge
	 * properties, you can uncomment them in the code below.
	 */
	public class ProLoaderInfo extends EventDispatcher{

		private var _proLoader:ProLoader;
		private var _realLI:LoaderInfo;
		private var _realContentLI:LoaderInfo;
		private var _rslPreloaderLoaded:Boolean;
		private var _doneProgressStalling:Boolean;
		private var _numAdded:int;

		/**
		 * @private
		 */
		var _lcRequestedContentParentSet:Boolean;

		/**
		 * it is never useful to create a ProLoaderInfo directly. It should always
		 * be created by the ProLoader and accessed via the contentLoaderInfo property.
		 *
		 * @private
		 */
		public function ProLoaderInfo(l:ProLoader)
		{
			_realContentLI = null;
			_lcRequestedContentParentSet = false;
			_rslPreloaderLoaded = false;
			_doneProgressStalling = false;
			_numAdded = 0;

			_proLoader = l;
			_realLI = l.realLoader.contentLoaderInfo;

			_realLI.addEventListener(AsyncErrorEvent.ASYNC_ERROR, handleAsyncErrorEvent, false, 0, true);
			_realLI.addEventListener(Event.COMPLETE, handleLoaderInfoEvent, false, 0, true);
			_realLI.addEventListener(HTTPStatusEvent.HTTP_STATUS, handleLoaderInfoEvent, false, 0, true);
			_realLI.addEventListener(Event.INIT, handleLoaderInfoEvent, false, 0, true);
			_realLI.addEventListener(IOErrorEvent.IO_ERROR, handleLoaderInfoEvent, false, 0, true);
			_realLI.addEventListener(Event.OPEN, handleLoaderInfoEvent, false, 0, true);
			_realLI.addEventListener(ProgressEvent.PROGRESS, handleProgressEvent, false, 0, true);
			_realLI.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityErrorEvent, false, 0, true);
			_realLI.addEventListener(Event.UNLOAD, handleLoaderInfoEvent, false, 0, true);
		}

		/**
		 * @private
		 */
		function reset():void
		{
			_realContentLI = null;
			_rslPreloaderLoaded = false;
			_doneProgressStalling = false;
			_lcRequestedContentParentSet = false;
		}

		/**
         * @copy flash.display.LoaderInfo#actionScriptVersion
         * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
		 * @see flash.display.LoaderInfo#actionScriptVersion
         * @see flash.display.ActionScriptVersion
         * @tiptext The ActionScript version of the loaded SWF file.
		 */
		public function get actionScriptVersion():uint
		{
			return _realLI.actionScriptVersion;
		}

		/**
         * @copy flash.display.LoaderInfo#applicationDomain
         * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
		 * @see flash.display.LoaderInfo#applicationDomain
         * @tiptext This property contains all ActionScript 3.0 definitions from the loaded class.
		 */
		public function get applicationDomain():ApplicationDomain
		{
			return _realLI.applicationDomain;
		}

		/**
         * The bytes associated with a ProLoaderInfo object. 
         * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
		 * @see flash.display.LoaderInfo#bytes
         * @tiptext The bytes associated with a ProLoaderInfo object.
		 */
		public function get bytes():ByteArray
		{
			return _realLI.bytes;
		}

		/**
         * @copy flash.display.LoaderInfo#bytesLoaded
         * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
		 * @see flash.display.LoaderInfo#bytesLoaded
         * @tiptext The number of bytes currently loaded for the media.
		 */
		public function get bytesLoaded():uint
		{
			// prevent bytesLoaded from equalling bytesTotal until we are certain that everything
			// is loaded completely correctly. Users should not rely on this to assume that everything
			// is ready, they should be using the init and complete events, but just in case.
			if (_realLI.bytesLoaded >= _realLI.bytesTotal && _proLoader.content == null) {
				return _realLI.bytesTotal - 1;
			}
			return _realLI.bytesLoaded;
		}

		/**
         * Before the first <code>progress</code> event is dispatched by this object's corresponding ProLoader object,
         * <code>bytesTotal</code> is 0. After the first progress event from the ProLoader object, <code>bytesTotal</code> 
         * reflects the actual number of bytes to be downloaded.
         * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
		 * @see flash.display.LoaderInfo#bytesTotal
         * @tiptext The number of bytes to be downloaded.
		 */
		public function get bytesTotal():uint
		{
			return _realLI.bytesTotal;
		}

		/**
         * Expresses the trust relationship from content (child) to the ProLoader (parent). 
         * If the child has allowed the parent access, <code>true</code>; otherwise, 
         * <code>false</code>. This property is set to <code>true</code> if the child object 
         * has called the <code>allowDomain()</code> method to grant permission to the parent domain 
         * or if a URL policy is loaded at the child domain that grants permission
         * to the parent domain. If child and parent are in 
         * the same domain, this property is set to <code>true</code>.
         * 
         * <p>For more information related to security, see the Flash Player Developer Center Topic: 
         * <a href="http://www.adobe.com/go/devnet_security_en" target="external">Security</a>.</p>
         * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
		 * @see flash.display.LoaderInfo#childAllowsParent
		 */
		public function get childAllowsParent():Boolean
		{
			return _realLI.childAllowsParent;
		}

		/**
	 * An object that can be set by the loaded content's code to expose properties and methods that can be accessed 
	 * by code in the ProLoader object's sandbox. This <em>sandbox bridge</em> lets content from a non-application domain have 
	 * controlled access to scripts in the AIR application sandbox, and vice versa. The sandbox bridge serves as a gateway between 
	 * the sandboxes, providing explicit interaction between application and non-application security sandboxes. 
	 * 
	 * @throws SecurityError Only content in the loaded content's sandbox can set this property.
	 * 
	 * @see #parentSandboxBridge
		 *
		 * @playerversion AIR 1.0
		 * @productversion Flash CS5.5 
		 * @langversion 3.0
		 * @see flash.display.LoaderInfo#childSandboxBridge
		 */
		public function get childSandboxBridge():Object
		{
			if (_realContentLI != null) return _realContentLI["childSandboxBridge"];
			return _realLI["childSandboxBridge"];
		}

		/**
		 * @private
		 */
		public function set childSandboxBridge(value:Object):void
		{
			if (_realContentLI != null) {
				_realContentLI["childSandboxBridge"] = value;
			} else {
				_realLI["childSandboxBridge"] = value;
			}
		}

		/**
         * The loaded object associated with this ProLoaderInfo object. 
         * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
		 * @see flash.display.LoaderInfo#content
         * @tiptext The loaded object associated with this ProLoaderInfo object. 
		 */
		public function get content():DisplayObject
		{
			return _proLoader.content;
		}

		/**
         * @copy flash.display.LoaderInfo#contentType
         * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
		 * @see flash.display.LoaderInfo#contentType
         * @tiptext The MIME type of the loaded file.
		 */
		public function get contentType():String
		{
			return _realLI.contentType;
		}

		/**
         * @copy flash.display.LoaderInfo#frameRate      
         * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
         * @see flash.display.LoaderInfo#frameRate
         * @tiptext The nominal frame rate, in frames per second, of the loaded SWF file.
		 */
		public function get frameRate():Number
		{
			return _realLI.frameRate;
		}

		/**
         * @copy flash.display.LoaderInfo#height   
         * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
         * @see flash.display.LoaderInfo#height
         * @tiptext The nominal height of the loaded file.
		 */
		public function get height():int
		{
			return _realLI.height;
		}

		/**
	 * Indicates if the <code>ProLoaderInfo.url</code> property has been
	 * truncated. When the <code>isURLInaccessible</code> value is <code>true</code> the 
	 * <code>ProLoaderInfo.url</code> value is only the domain of the final URL from which the content loaded.
	 * For example, the property is truncated if the content is loaded from <code>http://www.adobe.com/assets/hello.swf</code>,
	 * and the <code>ProLoaderInfo.url</code> property has the value <code>http://www.adobe.com</code>. The <code>isURLInaccessible</code>
	 * value is <code>true</code> only when all of the following are also true:
	 *
	 * <ul>
	 * <li>An HTTP redirect occurred while loading the content.</li>
	 * <li>The SWF file calling <code>ProLoader.load()</code> is from a different domain than
	 * the content's final URL.</li>
	 * <li>The SWF file calling <code>ProLoader.load()</code> does not have permission to access
	 * the content. Permission is granted to access the content the same way permission is granted for
	 * <code>BitmapData.draw()</code>:
	 * call <code>Security.allowDomain()</code> to access a SWF file
	 * (or for non-SWF file content, establish a policy file and use the <code>LoaderContext.checkPolicyFile</code>
	 * property).</li>
	 * </ul>
	 *
	 * <p><strong>Note:</strong> The <code>isURLInaccessible</code> property was added for Flash Player 10.1 and AIR 2.0.
	 * However, this property is made available to SWF files of all versions when the
	 * Flash runtime supports it. So, using some authoring tools in "strict mode" causes a compilation error. To work around the error
	 * use the indirect syntax <code>myLoaderInfo["isURLInaccessible"]</code>, or disable strict mode. If you are using Flash Professional CS5
	 * or Flex SDK 4.1, you can use and compile this API for runtimes released before Flash Player 10.1 and AIR 2.</p>
	 *
	 * <p>For application content in AIR, the value of this property is always <code>false</code>.</p>
	 *
	 * @see #url
	 * @see BitmapData#draw()
	 * @see flash.system.Security#allowDomain()
     * @see flash.system.LoaderContext#checkPolicyFile
		 *
		 * @playerversion Flash 10.1
 		 * @productversion Flash CS5.5		 
		 * @playerversion AIR 2
		 * @langversion 3.0
         * @see flash.display.LoaderInfo#height
		 */
		public function get isURLInaccessible():Boolean
		{
			return _realLI.isURLInaccessible;
		}

		/**
         * The ProLoader object associated with this ProLoaderInfo object. If this ProLoaderInfo object is the 
         * loaderInfo property of the instance of the main class of the SWF file, no ProLoader object is associated. 
         * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
         * @see flash.display.LoaderInfo#loader
         * @tiptext The ProLoader object associated with this ProLoaderInfo object.
		 */
		public function get loader():ProLoader
		{
			return _proLoader;
		}

		/**
	 * The URL of the SWF file that initiated the loading of the media
	 * described by this ProLoaderInfo object.  For the instance of the main class of the SWF file, this
	 * URL is the same as the SWF file's own URL.
	 *         
	 * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
         * @see flash.display.LoaderInfo#loaderURL
         * @tiptext The URL of the SWF file that initiated the loading of the media described by this ProLoaderInfo object. 
		 */
		public function get loaderURL():String
		{
			return _realLI.loaderURL;
		}

		/**
	 * An object that contains name-value pairs that represent the parameters provided
	 * to the loaded SWF file.
	 *
	 * <p>You can use a <code>for-in</code> loop to extract all the names and values
	 * from the <code>parameters</code> object.</p>
	 *
	 * <p>The two sources of parameters are: the query string in the
	 * URL of the main SWF file, and the value of the <code>FlashVars</code> HTML parameter (this affects
	 * only the main SWF file).</p>
	 *
	 * <p>The <code>parameters</code> property replaces the ActionScript 1.0 and 2.0 technique of
	 * providing SWF file parameters as properties of the main timeline.</p>
	 *
	 * <p>The value of the <code>parameters</code> property is null for ProLoader objects
	 * that contain SWF files that use ActionScript 1.0 or 2.0. It is only
	 * non-null for ProLoader objects that contain SWF files that use ActionScript 3.0.</p>
	 * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
         * @see flash.display.LoaderInfo#parameters
         * @tiptext An object that contains name-value pairs that represent the parameters provided to the loaded SWF file. 
		 */
		public function get parameters():Object
		{
			return _realLI.parameters;
		}

		/**
        * Expresses the trust relationship from ProLoader (parent) to the content (child). 
        * If the parent has allowed the child access, <code>true</code>; otherwise, 
        * <code>false</code>. This property is set to <code>true</code> if the parent object 
        * called the <code>allowDomain()</code> method to grant permission to the child domain 
        * or if a URL policy file is loaded at the parent domain granting permission
        * to the child domain. If child and parent are in 
        * the same domain, this property is set to <code>true</code>.
        * 
        * <p>For more information related to security, see the Flash Player Developer Center Topic: 
        * <a href="http://www.adobe.com/go/devnet_security_en" target="external">Security</a>.</p>
        * 
        * @throws Error  Thrown if the file is not downloaded sufficiently 
        * to retrieve the requested information.
         * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
         * @see flash.display.LoaderInfo#parentAllowsChild
         * @tiptext Expresses the trust relationship from ProLoader (parent) to the content (child).
		 */
		public function get parentAllowsChild():Boolean
		{
			return _realLI.parentAllowsChild;
		}

		/**
	 * A object that can be set by code in the ProLoader object's sandbox to expose properties and methods that can be accessed 
	 * by the loaded content's code. This <em>sandbox bridge</em> lets content from a non-application domain have controlled 
	 * access to scripts in the AIR application sandbox, and vice versa. The sandbox bridge serves as a gateway between 
	 * the sandboxes, providing explicit interaction between application and non-application security sandboxes. 
	 * 
	 * @throws SecurityError Only content in the ProLoader object's sandbox can set this property.
	 * 
	 * @see #childSandboxBridge
	 *
		 * @playerversion AIR 1.0
         * @productversion Flash CS5.5
		 * @langversion 3.0
         * @see flash.display.LoaderInfo#parentSandboxBridge
         * @tiptext An object that can be set by code in the ProLoader object's sandbox to expose properties and methods that 
         * can be accessed by the loaded content's code.
		 */
		public function get parentSandboxBridge():Object
		{
			if (_realContentLI != null) {
				return _realContentLI["parentSandboxBridge"];
			}
			return _realLI["parentSandboxBridge"];
		}

		/**
		 * @private
		 */
		public function set parentSandboxBridge(value:Object)
		{
			if (_realContentLI != null) {
				_realContentLI["parentSandboxBridge"] = value;
			} else {
				_realLI["parentSandboxBridge"] = value;
			}
		}

		/**
         * @copy flash.display.LoaderInfo#sameDomain 
         * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
         * @see flash.display.LoaderInfo#sameDomain
         * @tiptext Expresses the domain relationship between the loader and the content.
		 */
		public function get sameDomain():Boolean
		{
			return _realLI.sameDomain;
		}

		/**
		 * Because of timing issues when loading content that does RSL preloading, it is recommended to wait
		 * until the init event is received to add event listeners to the sharedEvents object, or to add them
		 * again when the init event is received.
		 *
         * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
         * @see flash.display.LoaderInfo#sharedEvents
		 */
		public function get sharedEvents():EventDispatcher
		{
			if (_realContentLI != null) return _realContentLI.sharedEvents;
			return _realLI.sharedEvents;
		}

		/**
         * @copy flash.display.LoaderInfo#swfVersion
         * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
         * @see flash.display.LoaderInfo#swfVersion
         * @tiptext The file format version of the loaded SWF file.
		 */
		public function get swfVersion():uint
		{
			return _realLI.swfVersion;
		}

		/**
	 * The URL of the media being loaded.
	 *
	 * <p>Before the first <code>progress</code> event is dispatched by this ProLoaderInfo 
	 * object's corresponding ProLoader object, the value of the <code>url</code> property
	 * might reflect only the initial URL specified in the call to the <code>load()</code> 
	 * method  of the ProLoader object.  After the first <code>progress</code> event, the 
	 * <code>url</code> property reflects the media's final URL, after any redirects and relative 
	 * URLs are resolved.</p>
         * <p>In some cases, the value of the <code>url</code> property is truncated; see the 
         * <code>isURLInaccessible</code> property for details.</p>
         * @tiptext The URL of the media being loaded. 
         * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
	 */
		public function get url():String
		{
			return _realLI.url;
		}

	 /**
         * @copy flash.display.LoaderInfo#width
         * @playerversion Flash 9
         * @playerversion AIR 1.0
         * @productversion Flash CS5.5
         * @langversion 3.0
         * @playerversion Lite 4
         * @see flash.display.LoaderInfo#width
         * @tiptext The nominal width of the loaded content.
		 */
		public function get width():int
		{
			return _realLI.width;
		}

		/**
		 * @private Calling the <code>dispatchEvent()</code> method of a ProLoaderInfo instance throws an exception.
		 */
		public override function dispatchEvent(event:Event):Boolean
		{
			Error.throwError(IllegalOperationError, 2118);
			return false; // unreachable
		}

		private function handleAsyncErrorEvent(e:AsyncErrorEvent):void
		{
			// AsyncErrorEvent always related to failure of LoaderContext.parent so
			// if LoaderContext.parent was set up by the ProLoader, suppress this error event
			if (!_lcRequestedContentParentSet) {
				super.dispatchEvent(e);
			}
		}

		private function handleLoaderInfoEvent(e:Event):void
		{
			switch (e.type) {
			case HTTPStatusEvent.HTTP_STATUS:
			case IOErrorEvent.IO_ERROR:
			case Event.OPEN:
			case Event.UNLOAD:
				// just forward these events
				super.dispatchEvent(e);
				break;
			case Event.INIT:
				var theContent:DisplayObject;
				if (!_rslPreloaderLoaded) {
					// check if we have loaded an RSL preloader SWF
					// this is the OLD way of checking that is compatible with CS5 but
					// can stumble when dealing with sandboxed content
					try {
						theContent = _realLI.content;
						var theName:String = getQualifiedClassName(theContent);
						if (theName.substr(-13) == "__Preloader__") {
							var rslPreloader:Object = theContent["__rslPreloader"];
							if (rslPreloader != null) {
								theName = getQualifiedClassName(rslPreloader);
								if (theName == "fl.rsl::RSLPreloader") {
									_rslPreloaderLoaded = true;
									_numAdded = 0;
									theContent.addEventListener(Event.ADDED, handleAddedEvent, false, 0, true);
								}
							}
						}
					} catch (err:Error) {
						_rslPreloaderLoaded = false;
					}
				}
				if (!_rslPreloaderLoaded) {
					_proLoader.loadDoneCallback(theContent);
					if (!_doneProgressStalling && _realLI.bytesLoaded >= _realLI.bytesTotal) {
						_doneProgressStalling = true;
						super.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _realLI.bytesLoaded, _realLI.bytesTotal));
					}
					super.dispatchEvent(e);
				}
				break;
			case Event.COMPLETE:
				if (!_rslPreloaderLoaded) super.dispatchEvent(e);
				break;
			}
		}

		private function handleProgressEvent(e:ProgressEvent):void
		{
			// don't dispatch event with progress at 100% completion until
			// we have determined whether we need to stall for the RSL preload
			// to complete
			if (_doneProgressStalling || e.bytesLoaded < e.bytesTotal) {
				super.dispatchEvent(e);
			}
		}

		private function handleSecurityErrorEvent(e:SecurityErrorEvent):void
		{
			// if event is related to failure of LoaderContext.parent and
			// LoaderContext.parent was set up by the ProLoader, then suppress
			// this error event
			if (!_lcRequestedContentParentSet || e.errorID != 2047) {
				super.dispatchEvent(e);
			}
		}

		private function handleAddedEvent(e:Event):void
		{
			// check to ensure this was actually something added to the Loader.content
			var c:DisplayObject = e.target as DisplayObject;
			var p:DisplayObjectContainer = e.currentTarget as DisplayObjectContainer;
			if (c != null && p != null && c.parent == p) {
				_numAdded++;
			}
			// the first thing added will be the loader animation swf, so ignore that
			if (_numAdded > 1) {
				e.currentTarget.removeEventListener(Event.ADDED, handleAddedEvent);
				// if the load was cancelled, then loadDoneCallback() will return false
				if (_proLoader.loadDoneCallback(c)) {
					if (!_doneProgressStalling && _realLI.bytesLoaded >= _realLI.bytesTotal) {
						_doneProgressStalling = true;
						super.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _realLI.bytesLoaded, _realLI.bytesTotal));
					}
					super.dispatchEvent(new Event(Event.INIT, false, false));
					super.dispatchEvent(new Event(Event.COMPLETE, false, false));
				}
			}
		}

		/**
		 * @private
		 */
		function set realContentLoaderInfo(value:LoaderInfo):void
		{
			_realContentLI = value;
			_realContentLI.addEventListener(Event.COMPLETE, handleRealContentEvent, false, 0, true);
			_realContentLI.addEventListener(Event.INIT, handleRealContentEvent, false, 0, true);
			_realContentLI.addEventListener(IOErrorEvent.IO_ERROR, handleLoaderInfoEvent, false, 0, true);
			_realContentLI.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityErrorEvent, false, 0, true);
			_rslPreloaderLoaded = true;
			if (_realContentLI.hasOwnProperty("childSandboxBridge")) {
				var obj:Object;
				try {
					obj = _realLI["childSandboxBridge"];
					if (obj != null) {
						_realContentLI["childSandboxBridge"] = obj;
					}
				} catch (se:SecurityError) {
				}
				try {
					obj = _realLI["parentSandboxBridge"];
					if (obj != null) {
						_realContentLI["parentSandboxBridge"] = obj;
					}
				} catch (se:SecurityError) {
				}
			}
		}

		/**
		 * @private
		 */
		function get realContentLoaderInfo():LoaderInfo
		{
			return _realContentLI;
		}

		private function handleRealContentEvent(e:Event):void
		{
			if (e.type == Event.INIT) {
				var d:DisplayObject;
				try {
					d = _realContentLI.content;
				} catch (se:SecurityError) {
					d = null;
				}
				_proLoader.loadDoneCallback(d);
				if (!_doneProgressStalling && _realLI.bytesLoaded >= _realLI.bytesTotal) {
					_doneProgressStalling = true;
					super.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _realLI.bytesLoaded, _realLI.bytesTotal));
				}
			}
			super.dispatchEvent(e);
		}

	}
}