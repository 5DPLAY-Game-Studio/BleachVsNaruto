package net.play5d.game.bvn.views.effects
{
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	import net.play5d.game.bvn.ctrl.AssetManager;

	public class BishaFaceEffectView
	{
		public var mc:MovieClip;
		private var _faceObj:Object = {};
		public function BishaFaceEffectView()
		{
			mc = AssetManager.I.getEffect("bisha_face_mc");
		}
		
		/**
		 * 设置角色图
		 * @param faceId 1 | 2
		 * @param face
		 */
		public function setFace(faceId:int , face:DisplayObject):void{
			var facemc:MovieClip = mc['facemc'+faceId];
			if(!facemc) return;
			
			_faceObj[faceId] = face;
			face.width = 254;
			face.height = 180;
			facemc.addChild(face);
		}
		
		public function fadIn():void{
			mc.gotoAndPlay(2);
		}
		
		public function destory():void{
			for each(var i:DisplayObject in _faceObj){
				if(i is Bitmap) (i as Bitmap).bitmapData.dispose();
			}
		}
		
		
	}
}