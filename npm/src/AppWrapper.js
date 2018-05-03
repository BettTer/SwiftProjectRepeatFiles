import 
{
    StyleSheet,
    WebView,
} from 'react-native'

import React from 'react'
const App = () =>{
    return (
        <WebView
          source={{uri: 'http://www.baidu.com'}}
          style={{marginTop: 20}}
        />
    );
}
export default App

const styles = StyleSheet.create({
    text:{
        marginTop: 100,
        alignSelf: 'center',
        fontSize: 50
    }
})