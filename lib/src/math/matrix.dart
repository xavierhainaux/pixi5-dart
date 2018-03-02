import 'dart:typed_data';

import 'package:pixi/src/math/transform.dart';

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
  num a, b, c, d, tx, ty;

  /**
   * @param {number} [a=1] - x scale
   * @param {number} [b=0] - x skew
   * @param {number} [c=0] - y skew
   * @param {number} [d=1] - y scale
   * @param {number} [tx=0] - x translation
   * @param {number} [ty=0] - y translation
   */
  Matrix([this.a = 1.0, this.b = 0.0, this.c = 0.0, this.d = 1.0, this.tx = 0.0, this.ty = 0.0]);

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
  factory Matrix.fromArray(List<num> array)
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
    a = a;
    b = b;
    c = c;
    d = d;
    tx = tx;
    ty = ty;
  }

  /**
   * Creates an array from the current Matrix object.
   *
   * @param {boolean} transpose - Whether we need to transpose the matrix or not
   * @param {Float32Array} [out=new Float32Array(9)] - If provided the array will be assigned to out
   * @return {number[]} the newly created array which contains the matrix
   */
  Float32List toArray({bool transpose: false, Float32List result})
  {
    result ??= new Float32List(9);

    if (transpose)
    {
      result[0] = a.toDouble();
      result[1] = b.toDouble();
      result[2] = 0.0;
      result[3] = c.toDouble();
      result[4] = d.toDouble();
      result[5] = 0.0;
      result[6] = tx.toDouble();
      result[7] = ty.toDouble();
      result[8] = 1.0;
    }
    else
    {
      result[0] = a.toDouble();
      result[1] = c.toDouble();
      result[2] = tx.toDouble();
      result[3] = b.toDouble();
      result[4] = d.toDouble();
      result[5] = ty.toDouble();
      result[6] = 0.0;
      result[7] = 0.0;
      result[8] = 1.0;
    }

    return result;
  }

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

    final num x = pos.x;
    final num y = pos.y;
    result.set((a * x) + (c * y) + tx, (b * x) + (d * y) + ty);

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

    final num id = 1.0 / ((a * d) + (c * -b));

    final num x = pos.x;
    final num y = pos.y;

    result.set((d * id * x) + (-c * id * y) + (((ty * c) - (tx * d)) * id),
    (a * id * y) + (-b * id * x) + (((-ty * a) + (tx * b)) * id));

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
    tx += x;
    ty += y;
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
    a *= x;
    d *= y;
    c *= x;
    b *= y;
    tx *= x;
    ty *= y;
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

    final num a1 = a;
    final num c1 = c;
    final num tx1 = tx;

    a = (a1 * cos) - (b * sin);
    b = (a1 * sin) + (b * cos);
    c = (c1 * cos) - (d * sin);
    d = (c1 * sin) + (d * cos);
    tx = (tx1 * cos) - (ty * sin);
    ty = (tx1 * sin) + (ty * cos);
  }

  /**
   * Appends the given Matrix to this Matrix.
   *
   * @param {PIXI.Matrix} matrix - The matrix to append.
   * @return {PIXI.Matrix} This matrix. Good for chaining method calls.
   */
  void append(Matrix matrix)
  {
    final num a1 = a;
    final num b1 = b;
    final num c1 = c;
    final num d1 = d;

    a = (matrix.a * a1) + (matrix.b * c1);
    b = (matrix.a * b1) + (matrix.b * d1);
    c = (matrix.c * a1) + (matrix.d * c1);
    d = (matrix.c * b1) + (matrix.d * d1);

    tx = (matrix.tx * a1) + (matrix.ty * c1) + tx;
    ty = (matrix.tx * b1) + (matrix.ty * d1) + ty;
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
  void setTransform(num x, num y, num pivotX, num pivotY, num scaleX, num scaleY, num rotation, num skewX, num skewY)
  {
    a = math.cos(rotation + skewY) * scaleX;
    b = math.sin(rotation + skewY) * scaleX;
    c = -math.sin(rotation - skewX) * scaleY;
    d = math.cos(rotation - skewX) * scaleY;

    tx = x - ((pivotX * a) + (pivotY * c));
    ty = y - ((pivotX * b) + (pivotY * d));
  }

  /**
   * Prepends the given Matrix to this Matrix.
   *
   * @param {PIXI.Matrix} matrix - The matrix to prepend
   * @return {PIXI.Matrix} This matrix. Good for chaining method calls.
   */
  void prepend(Matrix matrix)
  {
    final num tx1 = tx;

    if (matrix.a != 1 || matrix.b != 0 || matrix.c != 0 || matrix.d != 1)
    {
      final num a1 = a;
      final num c1 = c;

      a = (a1 * matrix.a) + (b * matrix.c);
      b = (a1 * matrix.b) + (b * matrix.d);
      c = (c1 * matrix.a) + (d * matrix.c);
      d = (c1 * matrix.b) + (d * matrix.d);
    }

    tx = (tx1 * matrix.a) + (ty * matrix.c) + matrix.tx;
    ty = (tx1 * matrix.b) + (ty * matrix.d) + matrix.ty;
  }

  /**
   * Decomposes the matrix (x, y, scaleX, scaleY, and rotation) and sets the properties on to a transform.
   *
   * @param {PIXI.Transform} transform - The transform to apply the properties to.
   * @return {PIXI.Transform} The transform with the newly applied properties
   */
  void decompose(Transform transform)
  {
    // sort out rotation / skew..
    final num skewX = -math.atan2(-c, d);
    final num skewY = math.atan2(b, a);

    final num delta = (skewX + skewY).abs();

    if (delta < 0.00001 || (math.PI * 2 - delta).abs() < 0.00001)
    {
      transform.rotation = skewY;

      if (a < 0 && d >= 0)
      {
        transform.rotation += (transform.rotation <= 0) ? math.PI : -math.PI;
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
    transform.scale.x = math.sqrt((a * a) + (b * b));
    transform.scale.y = math.sqrt((c * c) + (d * d));

    // next set position
    transform.position.x = tx;
    transform.position.y = ty;

    return transform;
  }

  /**
   * Inverts this matrix
   *
   */
  void invert()
  {
    final num a1 = a;
    final num b1 = b;
    final num c1 = c;
    final num d1 = d;
    final num tx1 = tx;
    final num n = (a1 * d1) - (b1 * c1);

    a = d1 / n;
    b = -b1 / n;
    c = -c1 / n;
    d = a1 / n;
    tx = ((c1 * ty) - (d1 * tx1)) / n;
    ty = -((a1 * ty) - (b1 * tx1)) / n;
  }

  /**
   * Resets this Matix to an identity (default) matrix.
   *
   */
  void setToIdentity()
  {
    a = 1;
    b = 0;
    c = 0;
    d = 1;
    tx = 0;
    ty = 0;
  }

  /**
   * Creates a new Matrix object with the same values as this one.
   *
   * @return {PIXI.Matrix} A copy of this matrix. Good for chaining method calls.
   */
  Matrix clone()
  {
    return new Matrix(a, b, c, d, tx, ty);
  }

  /**
   * Changes the values of the given matrix to be the same as the ones in this matrix
   *
   * @param {PIXI.Matrix} matrix - The matrix to copy to.
   */
  void copyTo(Matrix matrix)
  {
    matrix.a = a;
    matrix.b = b;
    matrix.c = c;
    matrix.d = d;
    matrix.tx = tx;
    matrix.ty = ty;
  }

  /**
   * Changes the values of the matrix to be the same as the ones in given matrix
   *
   * @param {PIXI.Matrix} matrix - The matrix to copy from.
   * @return {PIXI.Matrix} this
   */
  void copyFrom(Matrix matrix)
  {
    matrix.copyTo(this);
  }

  /**
   * A default (identity) matrix
   *
   * @static
   * @const
   */
  static final Matrix identity = new Matrix();

  /**
   * A temp matrix
   *
   * @static
   * @const
   */
  static final Matrix tempMatrix = new Matrix();
}
