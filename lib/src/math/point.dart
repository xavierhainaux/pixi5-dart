/**
 * The Point object represents a location in a two-dimensional coordinate system, where x represents
 * the horizontal axis and y represents the vertical axis.
 *
 * @class
 * @memberof PIXI
 */
class Point
{
  num _x, _y;
  /**
   * @param {number} [x=0] - position of the point on the x axis
   * @param {number} [y=0] - position of the point on the y axis
   */
  Point([this._x, this._y]) {
    assert(_x != null);
    assert(_y != null);
  }

  num get x => _x;

  num get y => _y;

  /**
   * Copies x and y from the given point
   *
   * @param {PIXI.Point} p - The point to copy from
   * @returns Returns itself.
   */
  void copyFrom(Point p)
  {
    set(p.x, p.y);
  }

  /**
   * Copies x and y into the given point
   *
   * @param {PIXI.Point} p - The point to copy.
   * @returns Given point with values updated
   */
  void copyTo(Point p)
  {
    p.set(x, y);
  }

  /**
   * Returns true if the given point is equal to this point
   *
   * @param {PIXI.Point} p - The point to check
   * @returns {boolean} Whether the given point equal to this point
   */
  bool operator==(Object p)
  {
    if (p is Point)  return (p.x == x) && (p.y == y);
    return false;
  }

  /**
   * Sets the point to a new x and y position.
   * If y is omitted, both x and y will be set to x.
   *
   * @param {number} [x=0] - position of the point on the x axis
   * @param {number} [y=0] - position of the point on the y axis
   */
  void set(num x, num y)
  {
    assert(x != null);
    assert(y != null);
    
    _x = x;
    _y = y;
  }
}
