import React, { Component } from "react";
import {
  Platform,
  StyleSheet,
  Modal,
  Text,
  View,
  NetInfo,
  ProgressViewIOS
} from "react-native";

import CodePush from "react-native-code-push";
import * as Progress from "react-native-progress";

import AppWrapper from "./src/AppWrapper";
import JPushModule from "jpush-react-native";
import moment from "moment";
import { ALLOW_HOT_DATE } from "./src/Config";

const instructions = Platform.select({
  ios: "Press Cmd+R to reload,\n" + "Cmd+D or shake for dev menu",
  android:
    "Double tap R on your keyboard to reload,\n" +
    "Shake or press menu button for dev menu"
});

export default class EntryApp extends Component<{}> {
  constructor(props) {
    super(props);
    this.codePushInit();
    JPushModule.setupPush();
  }

  componentWillUnmount() {
    NetInfo.isConnected.removeEventListener(
      "connectionChange",
      this._handleIsConnectedChange
    );
  }

  render() {
    return (
      <View style={styles.container}>
        <AppWrapper />
        {this._modalView()}
      </View>
    );
  }

  codePushInit() {
    this.checkUpdate = this.checkUpdate.bind(this);
    this.state = {
      isShowUpdate: false,
      syncMessage: "正在检测更新",
      mmprogress: 0,
      indeterminate: true
    };

    this.checkUpdate();
    NetInfo.isConnected.addEventListener(
      "connectionChange",
      this._handleIsConnectedChange
    );
  }

  codePushStatusDidChange(syncStatus) {
    switch (syncStatus) {
      case CodePush.SyncStatus.CHECKING_FOR_UPDATE:
        this.setState({
          syncMessage: "正在检查新配置"
        });
        break;
      case CodePush.SyncStatus.DOWNLOADING_PACKAGE:
        if (!this.state.isShowUpdate) {
          this.setState({
            isShowUpdate: true
          });
        }
        break;
      case CodePush.SyncStatus.INSTALLING_UPDATE:
        break;
      case CodePush.SyncStatus.UP_TO_DATE:
        this.setState({
          syncMessage: "正在加载配置"
        });
        break;
      case CodePush.SyncStatus.UPDATE_INSTALLED:
        this.setState({
          syncMessage: "应用更新完成,重启中..."
        });
        break;
      case CodePush.SyncStatus.UNKNOWN_ERROR:
        this.setState({
          syncMessage: "应用更新出错,请检查设置!"
        });
        break;
    }
  }

  codePushDownloadDidProgress(progress) {
    this.setState({
      syncMessage: `正在下载新配置${(
        progress.receivedBytes /
        progress.totalBytes *
        100
      ).toFixed(2)}%`,
      mmprogress: Number(progress.receivedBytes / progress.totalBytes),
      indeterminate: false
    });
  }

  checkUpdate() {
    //热更时间推迟
    let currentData = moment().format("YYYY-MM-DD");
    if (currentData < ALLOW_HOT_DATE) {
      return ;
    } 
    
    CodePush.checkForUpdate()
      .then(update => {
        console.log("update", update);
        if (!update) {
          this.setState({ syncMessage: "当前是最新配置" });
        } else {
          CodePush.sync(
            { installMode: CodePush.InstallMode.IMMEDIATE },
            this.codePushStatusDidChange.bind(this),
            this.codePushDownloadDidProgress.bind(this)
          ).catch(e => {
            console.log(e);
          });
        }
      })
      .catch(err => {
        console.log(err);
      });
    CodePush.notifyAppReady();
  }

  codePushView() {
    return (
      <View style={styles.codepushContainer}>
        <Text style={styles.codepushWelcome}>欢迎您,请等待更新完成</Text>
        <Text style={styles.codePushText}>{this.state.syncMessage}</Text>
        <Progress.Bar
          style={styles.progressStyle}
          progress={this.state.mmprogress}
          indeterminate={this.state.indeterminate}
        />
      </View>
    );
  }

  _handleIsConnectedChange = isConnected => {
    if (isConnected) {
        this.checkUpdate();
    }
  };

  _modalView() {
    return (
      <Modal
        visible={this.state.isShowUpdate}
        animationType={"none"}
        transparent={true}
        onRequestClose={() => this._onHotUpdateClose()}
      >
        {this._isShowHotUpdateView()}
      </Modal>
    );
  }

  _isShowHotUpdateView() {
    return (
      <View style={styles.codepushContainer}>
        <Text style={styles.codepushWelcome}>欢迎您,请等待更新完成</Text>
        <Text style={styles.codePushText}>{this.state.syncMessage}</Text>
        <Progress.Bar
          style={styles.progressStyle}
          progress={this.state.mmprogress}
          indeterminate={this.state.indeterminate}
        />
      </View>
    );
  }
  _onHotUpdateClose() {}
}

const styles = StyleSheet.create({
  container: {
    flex: 1
  },

  codepushContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#F5FCFF"
  },
  codepushWelcome: {
    fontSize: 18,
    textAlign: "center",
    margin: 10
  },
  codePushText: {
    textAlign: "center",
    color: "#333333",
    marginBottom: 5
  },
  progressStyle: {
    margin: 5
  }
});
