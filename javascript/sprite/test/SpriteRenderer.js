const { SpriteRenderer } = require('../');

const mockrunner = {
    contextChange: {
        remove: () => 1,
        add: () => 1,
    },
};

describe('SpriteRenderer', function ()
{
    it('can be destroyed', function ()
    {
        const destroyable = { destroy: sinon.stub() };
        const webgl = {
            on: sinon.stub(),
            runners: mockrunner,
            off: sinon.stub(),
        };
        const renderer = new SpriteRenderer(webgl);

        // simulate onContextChange
        renderer.vertexBuffers = [destroyable, destroyable];
        renderer.vaos = [destroyable, destroyable];
        renderer.indexBuffer = destroyable;
        renderer.shader = destroyable;

        expect(() => renderer.destroy()).to.not.throw();
    });

    it('can be destroyed immediately', function ()
    {
        const webgl = {
            on: sinon.stub(),
            runners: mockrunner,
            off: sinon.stub(),
        };

        const renderer = new SpriteRenderer(webgl);

        expect(() => renderer.destroy()).to.not.throw();
    });
});
