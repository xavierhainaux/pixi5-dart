import 'observable_point.dart';
import 'matrix.dart';
import 'dart:math' as math;

/**
 * Transform that takes care about its versions
 *
 * @class
 * @memberof PIXI
 */
class Transform
{
  static final Transform identity = new Transform();
  /**
   * The global matrix transform. It can be swapped temporarily by some functions like getLocalBounds()
   *
   * @member {PIXI.Matrix}
   */
  final Matrix _worldTransform = new Matrix();

  /**
   * The local matrix transform
   *
   * @member {PIXI.Matrix}
   */
  final Matrix _localTransform = new Matrix();
  ObservablePoint _position, _scale, _pivot, _skew;
  num _rotation = 0;
  num _cx = 1; // cos rotation + skewY;
  num _sx = 0; // sin rotation + skewY;
  num _cy = 0; // cos rotation + Math.PI/2 - skewX;
  num _sy = 1; // sin rotation + Math.PI/2 - skewX;
  int _localID = 0, _currentLocalID = 0, _worldID = 0, _parentID= 0;

  /**
   *
   */
  Transform()
  {
    _position = new ObservablePoint(_onChange, 0, 0);
    _scale = new ObservablePoint(_onChange, 0, 0);
    _pivot = new ObservablePoint(_onChange, 0, 0);
    _skew = new ObservablePoint(_onChange, 0, 0);
  }

  ObservablePoint  get position => _position;
  ObservablePoint  get scale => _scale;
  ObservablePoint  get pivot => _pivot;
  ObservablePoint  get skew => _skew;


  /**
   * Called when a value changes.
   *
   * @private
   */
  void _onChange()
  {
    _localID++;
  }

  /**
   * Called when skew or rotation changes
   *
   * @private
   */
  void _updateSkew()
  {
    _cx = math.cos(_rotation + _skew.y);
    _sx = math.sin(_rotation + _skew.y);
    _cy = -math.sin(_rotation - _skew.x); // cos, added PI/2
    _sy = math.cos(_rotation - _skew.x); // sin, added PI/2

    _localID++;
  }

  /**
   * Updates only local matrix
   */
  void _updateLocalTransform()
  {
    final Matrix lt = _localTransform;

    if (_localID != _currentLocalID)
    {
      // get the matrix values of the displayobject based on its transform properties..
      lt.a = _cx * _scale.x;
      lt.b = _sx * _scale.x;
      lt.c = _cy * _scale.y;
      lt.d = _sy * _scale.y;

      lt.tx = _position.x - ((_pivot.x * lt.a) + (_pivot.y * lt.c));
      lt.ty = _position.y - ((_pivot.x * lt.b) + (_pivot.y * lt.d));
      _currentLocalID = _localID;

      // force an update..
      _parentID = -1;
    }
  }

  /**
   * Updates the values of the object and applies the parent's transform.
   *
   * @param {PIXI.Transform} parentTransform - The transform of the parent of this object
   */
  updateTransform(parentTransform)
  {
    const lt = this.localTransform;

    if (this._localID !== this._currentLocalID)
    {
      // get the matrix values of the displayobject based on its transform properties..
      lt.a = this._cx * this.scale._x;
      lt.b = this._sx * this.scale._x;
      lt.c = this._cy * this.scale._y;
      lt.d = this._sy * this.scale._y;

      lt.tx = this.position._x - ((this.pivot._x * lt.a) + (this.pivot._y * lt.c));
      lt.ty = this.position._y - ((this.pivot._x * lt.b) + (this.pivot._y * lt.d));
      this._currentLocalID = this._localID;

      // force an update..
      this._parentID = -1;
    }

    if (this._parentID !== parentTransform._worldID)
    {
      // concat the parent matrix with the objects transform.
      const pt = parentTransform.worldTransform;
      const wt = this.worldTransform;

      wt.a = (lt.a * pt.a) + (lt.b * pt.c);
      wt.b = (lt.a * pt.b) + (lt.b * pt.d);
      wt.c = (lt.c * pt.a) + (lt.d * pt.c);
      wt.d = (lt.c * pt.b) + (lt.d * pt.d);
      wt.tx = (lt.tx * pt.a) + (lt.ty * pt.c) + pt.tx;
      wt.ty = (lt.tx * pt.b) + (lt.ty * pt.d) + pt.ty;

      this._parentID = parentTransform._worldID;

      // update the id of the transform..
      this._worldID++;
    }
  }

  /**
   * Decomposes a matrix and sets the transforms properties based on it.
   *
   * @param {PIXI.Matrix} matrix - The matrix to decompose
   */
  setFromMatrix(matrix)
  {
    matrix.decompose(this);
    this._localID++;
  }

  /**
   * The rotation of the object in radians.
   *
   * @member {number}
   */
  get rotation()
  {
    return this._rotation;
  }

  set rotation(value) // eslint-disable-line require-jsdoc
  {
    this._rotation = value;
    this.updateSkew();
  }
}
