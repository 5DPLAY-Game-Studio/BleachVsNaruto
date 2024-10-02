package net.play5d.game.bvn.ui.bigmap
{
	import flash.display.MovieClip;
	
	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.utils.ResUtils;

	public class CloudView
	{
		public var speed:Number = 0;
		public var mc:MovieClip;
		
		public function CloudView(X:Number, Y:Number)
		{
			mc = ResUtils.I.createDisplayObject(ResUtils.swfLib.bigMap, 'cloud_mc');
//			mc.x = (20 - mc.width) + (GameConfig.GAME_SIZE.x - 50) * Math.random();
			mc.x = X;
			mc.y = Y;
			mc.alpha = 0.2 + Math.random() * 0.3;
			mc.gotoAndStop(1 + int(Math.random() * mc.totalFrames));
			speed = 0.02 + Math.random() * 0.1;
			
//			trace('addCloud::', mc.x, mc.y, mc.alpha, mc.currentFrame, speed);
		}
		
		public function render():Boolean{
			mc.y -= speed;
			return mc.y < -mc.height + 30;
		}
		
	}
}