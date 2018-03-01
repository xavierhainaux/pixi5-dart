const { Container } = require('@pixi/display');
const { Texture, BaseTexture } = require('@pixi/core');
const { Point } = require('@pixi/math');
const { TilingSprite } = require('../');

describe('PIXI.TilingSprite', function ()
{
    describe('getBounds()', function ()
    {
        it('must have correct value according to _width, _height and anchor', function ()
        {
            const parent = new Container();
            const texture = new Texture(new BaseTexture());
            const tilingSprite = new TilingSprite(texture, 200, 300);

            parent.addChild(tilingSprite);

            tilingSprite.anchor.set(0.5, 0.5);
            tilingSprite.scale.set(-2, 2);
            tilingSprite.position.set(50, 40);

            const bounds = tilingSprite.getBounds();

            expect(bounds.x).to.equal(-150);
            expect(bounds.y).to.equal(-260);
            expect(bounds.width).to.equal(400);
            expect(bounds.height).to.equal(600);
        });
    });

    it('checks if tilingSprite contains a point', function ()
    {
        const texture = new Texture(new BaseTexture());
        const tilingSprite = new TilingSprite(texture, 200, 300);

        expect(tilingSprite.containsPoint(new Point(0, 0))).to.equal(true);
        expect(tilingSprite.containsPoint(new Point(10, 10))).to.equal(true);
        expect(tilingSprite.containsPoint(new Point(200, 300))).to.equal(false);
        expect(tilingSprite.containsPoint(new Point(300, 400))).to.equal(false);
    });

    it('gets and sets height and width correctly', function ()
    {
        const texture = new Texture(new BaseTexture());
        const tilingSprite = new TilingSprite(texture, 200, 300);

        tilingSprite.width = 400;
        tilingSprite.height = 600;

        expect(tilingSprite.width).to.equal(400);
        expect(tilingSprite.height).to.equal(600);
    });
});
