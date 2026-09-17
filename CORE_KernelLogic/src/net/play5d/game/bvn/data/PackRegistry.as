/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package net.play5d.game.bvn.data {
import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.debug.Debugger;

/**
 * 角色包注册：按 <code>packs.json</code> 加载各包 <code>meta.json</code>，并合并壳注入的外部包根。
 *
 * <p>外部包通过 <code>extraPackRootsProvider</code> 注入；同 id 时外部覆盖内置。</p>
 *
 * @example
 * <listing version="3.0">
 * PackRegistry.I.load(function ():void {
 *     // FighterModel / AssisterModel 已就绪
 * });
 * </listing>
 */
public class PackRegistry {

    private static var _i:PackRegistry;

    /**
     * 单例。
     */
    public static function get I():PackRegistry {
        _i ||= new PackRegistry();

        return _i;
    }

    /**
     * 壳注入：返回额外包描述数组。
     * 每项为 <code>{ kind: 'fighter'|'assist', id: String, root: String }</code>；
     * <code>root</code> 为相对 assets 的包根（以 <code>/</code> 结尾）。
     */
    public static var extraPackRootsProvider:Function;

    /** @private */
    private var _queue:Array;
    /** @private */
    private var _back:Function;
    /** @private */
    private var _fail:Function;

    /**
     * 加载内置 packs 与外部包，写入 FighterModel / AssisterModel。
     *
     * @param back 全部完成回调。
     * @param fail 清单本身加载失败时回调（单包失败仅跳过）。
     */
    public function load(back:Function, fail:Function = null):void {
        _back = back;
        _fail = fail;

        FighterModel.I.clear();
        AssisterModel.I.clear();

        AssetManager.I.loadJSON('config/packs.json', onPacksLoaded, onPacksFail);
    }

    /** @private */
    private function onPacksFail():void {
        Debugger.log('PackRegistry: load packs.json fail');
        if (_fail != null) {
            _fail();
        }
    }

    /** @private */
    private function onPacksLoaded(data:Object):void {
        _queue = [];

        appendBuiltin('fighter', (data['fighters'] as Array) || []);
        appendBuiltin('assist', (data['assists'] as Array) || []);
        appendExtras();

        loadNext();
    }

    /** @private */
    private function appendBuiltin(kind:String, ids:Array):void {
        var base:String = kind == 'assist' ? 'packs/assists/' : 'packs/fighters/';
        for each (var id:String in ids) {
            if (!id) {
                continue;
            }
            _queue.push({
                kind: kind,
                id  : id,
                root: base + id + '/'
            });
        }
    }

    /** @private */
    private function appendExtras():void {
        if (extraPackRootsProvider == null) {
            return;
        }

        var extras:Array = extraPackRootsProvider() as Array;
        if (!extras || extras.length < 1) {
            return;
        }

        for each (var item:Object in extras) {
            if (!item) {
                continue;
            }
            var kind:String = String(item['kind']);
            var id:String   = String(item['id']);
            var root:String = String(item['root'] || '');
            if (!id || !root) {
                continue;
            }
            if (root.charAt(root.length - 1) != '/') {
                root += '/';
            }
            _queue.push({
                kind: kind,
                id  : id,
                root: root
            });
        }
    }

    /** @private */
    private function loadNext():void {
        if (_queue.length < 1) {
            if (_back != null) {
                _back();
            }

            return;
        }

        var item:Object = _queue.shift();
        var kind:String = item['kind'];
        var id:String   = item['id'];
        var root:String = item['root'];
        var url:String  = root + 'meta.json';

        AssetManager.I.loadJSON(url, function (meta:Object):void {
            registerPack(kind, root, meta);
            loadNext();
        }, function ():void {
            Debugger.log('PackRegistry: skip pack', kind, id, root);
            loadNext();
        });
    }

    /** @private */
    private function registerPack(kind:String, root:String, meta:Object):void {
        if (!meta) {
            return;
        }

        var variants:Array = meta['variants'] as Array;
        if (!variants) {
            return;
        }

        var fileName:String = meta['file'] as String;
        var pathObj:Object  = {
            fighter: root,
            face   : root,
            bgm    : 'bgm/'
        };

        for each (var v:Object in variants) {
            if (!v) {
                continue;
            }
            var faces:Object = v['faces'] as Object;
            var urls:Object  = {};
            if (fileName) {
                urls['file'] = fileName;
            }
            if (faces) {
                if (faces['face']) {
                    urls['face'] = faces['face'];
                }
                if (faces['face_big']) {
                    urls['face_big'] = faces['face_big'];
                }
                if (faces['face_bar']) {
                    urls['face_bar'] = faces['face_bar'];
                }
                if (faces['face_win']) {
                    urls['face_win'] = faces['face_win'];
                }
            }

            var dataObj:Object = {
                id        : v['id'],
                name      : v['name'],
                comic_type: v['comic_type'],
                urls      : urls
            };
            if (v['start_frame'] != null) {
                dataObj['start_frame'] = v['start_frame'];
            }
            if (v['says']) {
                dataObj['says'] = v['says'];
            }
            if (v['bgm']) {
                dataObj['bgm'] = v['bgm'];
            }
            if (v['hasWarning']) {
                dataObj['hasWarning'] = v['hasWarning'];
            }

            var fv:FighterVO = new FighterVO();
            fv.initByObject({
                path: pathObj,
                data: dataObj
            });

            if (kind == 'assist') {
                AssisterModel.I.register(fv);
            }
            else {
                FighterModel.I.register(fv);
            }
        }
    }

}
}
