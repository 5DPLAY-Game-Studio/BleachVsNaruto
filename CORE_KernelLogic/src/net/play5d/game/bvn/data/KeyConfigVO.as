package net.play5d.game.bvn.data
{
	import net.play5d.kyo.utils.KyoUtils;

	public class KeyConfigVO
	{
		public var id:int;
		
		public var up:uint;
		public var down:uint;
		public var left:uint;
		public var right:uint;
		
		public var attack:uint;
		public var jump:uint;
		public var dash:uint;
		
		public var skill:uint;
		public var superKill:uint; //必杀
		public var beckons:uint; //召唤
		
		public var selects:Array;
		
		public function KeyConfigVO(id:int)
		{
			this.id = id;
		}
		
		public function setKeys(up:uint,down:uint,left:uint,right:uint,attack:uint,jump:uint,dash:uint,skill:uint,superKill:uint,beckons:uint):void{
			this.up = up;
			this.down = down;
			this.left = left;
			this.right = right;
			this.attack = attack;
			this.jump = jump;
			this.dash = dash;
			this.skill = skill;
			this.dash = dash;
			this.superKill = superKill;
			this.beckons = beckons;
			
			selects ||= [attack];
		}
		
//		public function getSelectKeyCode():Array{
//			return selects;
//		}
		
//		public function isSelectKey(code:int):Boolean{
//			return selects.indexOf(code) != -1;
//		}
		
		public function toSaveObj():Object{
			var o:Object = KyoUtils.itemToObject(this);
			delete o['id'];
			return o;
		}
		
		public function readSaveObj(o:Object):void{
			KyoUtils.setValueByObject(this,o);
		}
		
		public function clone():KeyConfigVO{
			var o:Object = toSaveObj();
			var newKey:KeyConfigVO = new KeyConfigVO(id);
			newKey.readSaveObj(o);
			return newKey;
		}
		
	}
}