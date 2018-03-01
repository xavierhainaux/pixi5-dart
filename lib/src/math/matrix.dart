import 'dart:typed_data';

import 'point.dart';
import 'dart:math' as math;

/**
 * The PixiJS Matrix class as an object, which makes it a lot faster,
 * here is a representation of it :
 * | a | c | tx|
 * | b | d | ty|
 * | 0 | 0 | 1 |
 *
 * @class
 * @memberof PIXI
 */
class Matrix
{
  double _a, _b, _c, _d, _tx, _ty;

  /**
   * @param {number} [a=1] - x scale
   * @param {number} [b=0] - x skew
   * @param {number} [c=0] - y skew
   * @param {number} [d=1] - y scale
   * @param {number} [tx=0] - x translation
   * @param {number} [ty=0] - y translation
   */
  Matrix([this._a = 1.0, this._b = 0.0, this._c = 0.0, this._d = 1.0, this._tx = 0.0, this._ty = 0.0]);

  /**
   * Creates a Matrix object based on the given array. The Element to Matrix mapping order is as follows:
   *
   * a = array[0]
   * b = array[1]
   * c = array[3]
   * d = array[4]
   * tx = array[2]
   * ty = array[5]
   *
   * @param {number[]} array - The array that the matrix will be populated from.
   */
  factory Matrix.fromArray(List<double> array)
  {
    return new Matrix(array[0],array[1],array[3],array[4],array[2],array[5]);
  }

  /**
   * sets the matrix properties
   *
   * @param {number} a - Matrix component
   * @param {number} b - Matrix component
   * @param {number} c - Matrix component
   * @param {number} d - Matrix component
   * @param {number} tx - Matrix component
   * @param {number} ty - Matrix component
   *
   */
  void set(num a, num b, num c, num d, num tx, num ty)
  {
    _a = a;
    _b = b;
    _c = c;
    _d = d;
    _tx = tx;
    _ty = ty;
  }

  /**
   * Creates an array from the current Matrix object.
   *
   * @param {boolean} transpose - Whether we need to transpose the matrix or not
   * @param {Float32Array} [out=new Float32Array(9)] - If provided the array will be assigned to out
   * @return {number[]} the newly created array which contains the matrix
   */
  List<double> toArray({bool transpose: false, Float32List result})
  {
    result ??= new Float32List(9);

    if (transpose)
    {
      result[0] = _a;
      result[1] = _b;
      result[2] = 0.0;
      result[3] = _c;
      result[4] = _d;
      result[5] = 0.0;
      result[6] = _tx;
      result[7] = _ty;
      result[8] = 1.0;
    }
    else
    {
      result[0] = _a;
      result[1] = _c;
      result[2] = _tx;
      result[3] = _b;
      result[4] = _d;
      result[5] = _ty;
      result[6] = 0.0;
      result[7] = 0.0;
      result[8] = 1.0;
    }

    return result;
  }

  double get a => _a;
  double get b => _b;
  double get c => _c;
  double get d => _d;
  double get tx => _tx;
  double get ty => _ty;

  /**
   * Get a new position with the current transformation applied.
   * Can be used to go from a child's coordinate space to the world coordinate space. (e.g. rendering)
   *
   * @param {PIXI.Point} pos - The origin
   * @param {PIXI.Point} [newPos] - The point that the new position is assigned to (allowed to be same as input)
   * @return {PIXI.Point} The new point, transformed through this matrix
   */
  Point apply(Point pos, {Point result})
  {
    result ??= new Point();

    final double x = pos.x.toDouble();
    final double y = pos.y.toDouble();
    result.set((_a * x) + (_c * y) + _tx, (_b * x) + (_d * y) + _ty);

    return result;
  }

  /**
   * Get a new position with the inverse of the current transformation applied.
   * Can be used to go from the world coordinate space to a child's coordinate space. (e.g. input)
   *
   * @param {PIXI.Point} pos - The origin
   * @param {PIXI.Point} [newPos] - The point that the new position is assigned to (allowed to be same as input)
   * @return {PIXI.Point} The new point, inverse-transformed through this matrix
   */
  Point applyInverse(Point pos, {Point result})
  {
    result ??= new Point();

    final double id = 1.0 / ((_a * _d) + (_c * -_b));

    final double x = pos.x.toDouble();
    final double y = pos.y.toDouble();

    result.set((_d * id * x) + (-_c * id * y) + (((_ty * _c) - (_tx * _d)) * id),
    (_a * id * y) + (-_b * id * x) + (((-_ty * _a) + (_tx * _b)) * id));

    return result;
  }

