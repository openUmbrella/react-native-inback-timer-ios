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

import BGTimer from 'react-native-inback-timer-ios';

export default class Demos extends Component {

    // 构造函数
    constructor (props){
        super(props);
        this.state={
        };
        this.timerID = null;
    }
    
    // 渲染组件
    render () {
        return (
            <View style={styles.container}>
                <TouchableOpacity style={{ height: 30, backgroundColor: 'orange', marginTop: 20}} onPress={()=>{
                    
                    if(this.timerID == null){
                        this.timerID = BGTimer.countdown(1000, 22, (data) => {
                            this.setState({
                                timerA: data.remain
                            });
                        });
                    }else{
                        BGTimer.clear(this.timerID);
                        this.timerID = null;
                    }
                    
                }}>
                    <Text style={{}}>countdown timerA: {this.state.timerA}</Text>
                </TouchableOpacity>
                <TouchableOpacity style={{ height: 30, backgroundColor: 'orange', marginTop: 20}} onPress={()=>{
                    BGTimer.countdown(1000,10,(data) =>{
                        this.setState({
                            timerB: data.remain
                        });
                    });
                }}>
                    <Text style={{}}>countdown timerB: {this.state.timerB}</Text>
                </TouchableOpacity>
                <TouchableOpacity style={{height: 30, backgroundColor: 'orange', marginTop: 20}} onPress={()=>{
                    BGTimer.setInterval(()=>{
                        console.log('setInterval');
                        this.setState({
                            timerC: this.state.timerC ?  null : 'didi',
                        });
                    },1000);
                }}>
                    <Text style={{}}> setInterval: {this.state.timerC}</Text>
                </TouchableOpacity>
                <TouchableOpacity style={{ height: 30, backgroundColor: 'orange', marginTop: 20}} onPress={()=>{
                    let timerID = BGTimer.setTimeout((data)=>{
                        this.setState({
                            timerD: 'lalala, timeout!',
                        });
                    },9000);
                }}>
                    <Text style={{}}> setTimeout: {this.state.timerD}</Text>
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
