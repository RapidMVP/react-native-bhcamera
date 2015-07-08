'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});

var _reactNative = require('react-native');

var _reactNative2 = babelHelpers.interopRequireDefault(_reactNative);

var _merge = require('merge');

var _merge2 = babelHelpers.interopRequireDefault(_merge);

var BHCameraManager = _reactNative.NativeModules.BHCameraManager;

var BH_CAMERA_REF = 'bhcamera';

var BHCamera = (function (_React$Component) {
  function BHCamera(props) {
    var _this = this;

    babelHelpers.classCallCheck(this, BHCamera);

    babelHelpers.get(Object.getPrototypeOf(BHCamera.prototype), 'constructor', this).call(this, props);

    this.requestAuth = function (fn) {
      BHCamera.requestAuth(fn);
    };

    this.stopScanner = function () {
      BHCameraManager.stopScanning(_this._getBHCameraHandle());
    };

    this.startScanner = function () {
      BHCameraManager.startScanning(_this._getBHCameraHandle());
    };

    this.captureImage = function () {
      BHCameraManager.captureImage(_this._getBHCameraHandle());
    };

    this._handleEvents = function (e) {
      if (!_this.props['on' + e.type] || e.type === 'Barcode' && !_this.props.scanning) {
        return;
      }
      _this.props['on' + e.type](e.data);
    };
  }

  babelHelpers.inherits(BHCamera, _React$Component);
  babelHelpers.createClass(BHCamera, [{
    key: 'componentDidMount',
    value: function componentDidMount() {
      _reactNative.NativeAppEventEmitter.addListener('BHCameraEvent', this._handleEvents);
    }
  }, {
    key: 'componentDidUnmount',
    value: function componentDidUnmount() {
      _reactNative.NativeAppEventEmitter.removeListener('BHCameraEvent', this._handleEvents);
    }
  }, {
    key: '_getBHCameraHandle',
    value: function _getBHCameraHandle() {
      return _reactNative2['default'].findNodeHandle(this.refs[BH_CAMERA_REF]);
    }
  }, {
    key: 'render',
    value: function render() {
      var nativeProps = (0, _merge2['default'])(this.props, {
        scanning: true,
        aspect: 0,
        camera: 0,
        flash: 0,
        orientation: 0
      });

      return _reactNative2['default'].createElement(
        NativeBHCamera,
        babelHelpers._extends({ ref: BH_CAMERA_REF }, nativeProps),
        this.props.children
      );
    }
  }], [{
    key: 'propTypes',

    //static requestAuth = (fn) => {
    //  BHCameraManager.requestAuth((res) => {
    //    let cb = fn ? fn : () => {};
    //    let err = !res.success ? new Error(res.details) : null;
    //    cb(err, res);
    //  });
    //}

    value: {
      scanning: _reactNative2['default'].PropTypes.bool,
      aspect: _reactNative2['default'].PropTypes.oneOf(['fill', 'fit', 'stretch']),
      camera: _reactNative2['default'].PropTypes.oneOf(['front', 'back']),
      flash: _reactNative2['default'].PropTypes.oneOf(['on', 'off', 'auto']),
      torch: _reactNative2['default'].PropTypes.number,
      orientation: _reactNative2['default'].PropTypes.oneOf(['auto', 'landscapeLeft', 'landscapeRight', 'portrait', 'portraitUpsideDown']),
      onImageCapture: _reactNative2['default'].PropTypes.func,
      onBarcode: _reactNative2['default'].PropTypes.func
    },
    enumerable: true
  }, {
    key: 'defaultProps',
    value: {
      scanning: true,
      aspect: 'fill',
      camera: 'front',
      flash: 'off',
      orientation: 'auto'
    },
    enumerable: true
  }]);
  return BHCamera;
})(_reactNative2['default'].Component);

Object.keys(_reactNative.NativeMethodsMixin).forEach(function (key) {
  BHCamera.prototype[key] = _reactNative.NativeMethodsMixin[key];
});

var NativeBHCamera = (0, _reactNative.requireNativeComponent)('BHCamera', BHCamera);

exports['default'] = BHCamera;
module.exports = exports['default'];