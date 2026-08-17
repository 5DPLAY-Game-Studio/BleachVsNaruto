package net.play5d.game.bvn.mob.views {
import flash.display.Sprite;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.events.SetBtnEvent;
import net.play5d.game.bvn.mob.GameInterfaceManager;
import net.play5d.game.bvn.mob.RootSprite;
import net.play5d.game.bvn.mob.data.ScreenPadConfigVO;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.ui.settings.SetBtnGroup;

public class SetScreenBtnView extends Sprite {

    public function SetScreenBtnView() {
        super();

        this.graphics.beginFill(0, 0.8);
        this.graphics.drawRect(0, 0, GameConfig.GAME_SIZE.x, GameConfig.GAME_SIZE.y);
        this.graphics.endFill();

        _btnGroup        = new SetBtnGroup();
        _btnGroup.startY = 30;
        _btnGroup.endY   = 550;
        _btnGroup.gap    = 70;

        var config:ScreenPadConfigVO = GameInterfaceManager.config.screenPadConfig;

        _btnGroup.setBtnData([

                                 {
                                     label      : 'PREINSTALL', cn: GetLang('txt.set_screen_btn_view.preinstall'),
                                     options    : [
                                         {label: 'TYPE 1', cn: GetLang('txt.set_screen_btn_view.type_1'), value: 0},
                                         {label: 'TYPE 2', cn: GetLang('txt.set_screen_btn_view.type_2'), value: 1},
                                     ],
                                     optoinKey  : 'joyMode',
                                     optionValue: config.joyMode
                                 },

                                 {
                                     label      : 'ALPHA', cn: GetLang('txt.set_screen_btn_view.alpha'),
                                     options    : [
                                         {label: '10%', cn: '10%', value: 0.1},
                                         {label: '30%', cn: '30%', value: 0.3},
                                         {label: '50%', cn: '50%', value: 0.5},
                                         {label: '70%', cn: '70%', value: 0.7},
                                         {label: '100%', cn: '100%', value: 1}
                                     ],
                                     optoinKey  : 'joyAlpha',
                                     optionValue: config.joyAlpha
                                 },

                                 {
                                     label      : 'SP SKILL', cn: GetLang('txt.set_screen_btn_view.sp_skill'),
                                     options    : [
                                         {label: 'AUTO', cn: GetLang('txt.set_screen_btn_view.auto_show'), value: true},
                                         {label: 'ALWAYS', cn: GetLang('txt.set_screen_btn_view.always_show'), value: false}
                                     ],
                                     optoinKey  : 'superSkillAutoHide',
                                     optionValue: config.superSkillAutoHide
                                 },

                                 {
                                     label      : 'WANKAI', cn: GetLang('txt.set_screen_btn_view.wankai'),
                                     options    : [
                                         {label: 'AUTO', cn: GetLang('txt.set_screen_btn_view.auto_show'), value: true},
                                         {label: 'ALWAYS', cn: GetLang('txt.set_screen_btn_view.always_show'), value: false}
                                     ],
                                     optoinKey  : 'wankaiAutoHide',
                                     optionValue: config.wankaiAutoHide
                                 },

                                 {
                                     label      : 'SPECIAL', cn: GetLang('txt.set_screen_btn_view.special'),
                                     options    : [
                                         {label: 'AUTO', cn: GetLang('txt.set_screen_btn_view.auto_show'), value: true},
                                         {label: 'ALWAYS', cn: GetLang('txt.set_screen_btn_view.always_show'), value: false}
                                     ],
                                     optoinKey  : 'specialAutoHide',
                                     optionValue: config.specialAutoHide
                                 },

                                 {label: 'CUSTOM', cn: GetLang('txt.set_screen_btn_view.custom')},
                                 {label: 'APPLY', cn: GetLang('txt.set_screen_btn_view.apply')}
                             ]);
        _btnGroup.initScroll(RootSprite.FULL_SCREEN_SIZE.x, RootSprite.FULL_SCREEN_SIZE.y);
        _btnGroup.addEventListener(SetBtnEvent.SELECT, onBtnSelect);
        _btnGroup.addEventListener(SetBtnEvent.OPTION_CHANGE, onOptionChange);

        this.addChild(_btnGroup);


    }
    private var _btnGroup:SetBtnGroup;

    private function closeSelf():void {

        if (_btnGroup) {
            try {
                _btnGroup.destroy();
                this.removeChild(_btnGroup);
                _btnGroup = null;
            }
            catch (e:Error) {
                trace(e);
            }

        }

        try {
            this.parent.removeChild(this);
        }
        catch (e:Error) {
            trace(e);
        }

    }

    private function onBtnSelect(e:SetBtnEvent):void {
        switch (e.selectedLabel) {
        case 'CUSTOM':
            var csb:CustomScreenBtnView = new CustomScreenBtnView();
            RootSprite.I.addChild(csb.getDisplay());
            break;
        case 'APPLY':
            closeSelf();
            break;
        }
    }

    private function onOptionChange(e:SetBtnEvent):void {
        if (e.optionKey == 'joyMode') {
            if (GameInterfaceManager.config.screenPadConfig.joySet) {
                GameUI.confrim(
                        GetLang('confirm.set_screen_btn_view.lose_custom_title'),
                        GetLang('confirm.set_screen_btn_view.lose_custom'),
                        function ():void {
                            GameInterfaceManager.config.screenPadConfig.joySet = null;
                            var config:ScreenPadConfigVO                       = GameInterfaceManager.config.screenPadConfig;
                            config.setValueByKey(e.optionKey, e.optionValue);
                        }
                );
                return;
            }
        }
        var config:ScreenPadConfigVO = GameInterfaceManager.config.screenPadConfig;
        config.setValueByKey(e.optionKey, e.optionValue);
    }

}
}
