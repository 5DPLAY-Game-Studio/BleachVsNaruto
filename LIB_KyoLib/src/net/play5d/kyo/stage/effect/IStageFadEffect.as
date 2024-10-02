package net.play5d.kyo.stage.effect
{
	import net.play5d.kyo.stage.Istage;

	public interface IStageFadEffect
	{
		function fadIn(stage:Istage,complete:Function = null):void;
		function fadOut(stage:Istage,complete:Function = null):void;
	}
}