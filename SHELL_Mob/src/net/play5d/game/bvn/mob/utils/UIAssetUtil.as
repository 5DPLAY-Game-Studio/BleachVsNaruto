package net.play5d.game.bvn.mob.utils {
import net.play5d.game.bvn.utils.EmbedSwfAssetUtil;

/**
 * 移动壳 UI Embed 资源（<code>mob_ui.swf</code>）。
 *
 * @see EmbedSwfAssetUtil
 */
public class UIAssetUtil extends EmbedSwfAssetUtil {

    private static var _i:UIAssetUtil;

    public static function get I():UIAssetUtil {
        _i ||= new UIAssetUtil();
        return _i;
    }


    [Embed(source='/../../shared/lib/swf/mob_ui.swf')]
    public var win_ui:Class;

    override protected function getUiClass():Class {
        return win_ui;
    }

}
}
