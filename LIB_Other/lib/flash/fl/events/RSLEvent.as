package fl.events {

	import flash.events.Event;
	/**
	* The RSLEvent class defines events dispatched by <code>RSLPreloader</code>. These events
	* indicate progress in downloading RSLs, including information on the number of files and 
	* the number of bytes loaded. When a custom event preloading loop is used, and the 
	* RSLPreloader code is generated automatically by Flash authoring, these events are 
	* dispatched by the main timeline. In this case, use <code>addEventListener</code> without needing to 
	* reference the RSLPreloader.
	*
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
	* @see fl.rsl.RSLPreloader
	*/
	public class RSLEvent extends Event
	{
		/**
		 * Event dispatched by <code>RSLPreloader</code> when all RSLs have successfully
		 * downloading. The <code>bytesLoaded</code> and <code>bytesTotal</code> properties
		 * are always 0 for this event type. When preloading with a custom event loop, user 
		 * content MUST listen for this event to determine when to exit the loading animation loop. 
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
		 *     <tr><td><code>bytesLoaded</code></td><td>The total number of downloaded bytes in files that have successfully downloaded. </td></tr>
		 *     <tr><td><code>bytesTotal</code></td><td>the total number of downloaded bytes in files that have downloaded, successful or not.</td></tr>			 
		 *  </table>
		 * <listing>
		 * import fl.events.RSLEvent;
		 * myPreloader.addEventListener(RSLEvent.RSL_LOAD_COMPLETE, loadComplete);
		 * function loadComplete(e:RSLEvent) {
		 * gotoAndPlay('startOfContent');
		 * }
		 * </listing>
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
		 * @see fl.rsl.RSLPreloader
		 */
		public static const RSL_LOAD_COMPLETE:String = "rslLoadComplete";

		/**
		 * Event dispatched by <code>RSLPreloader</code> to indicate progress in
		 * downloading RSL files.  This is the only event type for which the 
		 * <code>bytesLoaded</code> and <code>bytesTotal</code>
		 * properties are non-zero.
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
		 *     <tr><td><code>bytesLoaded</code></td><td>The total number of downloaded bytes in files that have successfully downloaded. </td></tr>
		 *     <tr><td><code>bytesTotal</code></td><td>the total number of downloaded bytes in files that have downloaded, successful or not.</td></tr>			 
		 *  </table>
		 * <listing>
		 * import fl.events.RSLEvent;
		 * myPreloader.addEventListener(RSLEvent.RSL_PROGRESS, progressHandler);
		 * function progressHandler(e:RSLEvent) {
		 * trace('rslsLoaded = ' + e.rslsLoaded);
		 * trace('rslsFailed = ' + e.rslsFailed);
		 * trace('rslsTotal = ' + e.rslsTotal);
		 * trace('bytesLoaded = ' + e.bytesLoaded);
		 * trace('bytesTotal = ' + e.bytesTotal);
		 * }
		 * </listing>
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
		 * @see fl.rsl.RSLPreloader
		 */
		public static const RSL_PROGRESS:String = "rslProgress";

		private var _rslsLoaded:int;
		private var _rslsFailed:int;
		private var _rslsTotal:int;
		private var _bytesLoaded:int;
		private var _bytesTotal:int;

		/**
		 * Creates an Event object with specific information relevant to RSL events.
		 * @param type The type of the event. Possible values are: <code>RSLEvent.RSL_LOAD_COMPLETE</code> and <code>RSLEvent.RSL_PROGRESS</code>.
		 * @param bubbles Determines whether the Event object participates in the bubbling stage of the event flow. 
		 * @param cancelable Determines whether the Event object can be canceled. 
		 * @param rslsLoaded The number of files that have downloaded successfully.
		 * @param rslsFailed The number of files that have failed to download.
		 * @param rslsTotal The total number of files that have downloaded, successfully or not.
		 * @param bytesLoaded The total number of downloaded bytes in files that have successfully downloaded.
		 * @param bytesTotal The total number of downloaded bytes in files that have downloaded, successful or not.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
		 */
		public function RSLEvent( type:String, bubbles:Boolean=false, cancelable:Boolean=false,
		                          rslsLoaded:int=0, rslsFailed:int=0, rslsTotal:int=0, bytesLoaded:int=0, bytesTotal:int=0 )
		{
			super(type, bubbles, cancelable);
			_rslsLoaded = rslsLoaded;
			_rslsFailed = rslsFailed;
			_rslsTotal = rslsTotal;
			_bytesLoaded = bytesLoaded;
			_bytesTotal = bytesTotal;
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
		 * Returns the total number of downloaded bytes in files that have successfully downloaded.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
		 */
		public function get bytesLoaded():int
		{
			return _bytesLoaded;
		}
		/**
		 * Returns the total number of downloaded bytes in files that have downloaded, successful or not.
		 *
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
		 */
		public function get bytesTotal():int
		{
			return _bytesTotal;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event 
		{
			return new RSLEvent(type, bubbles, cancelable, rslsLoaded, rslsFailed, rslsTotal, bytesLoaded, bytesTotal);
		}

	}

}