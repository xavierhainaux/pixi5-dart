const { BaseTextureCache, TextureCache } = require('@pixi/utils');
const { BaseTexture, Texture } = require('../');

const URL = 'foo.png';
const NAME = 'foo';
const NAME2 = 'bar';

function cleanCache()
{
    delete BaseTextureCache[URL];
    delete BaseTextureCache[NAME];
    delete BaseTextureCache[NAME2];

    delete TextureCache[URL];
    delete TextureCache[NAME];
    delete TextureCache[NAME2];
}

describe('PIXI.Texture', function ()
{
    it('should register Texture from Loader', function ()
    {
        cleanCache();

        const image = new Image();

        const texture = Texture.fromLoader(image, URL, NAME);

        expect(texture.baseTexture.resource.url).to.equal('foo.png');
        expect(TextureCache[NAME]).to.equal(texture);
        expect(BaseTextureCache[NAME]).to.equal(texture.baseTexture);
        expect(TextureCache[URL]).to.equal(texture);
        expect(BaseTextureCache[URL]).to.equal(texture.baseTexture);
    });

    it('should remove Texture from cache on destroy', function ()
    {
        cleanCache();

        const texture = new Texture(new BaseTexture());

        Texture.addToCache(texture, NAME);
        Texture.addToCache(texture, NAME2);
        expect(texture.textureCacheIds.indexOf(NAME)).to.equal(0);
        expect(texture.textureCacheIds.indexOf(NAME2)).to.equal(1);
        expect(TextureCache[NAME]).to.equal(texture);
        expect(TextureCache[NAME2]).to.equal(texture);
        texture.destroy();
        expect(texture.textureCacheIds).to.equal(null);
        expect(TextureCache[NAME]).to.equal(undefined);
        expect(TextureCache[NAME2]).to.equal(undefined);
    });

    it('should be added to the texture cache correctly, '
     + 'and should remove only itself, not effecting the base texture and its cache', function ()
    {
        cleanCache();

        const texture = new Texture(new BaseTexture());

        BaseTexture.addToCache(texture.baseTexture, NAME);
        Texture.addToCache(texture, NAME);
        expect(texture.baseTexture.textureCacheIds.indexOf(NAME)).to.equal(0);
        expect(texture.textureCacheIds.indexOf(NAME)).to.equal(0);
        expect(BaseTextureCache[NAME]).to.equal(texture.baseTexture);
        expect(TextureCache[NAME]).to.equal(texture);
        Texture.removeFromCache(NAME);
        expect(texture.baseTexture.textureCacheIds.indexOf(NAME)).to.equal(0);
        expect(texture.textureCacheIds.indexOf(NAME)).to.equal(-1);
        expect(BaseTextureCache[NAME]).to.equal(texture.baseTexture);
        expect(TextureCache[NAME]).to.equal(undefined);
    });

    it('should remove Texture from entire cache using removeFromCache (by Texture instance)', function ()
    {
        cleanCache();

        const texture = new Texture(new BaseTexture());

        Texture.addToCache(texture, NAME);
        Texture.addToCache(texture, NAME2);
        expect(texture.textureCacheIds.indexOf(NAME)).to.equal(0);
        expect(texture.textureCacheIds.indexOf(NAME2)).to.equal(1);
        expect(TextureCache[NAME]).to.equal(texture);
        expect(TextureCache[NAME2]).to.equal(texture);
        Texture.removeFromCache(texture);
        expect(texture.textureCacheIds.indexOf(NAME)).to.equal(-1);
        expect(texture.textureCacheIds.indexOf(NAME2)).to.equal(-1);
        expect(TextureCache[NAME]).to.equal(undefined);
        expect(TextureCache[NAME2]).to.equal(undefined);
    });

    it('should remove Texture from single cache entry using removeFromCache (by id)', function ()
    {
        cleanCache();

        const texture = new Texture(new BaseTexture());

        Texture.addToCache(texture, NAME);
        Texture.addToCache(texture, NAME2);
        expect(texture.textureCacheIds.indexOf(NAME)).to.equal(0);
        expect(texture.textureCacheIds.indexOf(NAME2)).to.equal(1);
        expect(TextureCache[NAME]).to.equal(texture);
        expect(TextureCache[NAME2]).to.equal(texture);
        Texture.removeFromCache(NAME);
        expect(texture.textureCacheIds.indexOf(NAME)).to.equal(-1);
        expect(texture.textureCacheIds.indexOf(NAME2)).to.equal(0);
        expect(TextureCache[NAME]).to.equal(undefined);
        expect(TextureCache[NAME2]).to.equal(texture);
    });

    it('should not remove Texture from cache if Texture instance has been replaced', function ()
    {
        cleanCache();

        const texture = new Texture(new BaseTexture());
        const texture2 = new Texture(new BaseTexture());

        Texture.addToCache(texture, NAME);
        expect(texture.textureCacheIds.indexOf(NAME)).to.equal(0);
        expect(TextureCache[NAME]).to.equal(texture);
        Texture.addToCache(texture2, NAME);
        expect(texture2.textureCacheIds.indexOf(NAME)).to.equal(0);
        expect(TextureCache[NAME]).to.equal(texture2);
        Texture.removeFromCache(texture);
        expect(texture.textureCacheIds.indexOf(NAME)).to.equal(-1);
        expect(texture2.textureCacheIds.indexOf(NAME)).to.equal(0);
        expect(TextureCache[NAME]).to.equal(texture2);
    });

    it('destroying a destroyed texture should not throw an error', function ()
    {
        const texture = new Texture(new BaseTexture());

        texture.destroy(true);
        texture.destroy(true);
    });
});
