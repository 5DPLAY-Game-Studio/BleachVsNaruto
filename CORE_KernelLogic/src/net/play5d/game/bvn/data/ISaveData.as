package net.play5d.game.bvn.data
{
	public interface ISaveData
	{
		function toSaveObj():Object;
		function readSaveObj(o:Object):void;
	}
}