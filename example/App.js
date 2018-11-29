/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

/**
 * 组件描述
 * 
*/

import React, { Component } from 'react';
import {
    StyleSheet,
    TouchableOpacity,
    View,
    Text,
    Image
} from 'react-native';

import bgTimer from 'react-native-inback-timer-ios';

export default class Demos extends Component {

    // 构造函数
    constructor (props){
        super(props);
        this.state={
        };
        this.timerID = null;

        setInterval(()=>{
            console.log('我运行了');
        }, 1000);
    }
    
    // 渲染组件
    render () {
        return (
            <View style={styles.container}>
                <TouchableOpacity style={{ height: 30, backgroundColor: 'orange', marginTop: 20}} onPress={()=>{
                    
                    if(this.timerID == null){
                        this.timerID = bgTimer.countdown(1000, 22, (data) => {
                            console.log('啦啦啦:', data.remain);
                            this.setState({
                                timerA: data.remain
                            });
                        });
                    }else{
                        bgTimer.clear(this.timerID);
                        this.timerID = null;
                    }
                    
                }}>
                    <Text style={{}}>倒计时 时钟A: {this.state.timerA}</Text>
                </TouchableOpacity>
                <TouchableOpacity style={{ height: 30, backgroundColor: 'orange', marginTop: 20}} onPress={()=>{
                    bgTimer.countdown(1000,10,(data) =>{
                        this.setState({
                            timerB: data.remain
                        });
                    });
                }}>
                    <Text style={{}}>倒计时 时钟B: {this.state.timerB}</Text>
                </TouchableOpacity>
                <TouchableOpacity style={{height: 30, backgroundColor: 'orange', marginTop: 20}} onPress={()=>{
                    bgTimer.setInterval(()=>{
                        console.log('setInterval 滴滴');
                        this.setState({
                            timerC: '滴滴'
                        });
                    },1000);
                }}>
                    <Text style={{}}> setInterval 时钟C: {this.state.timerC}</Text>
                </TouchableOpacity>
                <TouchableOpacity style={{ height: 30, backgroundColor: 'orange', marginTop: 20}} onPress={()=>{
                    bgTimer.setTimeout((data)=>{
                        this.setState({
                            timerD: '时间到啦！',
                        });
                    },2000);
                }}>
                    <Text style={{}}> setTimeout 时钟D: {this.state.timerD}</Text>
                </TouchableOpacity>
                
                <TouchableOpacity style={{ height: 30, backgroundColor: 'orange', marginTop: 20}} onPress={()=>{
                    bgTimer.countdown(1000,4, (data) =>{
                        this.setState({
                            timerE: data.remain
                        });
                    });
                }}>
                    <Text style={{}}>时钟E: {this.state.timerE}</Text>
                </TouchableOpacity>
                
            </View>
        );
    }

}


// 样式
const styles = StyleSheet.create({
    container:{
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center'
        
    }
    
    
});
