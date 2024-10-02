package net.play5d.game.bvn.data.mosou.utils
{
	import net.play5d.game.bvn.data.FighterModel;
	import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;

	public class MosouFighterFactory
	{
		public function MosouFighterFactory()
		{
		}
		
		public static function create(id:String):MosouFighterVO{
			var mv:MosouFighterVO = new MosouFighterVO();
			mv.id = id;
			return mv;
		}
		
	}
}