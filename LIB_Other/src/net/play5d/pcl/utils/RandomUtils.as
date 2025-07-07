/*
 * Copyright (C) 2021-2025, 5DPLAY Game Studio
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

package net.play5d.pcl.utils {
import flash.utils.getTimer;

/**
 * 随机数生成 工具类，可通过指定种子获取指定的随机数列
 * <br/>
 * 摘自 https://blog.csdn.net/aisajiajiao/article/details/7795621
 */
public class RandomUtils {

    // 最大比率
    private const MAX_RATIO:Number = 1 / uint.MAX_VALUE;

    // 种子
    private var _seed:uint = 0;
    private var _r:uint;

    // 当前实例
    private static var _instance:RandomUtils;
    public static function get I():RandomUtils {
        _instance ||= new RandomUtils();

        return _instance;
    }

    /**
     * 设置随机数种子
     * @param seed 随机数种子
     */
    public function setSeed(seed:uint):void {
        seed ||= getTimer();
        _r = _seed = seed;
    }

    /**
     * 获得随机数种子
     * @return 当前随机数种子
     */
    public function getSeed():uint {
        return _seed;
    }

    /**
     * 产生下一个随机数
     * @return 下一个随机数
     */
    public function getNext():Number {
        _r ^= (_r << 21);
        _r ^= (_r >>> 35);
        _r ^= (_r << 4);

        return (_r * MAX_RATIO);
    }
}
}
