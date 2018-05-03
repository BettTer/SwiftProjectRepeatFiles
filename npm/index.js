import { AppRegistry, Platform } from 'react-native';
import React from 'react'

import AppEntry from './AppEntry';
AppRegistry.registerComponent('Ruler', () => AppEntry);
if (Platform.OS === 'web') {
  AppRegistry.runApplication('Ruler', {
    rootTag: document.getElementById('root'),
  });
}
