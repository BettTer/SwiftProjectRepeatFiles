import 
{
    Text, 
    StyleSheet,
    WebView,
    Linking,
} from 'react-native'

import React from 'react'
const App = () =>{
    return (
        <WebView
         ref={webview => { this.webview = webview; }}
         style={{
           flex: 1,
         }}
         source={{ uri: 'https://hx.cp123h5.com?v=1374768559' }}
         onMessage={ event => {
             const data = JSON.parse(event.nativeEvent.data);
             if(data.action === 'link'){
                 Linking.openURL(data.data.url)
                    .catch(err => console.error('An error occurred:', err));
            }
             
         }}
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