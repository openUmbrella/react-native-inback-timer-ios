import {
    NativeEventEmitter,
    NativeModules
} from 'react-native';
/**
 * InBackTimer对象只提供了
 * 属性：
 * 事件基本名 basicEventName  值是：backgroundTimerEvent
 * 支持最大时钟数量 maxTimerCount   值是：20
 * 注：能支持的事件名只有：backgroundTimerEvent(0 ... 19)
 * 
 * 方法:
 * timer(eventName, interval, count) 创建一个时钟
 * eventName: 时钟事件名
 * interval: 时间间隔，单位毫秒
 * count: 回调次数
 * 
 * 方法:   销毁一个时钟
 * clear(eventName)
 * eventName 事件名
 * 
 */
const { InBackTimer } = NativeModules;

const Emitter = new NativeEventEmitter(InBackTimer);

// 时钟池
let TimerPool = [];

/**
 * 对原生InBackTimer的封装类
 */
class BgTimer {
    /**
     * 倒计时
     */
    countdown(interval, count, fn, finalcb) {

        let timerId = this.timer(interval, count, fn, finalcb);
        // 立即回调一次
        fn && fn({ remain: count });
        return timerId;
    }
    /**
     * setInterval
     */
    setInterval(fn, interval) {

        return this.timer(interval, Number.MAX_SAFE_INTEGER, fn, null);
    }
    /**
     * setTimeout
     */
    setTimeout(fn, timeout) {

        return this.timer(timeout, 1, null, fn);
    }
    /**
     * 开启一个时钟
     * @param {number} interval 时间间隔 单位毫秒
     * @param {number} count 回调多少次
     * @param {func} fn 每次的回调
     * @param {func} finalcb 最终的回调
     */
    timer(interval, count, fn, finalcb) {
        // 时钟信息对象 用于存放时钟各种信息
        let timer = {};
        // 创建监听事件名
        timer.eventName = this.getEventName();
        // 将listener加入到时钟信息对象里面
        timer.listener = Emitter.addListener(timer.eventName, (data) => {
            // 回到过来参数，是{remain: <剩余次数>}
            if (data.remain > 0) {
                fn && fn(data);
            } else {
                fn && fn(data);
                finalcb && finalcb(data);
                // 移除时钟
                timer.listener.remove();
                // 将该时钟从时钟池剔除
                for (let i = 0; i < TimerPool.length; i++) {
                    let t = TimerPool[i];
                    if (t.eventName === timer.eventName) {
                        TimerPool.splice(i, 1);
                        break;
                    }
                }
            }
        });
        TimerPool.push(timer);
        InBackTimer.timer(timer.eventName, interval, count);

        // 返回事件名，后期通过事件名来 来做更多操作，比如提前终止时钟
        return timer.eventName;
    }
    /**
     * 销毁时钟
     * @param {string} eventName 时钟事件名
     */
    clear(eventName) {
        //调用原生方法
        InBackTimer.clear(eventName);
        //清除时钟池中的时钟信息对象
        for (let i = 0; i < TimerPool.length; i++) {
            let ti = TimerPool[i];
            if (ti.eventName === eventName) {
                ti.listener.remove();
                TimerPool.splice(i, 1);
                break;
            }
        }
    }

    /**
     * 获取时钟事件名
     */
    getEventName() {
        let basicEventName = InBackTimer.basicEventName;
        let basicEventNameLen = basicEventName.length;
        // 判断是否已经超过最大限制
        if (TimerPool.length >= InBackTimer.maxTimerCount) {
            throw new Error('InBackTimer时钟数量已经超过最大数量！');
        }
        if (TimerPool.length === 0) {
            return '' + basicEventName + '0';
        } else if (TimerPool.length === 1) {
            let num = parseInt(TimerPool[0].eventName.substr(basicEventNameLen));
            if (num > 0) {
                return '' + basicEventName + '0';
            } else {
                return '' + basicEventName + '1';
            }
        }

        TimerPool.sort((a, b) => {
            return parseInt(a.eventName.substr(basicEventNameLen)) - parseInt(b.eventName.substr(basicEventNameLen));
        });
        for (let i = 0; i < TimerPool.length; i++) {
            let num = parseInt(TimerPool[i].eventName.substr(basicEventNameLen));
            if (i === TimerPool.length - 1) {
                // 最后一个了
                return '' + basicEventName + (num + 1);
            }
            let nextnum = parseInt(TimerPool[i + 1].eventName.substr(basicEventNameLen));
            if (num > 0 && i == 0) {
                return '' + basicEventName + '0';
            } else {
                if (num + 1 === nextnum) {
                    continue;
                } else {
                    return '' + basicEventName + (num + 1);
                }
            }
        }

    }

}

export default new BgTimer();