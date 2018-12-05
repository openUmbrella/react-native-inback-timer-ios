### react-native-inback-timer-ios
the react native timer that can run in iOS app background state

### Install
```
npm install --save react-native-inback-timer-ios
```
### ScreenShoot
![screen-shoot](https://github.com/openUmbrella/react-native-inback-timer-ios/blob/master/example/images/screenshoot.gif?raw=true)

#### [如果你恰好再天朝,请点击这里](https://www.jianshu.com/p/9cc582cba9d4)

### Features
1. it's a timer can run in background state
2. support ios only
3. provide the same API with javascript (setTimeout, setInterval, clear) etc.

### Usage

1. you need link library react-native-inback-timer-ios (don't know linking ? [scan here first](https://facebook.github.io/react-native/docs/linking-libraries-ios))
2. import react-native-inback-timer-ios in your container
```
import BGTimer from 'react-native-inback-timer-ios';
```

3. start your timer

```
let timerID = BGTimer.setInterval(() => {
    // do something..
    });
}, 1000);
                    
// ...
BGTimer.clear(timerID);
```
or

```

let timerID = BGTimer.setTimeout((data) => {
    // time out!
}, 9000);

```
