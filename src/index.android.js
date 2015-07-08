'use strict';

import React, {
  NativeAppEventEmitter,
  NativeModules,
  requireNativeComponent,
  NativeMethodsMixin,
} from 'react-native';

import merge from 'merge';

let { BHCameraManager } = NativeModules;
const BH_CAMERA_REF = 'bhcamera';

class BHCamera extends React.Component {

  //static requestAuth = (fn) => {
  //  BHCameraManager.requestAuth((res) => {
  //    let cb = fn ? fn : () => {};
  //    let err = !res.success ? new Error(res.details) : null;
  //    cb(err, res);
  //  });
  //}

  static propTypes = {
    scanning: React.PropTypes.bool,
    aspect: React.PropTypes.oneOf(['fill', 'fit', 'stretch']),
    camera: React.PropTypes.oneOf(['front', 'back']),
    flash: React.PropTypes.oneOf(['on', 'off', 'auto']),
    torch: React.PropTypes.number,
    orientation: React.PropTypes.oneOf(['auto', 'landscapeLeft', 'landscapeRight', 'portrait', 'portraitUpsideDown']),
    onImageCapture: React.PropTypes.func,
    onBarcode: React.PropTypes.func
  }

  static defaultProps = {
    scanning: true,
    aspect: 'fill',
    camera: 'front',
    flash: 'off',
    orientation: 'auto'
  }

  constructor(props) {
    super(props);
  }

  componentDidMount() {
    NativeAppEventEmitter.addListener('BHCameraEvent', this._handleEvents);
  }

  componentDidUnmount() {
    NativeAppEventEmitter.removeListener('BHCameraEvent', this._handleEvents);
  }

  _getBHCameraHandle() {
    return React.findNodeHandle(this.refs[BH_CAMERA_REF]);
  }

  requestAuth = (fn) => {
    BHCamera.requestAuth(fn);
  }

  stopScanner = () => {
    BHCameraManager.stopScanning(this._getBHCameraHandle());
  }

  startScanner = () => {
    BHCameraManager.startScanning(this._getBHCameraHandle());
  }

  captureImage = () => {
    BHCameraManager.captureImage(this._getBHCameraHandle());
  }

  _handleEvents = (e) => {
    if (!this.props[`on${e.type}`] || (e.type === 'Barcode' && !this.props.scanning)) {
      return;
    }
    this.props[`on${e.type}`](e.data);
  }

  render(){
    let nativeProps = merge(this.props, {
      scanning: true,
      aspect: 0,
      camera: 0,
      flash: 0,
      orientation: 0
    });

    return (
      <NativeBHCamera ref={BH_CAMERA_REF} {...nativeProps}>
        {this.props.children}
      </NativeBHCamera>
    );
  }
}

Object.keys(NativeMethodsMixin).forEach((key) => {
  BHCamera.prototype[key] = NativeMethodsMixin[key];
});

let NativeBHCamera = requireNativeComponent('BHCamera', BHCamera);

export default BHCamera;