  /**
   * Translates the matrix on the x and y.
   *
   * @param {number} x How much to translate x by
   * @param {number} y How much to translate y by
   * @return {PIXI.Matrix} This matrix. Good for chaining method calls.
   */
  void translate(num x, num y)
  {
    _tx += x;
    _ty += y;
  }

  /**
   * Applies a scale transformation to the matrix.
   *
   * @param {number} x The amount to scale horizontally
   * @param {number} y The amount to scale vertically
   * @return {PIXI.Matrix} This matrix. Good for chaining method calls.
   */
  void scale(num x, num y)
  {
    _a *= x;
    _d *= y;
    _c *= x;
    _b *= y;
    _tx *= x;
    _ty *= y;
  }

  /**
   * Applies a rotation transformation to the matrix.
   *
   * @param {number} angle - The angle in radians.
   * @return {PIXI.Matrix} This matrix. Good for chaining method calls.
   */
  void rotate(num angle)
  {
    num cos = math.cos(angle);
    num sin = math.sin(angle);

    final double a1 = _a;
    final double c1 = _c;
    final double tx1 = _tx;

    _a = (a1 * cos) - (_b * sin);
    _b = (a1 * sin) + (_b * cos);
    _c = (c1 * cos) - (_d * sin);
    _d = (c1 * sin) + (_d * cos);
    _tx = (tx1 * cos) - (_ty * sin);
    _ty = (tx1 * sin) + (_ty * cos);
  }

  /**
   * Appends the given Matrix to this Matrix.
   *
   * @param {PIXI.Matrix} matrix - The matrix to append.
   * @return {PIXI.Matrix} This matrix. Good for chaining method calls.
   */
  void append(Matrix matrix)
  {
    final double a1 = _a;
    final double b1 = _b;
    final double c1 = _c;
    final double d1 = _d;

    _a = (matrix.a * a1) + (matrix.b * c1);
    _b = (matrix.a * b1) + (matrix.b * d1);
    _c = (matrix.c * a1) + (matrix.d * c1);
    _d = (matrix.c * b1) + (matrix.d * d1);

    _tx = (matrix.tx * a1) + (matrix.ty * c1) + _tx;
    _ty = (matrix.tx * b1) + (matrix.ty * d1) + _ty;
  }

  /**
   * Sets the matrix based on all the available properties
   *
   * @param {number} x - Position on the x axis
   * @param {number} y - Position on the y axis
   * @param {number} pivotX - Pivot on the x axis
   * @param {number} pivotY - Pivot on the y axis
   * @param {number} scaleX - Scale on the x axis
   * @param {number} scaleY - Scale on the y axis
   * @param {number} rotation - Rotation in radians
   * @param {number} skewX - Skew on the x axis
   * @param {number} skewY - Skew on the y axis
   * @return {PIXI.Matrix} This matrix. Good for chaining method calls.
   */
  void setTransform(double x, double y, double pivotX, double pivotY, double scaleX, double scaleY, double rotation, double skewX, double skewY)
  {
    _a = math.cos(rotation + skewY) * scaleX;
    _b = math.sin(rotation + skewY) * scaleX;
    _c = -math.sin(rotation - skewX) * scaleY;
    _d = math.cos(rotation - skewX) * scaleY;

    _tx = x - ((pivotX * _a) + (pivotY * _c));
    _ty = y - ((pivotX * _b) + (pivotY * _d));
  }

  /**
   * Prepends the given Matrix to this Matrix.
   *
   * @param {PIXI.Matrix} matrix - The matrix to prepend
   * @return {PIXI.Matrix} This matrix. Good for chaining method calls.
   */
  prepend(matrix)
  {
    const tx1 = this.tx;

    if (matrix.a !== 1 || matrix.b !== 0 || matrix.c !== 0 || matrix.d !== 1)
    {
      const a1 = this.a;
      const c1 = this.c;

      this.a = (a1 * matrix.a) + (this.b * matrix.c);
      this.b = (a1 * matrix.b) + (this.b * matrix.d);
      this.c = (c1 * matrix.a) + (this.d * matrix.c);
      this.d = (c1 * matrix.b) + (this.d * matrix.d);
    }

    this.tx = (tx1 * matrix.a) + (this.ty * matrix.c) + matrix.tx;
    this.ty = (tx1 * matrix.b) + (this.ty * matrix.d) + matrix.ty;
  }

