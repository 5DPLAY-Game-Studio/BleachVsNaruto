package net.play5d.game.bvn.data.mosou
{
	public class MosouWaveRepeatVO
	{
		
		/**
		 * 类型：
		 * 0=按时间重复
		 * 1=当该节点中的敌人DEAD后，在等待时间之后进行重复 
		 */
		public var type:int;
		
		public var hold:int;
		
		public var wave:MosouWaveVO;
		
		/**
		 * 敌人数组 （{id: fighterID, amount: 数量, hp: 血量}）
		 */
		public var enemies:Vector.<MosouEnemyVO>;
		
		public var _holdFrame:int;
		
		public function MosouWaveRepeatVO()
		{
		}
		
		public function addEnemy(enemyAdds:Vector.<MosouEnemyVO>):void{
			enemies ||= new Vector.<MosouEnemyVO>();
			
			for each(var e:MosouEnemyVO in enemyAdds){
				e.wave = wave;
				e.repeat = this;
				enemies.push(e);
			}
			
		}
		
	}
}