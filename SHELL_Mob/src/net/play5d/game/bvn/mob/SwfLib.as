package net.play5d.game.bvn.mob {
import net.play5d.game.bvn.interfaces.ISwfLib;

public class SwfLib implements ISwfLib {

    public function SwfLib() {
    }

    [Embed(source='/../../shared/lib/swf/common_ui.swf')]
    private var _common_ui:Class;

    public function get common_ui():Class {
        return _common_ui;
    }

    [Embed(source='/../../shared/lib/swf/fight.swf')]
    private var _fight:Class;

    public function get fight():Class {
        return _fight;
    }

    [Embed(source='/../../shared/lib/swf/gameover.swf')]
    private var _gameover:Class;

    public function get gameover():Class {
        return _gameover;
    }

    [Embed(source='/../../shared/lib/swf/howtoplay.swf')]
    private var _howtoplay:Class;

    public function get howtoplay():Class {
        return _howtoplay;
    }

    [Embed(source='/../../shared/lib/swf/loading.swf')]
    private var _loading:Class;

    public function get loading():Class {
        return _loading;
    }

    [Embed(source='/../../shared/lib/swf/select.swf')]
    private var _select:Class;

    public function get select():Class {
        return _select;
    }

    [Embed(source='/../../shared/lib/swf/setting.swf')]
    private var _setting:Class;

    public function get setting():Class {
        return _setting;
    }

    [Embed(source='/../../shared/lib/swf/title.swf')]
    private var _title:Class;

    public function get title():Class {
        return _title;
    }

    [Embed(source='/../../shared/lib/swf/mosou.swf')]
    private var _mosou:Class;

    public function get musou():Class {
        return _mosou;
    }

    [Embed(source='/../../shared/lib/swf/bigmap.swf')]
    private var _bigMap:Class;

    public function get bigMap():Class {
        return _bigMap;
    }

    [Embed(source='/../../shared/lib/swf/dialog_ui.swf')]
    private var _dialog:Class;

    public function get dialog():Class {
        return _dialog;
    }

    [Embed(source='/../../shared/lib/swf/language.swf')]
    private var _language:Class;

    public function get language():Class {
        return _language;
    }

}
}
