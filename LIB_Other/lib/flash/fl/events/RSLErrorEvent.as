package fl.events {

	import flash.events.Event;
	import flash.events.ErrorEvent;
	/**
	* The RSLErrorEvent class defines an error event dispatched by <code>RSLPreloader</code>. This event
	* indicates that the download of RSLs has failed, and provides information on the files that have failed
	* and the number of files, both attempted and failed. When a custom event preloading loop is used, and the 
	* RSLPreloader code is generated automatically by Flash authoring, this event is 
	* dispatched by the main timeline. In this case, use <code>addEventListener</code> without needing to 
	* reference the RSLPreloader.
	*
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
	* @see fl.rsl.RSLPreloader
	*/
	public class RSLErrorEvent extends ErrorEvent
	{
		/**
		 * Error dispatched by <code>RSLPreloader</code> when all RSLs have finished
		 * downloading and one or more have failed. When preloading with a custom event loop, user 
		 * content MUST listen for this event to determine when to exit the loading animation loop. 
		 *
		 * <p>This event has the following properties:</p>
		 * <table class="innertable" width="100%">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td><code>true</code></td></tr>
		 *     <tr><td><code>cancelable</code></td><td><code>false</code>; there is no default behavior to cancel.</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The object that is actively processing the Event 
		 * object with an event listener.</td></tr>
		 *     <tr><td><code>target</code></td><td>The DisplayObject instance being added to the display list.
		 * The <code>target</code> is not always the object in the display list 
		 * that registered the event listener. Use the <code>currentTarget</code> 
		 * property to access the object in the display list that is currently processing the event.</td></tr>
		 *     <tr><td><code>rslsLoaded</code></td><td>The number of files that have downloaded successfully.</td></tr>
		 *     <tr><td><code>rslsFailed</code></td><td>the number of files that have failed to download.</td></tr>
		 *     <tr><td><code>rslsTotal</code></td><td>the total number of files that have downloaded, successfully or not.</td></tr>		
		 *     <tr><td><code>failedURLs</code></td><td>An array of files that have failed to download.</td></tr>
		 *  </table>		 
		 * <listing>
		 * import fl.events.RSLErrorEvent;
		 * myPreloader.addEventListener(RSLErrorEvent.RSL_LOAD_FAILED, rslLoadFailedHandler);
		 * function rslLoadFailedHandler(e:RSLErrorEvent) {
		 * gotoAndPlay('rslLoadFailure');
		 * }
		 * </listing>
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
		 * @keyword RSL_LOAD_FAILED
 	 	 * @see fl.rsl.RSLPreloader
		 */
		public static const RSL_LOAD_FAILED:String = "rslLoadFailed";

		private var _rslsLoaded:int;
		private var _rslsFailed:int;
		private var _rslsTotal:int;
		private var _failedURLs:Array;

		/**
		 * Creates an RSLErrorEvent object that contains information about RSLError events. RSLErrorEvent objects are passed as parameters to event listeners. 
		 * @param type The type of the event. Possible values are: <code>RSLEvent.RSL_LOAD_COMPLETE</code> and <code>RSLEvent.RSL_PROGRESS</code>.
		 * @param bubbles Determines whether the Event object participates in the bubbling stage of the event flow. 
		 * @param cancelable Determines whether the Event object can be canceled. 
		 * @param rslsLoaded The number of files that have downloaded successfully.
		 * @param rslsFailed The number of files that have failed to download.
		 * @param rslsTotal The total number of files that have downloaded, successfully or not.
		 * @param failedURLs An array of files that have failed to download.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
		 */
		public function RSLErrorEvent( type:String, bubbles:Boolean=false, cancelable:Boolean=false,
		                               rslsLoaded:int=0, rslsFailed:int=0, rslsTotal:int=0, failedURLs:Array=null)
		{
			super(type, bubbles, cancelable);
			_rslsLoaded = rslsLoaded;
			_rslsFailed = rslsFailed;
			_rslsTotal = rslsTotal;
			_failedURLs = failedURLs;
		}
		/**
		 * Returns the number of files that have downloaded successfully.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
		 */
		public function get rslsLoaded():int
		{
			return _rslsLoaded;
		}
		/**
		 * Returns the number of files that have failed to download.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
		 */
		public function get rslsFailed():int
		{
			return _rslsFailed;
		}
		/**
		 * Returns the total number of files that have downloaded, successfully or not.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
		 */
		public function get rslsTotal():int
		{
			return _rslsTotal;
		}
		/**
		 * Returns an array of files that have failed to download.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
		 */
		public function get failedURLs():Array
		{
			return _failedURLs;
		}

		/**
		 * @private
		 */
		override public function clone():Event 
		{
			return new RSLErrorEvent(type, bubbles, cancelable, rslsLoaded, rslsFailed, rslsTotal, failedURLs);
		}

	}

}