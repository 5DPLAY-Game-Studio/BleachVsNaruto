package net.play5d.game.bvn.mob.views {
import flash.display.Sprite;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.events.SetBtnEvent;
import net.play5d.game.bvn.mob.GameInterfaceManager;
import net.play5d.game.bvn.mob.RootSprite;
import net.play5d.game.bvn.mob.data.ScreenPadConfigVO;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.ui.SetBtnGroup;

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
                                     label      : 'PREINSTALL', cn: '预置位置',
                                     options    : [
                                         {label: 'TYPE 1', cn: '设定1', value: 0},
                                         {label: 'TYPE 2', cn: '设定2', value: 1},
                                     ],
                                     optoinKey  : 'joyMode',
                                     optionValue: config.joyMode
                                 },

                                 {
                                     label      : 'ALPHA', cn: '按钮透明度',
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
                                     label      : 'SP SKILL', cn: '必杀按键',
                                     options    : [
                                         {label: 'AUTO', cn: '自动显示/隐藏', value: true},
                                         {label: 'ALWAYS', cn: '总是显示', value: false}
                                     ],
                                     optoinKey  : 'superSkillAutoHide',
                                     optionValue: config.superSkillAutoHide
                                 },

                                 {
                                     label      : 'WANKAI', cn: '卍解按键',
                                     options    : [
                                         {label: 'AUTO', cn: '自动显示/隐藏', value: true},
                                         {label: 'ALWAYS', cn: '总是显示', value: false}
                                     ],
                                     optoinKey  : 'wankaiAutoHide',
                                     optionValue: config.wankaiAutoHide
                                 },

                                 {
                                     label      : 'SPECIAL', cn: '辅助/灵爆/替身术按键',
                                     options    : [
                                         {label: 'AUTO', cn: '自动显示/隐藏', value: true},
                                         {label: 'ALWAYS', cn: '总是显示', value: false}
                                     ],
                                     optoinKey  : 'specialAutoHide',
                                     optionValue: config.specialAutoHide
                                 },

                                 {label: 'CUSTOM', cn: '自定义'},
                                 {label: 'APPLY', cn: '确定'}
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
                _btnGroup.destory();
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
                GameUI.confrim('Custom already set, are you sure ?',
                               '自定义按钮已设定，改变此项将丢失自定义按钮设定，确定要改变？', function ():void {
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
