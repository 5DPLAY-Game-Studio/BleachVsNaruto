package net.play5d.game.bvn.data
{
	import net.play5d.game.bvn.interfaces.BaseGameSprite;
	import net.play5d.game.bvn.interfaces.IGameSprite;

	public class TeamVO
	{
		public var id:int;
		public var name:String;
		public var children:Vector.<IGameSprite> = new Vector.<IGameSprite>();
		public function TeamVO(id:int , name:String = null)
		{
			this.id = id;
			this.name = name;
		}
		
		public function getAliveChildren():Vector.<IGameSprite>{
			var result:Vector.<IGameSprite> = new Vector.<IGameSprite>();
			for(var i:int ; i < children.length ; i++){
				var c:IGameSprite = children[i];
				if(c is BaseGameSprite){
					if((c as BaseGameSprite).isAlive) result.push(c);
				}else{
					result.push(c);
				}
			}
			return result;
		}
		
		public function addChild(v:IGameSprite):void{
			var index:int = children.indexOf(v);
			if(index == -1) children.push(v);
		}
		
		public function removeChild(v:IGameSprite):void{
			var index:int = children.indexOf(v);
			if(index != -1) children.splice(index , 1);
		}
		
	}
}