  /**
   * Decomposes the matrix (x, y, scaleX, scaleY, and rotation) and sets the properties on to a transform.
   *
   * @param {PIXI.Transform} transform - The transform to apply the properties to.
   * @return {PIXI.Transform} The transform with the newly applied properties
   */
  decompose(transform)
  {
    // sort out rotation / skew..
    const a = this.a;
    const b = this.b;
    const c = this.c;
    const d = this.d;

    const skewX = -Math.atan2(-c, d);
    const skewY = Math.atan2(b, a);

    const delta = Math.abs(skewX + skewY);

    if (delta < 0.00001 || Math.abs(PI_2 - delta) < 0.00001)
    {
      transform.rotation = skewY;

      if (a < 0 && d >= 0)
      {
        transform.rotation += (transform.rotation <= 0) ? Math.PI : -Math.PI;
      }

      transform.skew.x = transform.skew.y = 0;
    }
    else
    {
      transform.rotation = 0;
      transform.skew.x = skewX;
      transform.skew.y = skewY;
    }

    // next set scale
    transform.scale.x = Math.sqrt((a * a) + (b * b));
    transform.scale.y = Math.sqrt((c * c) + (d * d));

    // next set position
    transform.position.x = this.tx;
    transform.position.y = this.ty;

    return transform;
  }

  /**
   * Inverts this matrix
   *
   * @return {PIXI.Matrix} This matrix. Good for chaining method calls.
   */
  invert()
  {
    const a1 = this.a;
    const b1 = this.b;
    const c1 = this.c;
    const d1 = this.d;
    const tx1 = this.tx;
    const n = (a1 * d1) - (b1 * c1);

    this.a = d1 / n;
    this.b = -b1 / n;
    this.c = -c1 / n;
    this.d = a1 / n;
    this.tx = ((c1 * this.ty) - (d1 * tx1)) / n;
    this.ty = -((a1 * this.ty) - (b1 * tx1)) / n;

    return this;
  }

  /**
   * Resets this Matix to an identity (default) matrix.
   *
   * @return {PIXI.Matrix} This matrix. Good for chaining method calls.
   */
  identity()
  {
    this.a = 1;
    this.b = 0;
    this.c = 0;
    this.d = 1;
    this.tx = 0;
    this.ty = 0;

    return this;
  }

  /**
   * Creates a new Matrix object with the same values as this one.
   *
   * @return {PIXI.Matrix} A copy of this matrix. Good for chaining method calls.
   */
  clone()
  {
    const matrix = new Matrix();

    matrix.a = this.a;
    matrix.b = this.b;
    matrix.c = this.c;
    matrix.d = this.d;
    matrix.tx = this.tx;
    matrix.ty = this.ty;

    return matrix;
  }

  /**
   * Changes the values of the given matrix to be the same as the ones in this matrix
   *
   * @param {PIXI.Matrix} matrix - The matrix to copy to.
   * @return {PIXI.Matrix} The matrix given in parameter with its values updated.
   */
  copyTo(matrix)
  {
    matrix.a = this.a;
    matrix.b = this.b;
    matrix.c = this.c;
    matrix.d = this.d;
    matrix.tx = this.tx;
    matrix.ty = this.ty;

    return matrix;
  }

  /**
   * Changes the values of the matrix to be the same as the ones in given matrix
   *
   * @param {PIXI.Matrix} matrix - The matrix to copy from.
   * @return {PIXI.Matrix} this
   */
  copyFrom(matrix)
  {
    this.a = matrix.a;
    this.b = matrix.b;
    this.c = matrix.c;
    this.d = matrix.d;
    this.tx = matrix.tx;
    this.ty = matrix.ty;

    return this;
  }

  /**
   * A default (identity) matrix
   *
   * @static
   * @const
   */
  static get IDENTITY()
  {
    return new Matrix();
  }

  /**
   * A temp matrix
   *
   * @static
   * @const
   */
  static get TEMP_MATRIX()
  {
    return new Matrix();
  }
}
