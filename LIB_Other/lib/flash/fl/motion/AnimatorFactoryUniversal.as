package fl.motion
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;


     /**
     * The AnimatorFactoryUniversal class provides ActionScript-based support to associate one Motion object with multiple
     * display objects. AnimatorFactoryUniversal supports both traditional and three-dimensional animation.
     * <p>Use the AnimatorFactoryUniversal constructor to create an AnimatorFactoryUniversal instance. Then,
     * use the methods inherited from the 
     * AnimatorFactoryBase class to associate the desired properties with display objects.</p>
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @see fl.motion.AnimatorUniversal
     * @see fl.motion.AnimatorFactoryBase
     * @see fl.motion.Motion
     * @see fl.motion.MotionBase
     */
	public class AnimatorFactoryUniversal extends AnimatorFactoryBase
	{	
	
     /**
     * Creates an AnimatorFactory instance you can use to assign the properties of
     * a MotionBase object to display objects. 
     * @param motion The MotionBase object containing the desired motion properties.
     * .
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @see fl.motion.Animator
     * @see fl.motion.AnimatorFactoryBase
     * @see fl.motion.Motion
     * @see fl.motion.MotionBase
     */	
		public function AnimatorFactoryUniversal(motion:MotionBase, motionArray:Array)
		{
			super(motion, motionArray);
		}
		
		/**
		* @private
		*/
		protected override function getNewAnimator():AnimatorBase
		{
			return new AnimatorUniversal();
		}
	}
}