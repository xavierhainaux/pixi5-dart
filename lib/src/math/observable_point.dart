import 'package:pixi/src/math/point.dart';

/**
 * The Point object represents a location in a two-dimensional coordinate system, where x represents
 * the horizontal axis and y represents the vertical axis.
 * An observable point is a point that triggers a callback when the point's position is changed.
 *
 * @class
 * @memberof PIXI
 */
class ObservablePoint implements Point
{
  final Function() callback;
  num _x, _y;

  /**
   * @param {Function} cb - callback when changed
   * @param {number} [x=0] - position of the point on the x axis
   * @param {number} [y=0] - position of the point on the y axis
   */
  ObservablePoint(this.callback, [this._x = 0, this._y = 0]) {
    assert(callback != null);
    assert(_x != null);
    assert(_y != null);
  }

  /**
   * Sets the point to a new x and y position.
   * If y is omitted, both x and y will be set to x.
   *
   * @param {number} [x=0] - position of the point on the x axis
   * @param {number} [y=0] - position of the point on the y axis
   */
  @override
  void set(num x, num y)
  {
    assert(x != null);
    assert(y != null);

    if (_x != x || _y != y)
    {
      _x = x;
      _y = y;
      callback();
    }
  }

  /**
   * Copies x and y from the given point
   *
   * @param {PIXI.Point} p - The point to copy from.
   * @returns Returns itself.
   */
  @override
  void copyFrom(Point p)
  {
    if (_x != p.x || _y != p.y)
    {
      _x = p.x;
      _y = p.y;
      callback();
    }
  }

  /**
   * Copies x and y into the given point
   *
   * @param {PIXI.Point} p - The point to copy.
   * @returns Given point with values updated
   */
  @override
  void copyTo(Point p)
  {
    p.set(_x, _y);
  }

  /**
   * The position of the displayObject on the x axis relative to the local coordinates of the parent.
   *
   * @member {number}
   */
  @override
  num get x => _x;

  set x(num value)
  {
    assert(value != null);

    if (_x != value)
    {
      _x = value;
      callback();
    }
  }

  /**
   * The position of the displayObject on the x axis relative to the local coordinates of the parent.
   *
   * @member {number}
   */
  @override
  num get y => _y;

  set y(num value)
  {
    assert(value != null);

    if (_y != value)
    {
      _y = value;
      callback();
    }
  }
}
