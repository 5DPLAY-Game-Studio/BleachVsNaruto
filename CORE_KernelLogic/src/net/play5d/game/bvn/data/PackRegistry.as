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
import net.play5d.game.bvn.data.vos.MapVO;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.utils.PackLangUtil;

/**
 * 角色/地图包注册：按 <code>packs.json</code> 加载各包 <code>meta.json</code>，并合并壳注入的外部包根。
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
        MapModel.I.clear();

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
        appendBuiltin('map', (data['maps'] as Array) || []);
        appendExtras();

        loadNext();
    }

    /** @private */
    private function appendBuiltin(kind:String, ids:Array):void {
        var base:String;
        if (kind == 'assist') {
            base = 'packs/assists/';
        }
        else if (kind == 'map') {
            base = 'packs/maps/';
        }
        else {
            base = 'packs/fighters/';
        }
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

        if (kind == 'map') {
            registerMapPack(root, meta);
            return;
        }

        var variants:Array = meta['variants'] as Array;
        if (!variants) {
            return;
        }

        var fileName:String = meta['file'] as String;
        var faceBase:String = 'face/';
        if (meta['path'] && meta['path']['face']) {
            faceBase = String(meta['path']['face']);
        }

        var pathObj:Object = {
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
                    urls['face'] = resolvePackRel(String(faces['face']), faceBase);
                }
                if (faces['face_big']) {
                    urls['face_big'] = resolvePackRel(String(faces['face_big']), faceBase);
                }
                if (faces['face_bar']) {
                    urls['face_bar'] = resolvePackRel(String(faces['face_bar']), faceBase);
                }
                if (faces['face_win']) {
                    urls['face_win'] = resolvePackRel(String(faces['face_win']), faceBase);
                }
            }

            var variantId:String = v['id'] != null ? String(v['id']) : null;
            // language.{locale}.name/says[id] → 兼容旧形态
            var localePack:Object = PackLangUtil.pickLocalePack(meta['language'] as Object);
            var nameRaw:*         = lookupRootI18n(localePack ? localePack['name'] : null, variantId);
            if (nameRaw == null) {
                nameRaw = lookupRootI18n(meta['name'], variantId);
            }
            if (nameRaw == null) {
                nameRaw = v['name'];
            }
            var saysRaw:* = lookupRootI18n(localePack ? localePack['says'] : null, variantId);
            if (saysRaw == null) {
                saysRaw = lookupRootI18n(meta['says'], variantId);
            }
            if (saysRaw == null) {
                saysRaw = v['says'];
            }

            var dataObj:Object = {
                id        : variantId,
                name      : PackLangUtil.resolveString(nameRaw, variantId),
                comic_type: v['comic_type'],
                urls      : urls
            };
            if (v['start_frame'] != null) {
                dataObj['start_frame'] = v['start_frame'];
            }
            var says:Array = PackLangUtil.resolveStringArray(saysRaw);
            if (says) {
                dataObj['says'] = says;
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

    /** @private */
    private function registerMapPack(root:String, meta:Object):void {
        var pathObj:Object = {
            map: root,
            bgm: 'bgm/'
        };

        var mapId:String      = meta['id'] || meta['pack'];
        var localePack:Object = PackLangUtil.pickLocalePack(meta['language'] as Object);
        var nameRaw:*         = localePack ? localePack['name'] : null;
        if (nameRaw == null) {
            nameRaw = meta['name'];
        }
        var obj:Object = {
            path: pathObj,
            id  : mapId,
            name: PackLangUtil.resolveString(nameRaw, mapId != null ? String(mapId) : null)
        };
        if (meta['file']) {
            obj['file'] = meta['file'];
        }
        else {
            obj['file'] = '';
        }
        if (meta['img']) {
            obj['img'] = meta['img'];
        }
        if (meta['bgm']) {
            obj['bgm'] = meta['bgm'];
        }

        var mv:MapVO = new MapVO();
        mv.initByObject(obj);
        MapModel.I.register(mv);
    }

    /**
     * 包内相对路径：裸文件名拼 <code>faceBase</code>；已含 <code>/</code> 则原样使用。
     *
     * @param rel      faces 字段值。
     * @param faceBase 如 <code>face/</code>。
     * @return 相对包根路径。
     */
    private function resolvePackRel(rel:String, faceBase:String):String {
        if (!rel) {
            return rel;
        }
        if (rel.indexOf('/') >= 0) {
            return rel;
        }

        return faceBase + rel;
    }

    /**
     * @private 从根节点 <code>name</code>/<code>says</code> 按 variant id 取值
     */
    private static function lookupRootI18n(rootMap:Object, variantId:String):* {
        if (!rootMap || !variantId) {
            return null;
        }
        if (rootMap is Array || rootMap is String) {
            return null;
        }

        return rootMap[variantId];
    }

}
}
