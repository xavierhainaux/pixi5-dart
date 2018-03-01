const path = require('path');
const fs = require('fs');
const { BaseTextureCache, TextureCache } = require('@pixi/utils');
const { Texture, BaseTexture } = require('@pixi/core');
const { Spritesheet } = require('@pixi/spritesheet');
const { BitmapText, BitmapFontLoader } = require('../');

describe('PIXI.BitmapFontLoader', function ()
{
    afterEach(function ()
    {
        for (const font in BitmapText.fonts)
        {
            delete BitmapText.fonts[font];
        }
        for (const baseTexture in BaseTextureCache)
        {
            delete BaseTextureCache[baseTexture];
        }
        for (const texture in TextureCache)
        {
            delete TextureCache[texture];
        }
    });

    before(function (done)
    {
        const resolveURL = (url) => path.resolve(this.resources, url);

        this.resources = path.join(__dirname, 'resources');
        this.fontXML = null;
        this.fontScaledXML = null;
        this.fontImage = null;
        this.fontScaledImage = null;
        this.atlasImage = null;
        this.atlasScaledImage = null;
        this.atlasJSON = require(resolveURL('atlas.json')); // eslint-disable-line global-require
        this.atlasScaledJSON = require(resolveURL('atlas@0.5x.json')); // eslint-disable-line global-require

        const loadXML = (url) => new Promise((resolve) =>
            fs.readFile(resolveURL(url), 'utf8', (err, data) =>
            {
                expect(err).to.be.null;
                resolve((new window.DOMParser()).parseFromString(data, 'text/xml'));
            }));

        const loadImage = (url) => new Promise((resolve) =>
        {
            const image = new Image();

            image.onload = () => resolve(image);
            image.src = resolveURL(url);
        });

        Promise.all([
            loadXML('font.fnt'),
            loadXML('font@0.5x.fnt'),
            loadImage('font.png'),
            loadImage('font@0.5x.png'),
            loadImage('atlas.png'),
            loadImage('atlas@0.5x.png'),
        ]).then(([
            fontXML,
            fontScaledXML,
            fontImage,
            fontScaledImage,
            atlasImage,
            atlasScaledImage,
        ]) =>
        {
            this.fontXML = fontXML;
            this.fontScaledXML = fontScaledXML;
            this.fontImage = fontImage;
            this.fontScaledImage = fontScaledImage;
            this.atlasImage = atlasImage;
            this.atlasScaledImage = atlasScaledImage;
            done();
        });
    });

    it('should exist and return a function', function ()
    {
        expect(BitmapFontLoader).to.not.be.undefined;
        expect(BitmapFontLoader.use).to.be.a('function');
    });

    it('should process dirname correctly', function ()
    {
        const { dirname } = BitmapFontLoader;

        expect(dirname('file.fnt')).to.equal('.');
        expect(dirname('/file.fnt')).to.equal('/');
        expect(dirname('foo/bar/file.fnt')).to.equal('foo/bar');
        expect(dirname('/foo/bar/file.fnt')).to.equal('/foo/bar');
        expect(dirname('../file.fnt')).to.equal('..');
    });

    it('should do nothing if the resource is not XML', function ()
    {
        const spy = sinon.spy();
        const res = {};

        BitmapFontLoader.use(res, spy);

        expect(spy).to.have.been.calledOnce;
        expect(res.textures).to.be.undefined;
    });

    it('should do nothing if the resource is not properly formatted XML', function ()
    {
        const spy = sinon.spy();
        const res = { data: document.createDocumentFragment() };

        BitmapFontLoader.use(res, spy);

        expect(spy).to.have.been.calledOnce;
        expect(res.textures).to.be.undefined;
    });

    // TODO: Test the texture cache code path.
    // TODO: Test the loading texture code path.
    // TODO: Test data-url code paths.

    it('should properly register bitmap font', function (done)
    {
        const texture = new Texture(new BaseTexture(this.fontImage, null, 1));
        const font = BitmapText.registerFont(this.fontXML, texture);

        expect(font).to.be.an.object;
        expect(BitmapText.fonts.font).to.equal(font);
        expect(font).to.have.property('chars');
        const charA = font.chars['A'.charCodeAt(0) || 65];

        expect(charA).to.exist;
        expect(charA.texture.baseTexture.resource.source).to.equal(this.fontImage);
        expect(charA.texture.frame.x).to.equal(2);
        expect(charA.texture.frame.y).to.equal(2);
        expect(charA.texture.frame.width).to.equal(19);
        expect(charA.texture.frame.height).to.equal(20);
        const charB = font.chars['B'.charCodeAt(0) || 66];

        expect(charB).to.exist;
        expect(charB.texture.baseTexture.resource.source).to.equal(this.fontImage);
        expect(charB.texture.frame.x).to.equal(2);
        expect(charB.texture.frame.y).to.equal(24);
        expect(charB.texture.frame.width).to.equal(15);
        expect(charB.texture.frame.height).to.equal(20);
        const charC = font.chars['C'.charCodeAt(0) || 67];

        expect(charC).to.exist;
        expect(charC.texture.baseTexture.resource.source).to.equal(this.fontImage);
        expect(charC.texture.frame.x).to.equal(23);
        expect(charC.texture.frame.y).to.equal(2);
        expect(charC.texture.frame.width).to.equal(18);
        expect(charC.texture.frame.height).to.equal(20);
        const charD = font.chars['D'.charCodeAt(0) || 68];

        expect(charD).to.exist;
        expect(charD.texture.baseTexture.resource.source).to.equal(this.fontImage);
        expect(charD.texture.frame.x).to.equal(19);
        expect(charD.texture.frame.y).to.equal(24);
        expect(charD.texture.frame.width).to.equal(17);
        expect(charD.texture.frame.height).to.equal(20);
        const charE = font.chars['E'.charCodeAt(0) || 69];

        expect(charE).to.be.undefined;
        done();
    });

    it('should properly register SCALED bitmap font', function (done)
    {
        const baseTexture = new BaseTexture(this.fontScaledImage);

        baseTexture.setResolution(0.5);

        const texture = new Texture(baseTexture);
        const font = BitmapText.registerFont(this.fontScaledXML, texture);

        expect(font).to.be.an.object;
        expect(BitmapText.fonts.font).to.equal(font);
        expect(font).to.have.property('chars');
        const charA = font.chars['A'.charCodeAt(0) || 65];

        expect(charA).to.exist;
        expect(charA.texture.baseTexture.resource.source).to.equal(this.fontScaledImage);
        expect(charA.texture.frame.x).to.equal(4); // 2 / 0.5
        expect(charA.texture.frame.y).to.equal(4); // 2 / 0.5
        expect(charA.texture.frame.width).to.equal(38); // 19 / 0.5
        expect(charA.texture.frame.height).to.equal(40); // 20 / 0.5
        const charB = font.chars['B'.charCodeAt(0) || 66];

        expect(charB).to.exist;
        expect(charB.texture.baseTexture.resource.source).to.equal(this.fontScaledImage);
        expect(charB.texture.frame.x).to.equal(4); // 2 / 0.5
        expect(charB.texture.frame.y).to.equal(48); // 24 / 0.5
        expect(charB.texture.frame.width).to.equal(30); // 15 / 0.5
        expect(charB.texture.frame.height).to.equal(40); // 20 / 0.5
        const charC = font.chars['C'.charCodeAt(0) || 67];

        expect(charC).to.exist;
        expect(charC.texture.baseTexture.resource.source).to.equal(this.fontScaledImage);
        expect(charC.texture.frame.x).to.equal(46); // 23 / 0.5
        expect(charC.texture.frame.y).to.equal(4); // 2 / 0.5
        expect(charC.texture.frame.width).to.equal(36); // 18 / 0.5
        expect(charC.texture.frame.height).to.equal(40); // 20 / 0.5
        const charD = font.chars['D'.charCodeAt(0) || 68];

        expect(charD).to.exist;
        expect(charD.texture.baseTexture.resource.source).to.equal(this.fontScaledImage);
        expect(charD.texture.frame.x).to.equal(38); // 19 / 0.5
        expect(charD.texture.frame.y).to.equal(48); // 24 / 0.5
        expect(charD.texture.frame.width).to.equal(34); // 17 / 0.5
        expect(charD.texture.frame.height).to.equal(40); // 20 / 0.5
        const charE = font.chars['E'.charCodeAt(0) || 69];

        expect(charE).to.be.undefined;
        done();
    });

    it('should properly register bitmap font NESTED into spritesheet', function (done)
    {
        const baseTexture = new BaseTexture(this.atlasImage, null, 1);
        const spritesheet = new Spritesheet(baseTexture, this.atlasJSON);

        spritesheet.parse(() =>
        {
            const fontTexture  = Texture.fromFrame('resources/font.png');
            const font =  BitmapText.registerFont(this.fontXML, fontTexture);
            const fontX = 158; // bare value from spritesheet frame
            const fontY = 2; // bare value from spritesheet frame

            expect(font).to.be.an.object;
            expect(BitmapText.fonts.font).to.equal(font);
            expect(font).to.have.property('chars');
            const charA = font.chars['A'.charCodeAt(0) || 65];

            expect(charA).to.exist;
            expect(charA.texture.baseTexture.resource.source).to.equal(this.atlasImage);
            expect(charA.texture.frame.x).to.equal(fontX + 2);
            expect(charA.texture.frame.y).to.equal(fontY + 2);
            expect(charA.texture.frame.width).to.equal(19);
            expect(charA.texture.frame.height).to.equal(20);
            const charB = font.chars['B'.charCodeAt(0) || 66];

            expect(charB).to.exist;
            expect(charB.texture.baseTexture.resource.source).to.equal(this.atlasImage);
            expect(charB.texture.frame.x).to.equal(fontX + 2);
            expect(charB.texture.frame.y).to.equal(fontY + 24);
            expect(charB.texture.frame.width).to.equal(15);
            expect(charB.texture.frame.height).to.equal(20);
            const charC = font.chars['C'.charCodeAt(0) || 67];

            expect(charC).to.exist;
            expect(charC.texture.baseTexture.resource.source).to.equal(this.atlasImage);
            expect(charC.texture.frame.x).to.equal(fontX + 23);
            expect(charC.texture.frame.y).to.equal(fontY + 2);
            expect(charC.texture.frame.width).to.equal(18);
            expect(charC.texture.frame.height).to.equal(20);
            const charD = font.chars['D'.charCodeAt(0) || 68];

            expect(charD).to.exist;
            expect(charD.texture.baseTexture.resource.source).to.equal(this.atlasImage);
            expect(charD.texture.frame.x).to.equal(fontX + 19);
            expect(charD.texture.frame.y).to.equal(fontY + 24);
            expect(charD.texture.frame.width).to.equal(17);
            expect(charD.texture.frame.height).to.equal(20);
            const charE = font.chars['E'.charCodeAt(0) || 69];

            expect(charE).to.be.undefined;
            done();
        });
    });

    it('should properly register bitmap font NESTED into SCALED spritesheet', function (done)
    {
        const baseTexture = new BaseTexture(this.atlasScaledImage, null, 1);
        const spritesheet = new Spritesheet(baseTexture, this.atlasScaledJSON);

        spritesheet.resolution = 1;

        spritesheet.parse(() =>
        {
            const fontTexture  = Texture.fromFrame('resources/font.png');
            const font =  BitmapText.registerFont(this.fontXML, fontTexture);
            const fontX = 158; // bare value from spritesheet frame
            const fontY = 2; // bare value from spritesheet frame

            expect(font).to.be.an.object;
            expect(BitmapText.fonts.font).to.equal(font);
            expect(font).to.have.property('chars');
            const charA = font.chars['A'.charCodeAt(0) || 65];

            expect(charA).to.exist;
            expect(charA.texture.baseTexture.resource.source).to.equal(this.atlasScaledImage);
            expect(charA.texture.frame.x).to.equal(fontX + 2);
            expect(charA.texture.frame.y).to.equal(fontY + 2);
            expect(charA.texture.frame.width).to.equal(19);
            expect(charA.texture.frame.height).to.equal(20);
            const charB = font.chars['B'.charCodeAt(0) || 66];

            expect(charB).to.exist;
            expect(charB.texture.baseTexture.resource.source).to.equal(this.atlasScaledImage);
            expect(charB.texture.frame.x).to.equal(fontX + 2);
            expect(charB.texture.frame.y).to.equal(fontY + 24);
            expect(charB.texture.frame.width).to.equal(15);
            expect(charB.texture.frame.height).to.equal(20);
            const charC = font.chars['C'.charCodeAt(0) || 67];

            expect(charC).to.exist;
            expect(charC.texture.baseTexture.resource.source).to.equal(this.atlasScaledImage);
            expect(charC.texture.frame.x).to.equal(fontX + 23);
            expect(charC.texture.frame.y).to.equal(fontY + 2);
            expect(charC.texture.frame.width).to.equal(18);
            expect(charC.texture.frame.height).to.equal(20);
            const charD = font.chars['D'.charCodeAt(0) || 68];

            expect(charD).to.exist;
            expect(charD.texture.baseTexture.resource.source).to.equal(this.atlasScaledImage);
            expect(charD.texture.frame.x).to.equal(fontX + 19);
            expect(charD.texture.frame.y).to.equal(fontY + 24);
            expect(charD.texture.frame.width).to.equal(17);
            expect(charD.texture.frame.height).to.equal(20);
            const charE = font.chars['E'.charCodeAt(0) || 69];

            expect(charE).to.be.undefined;
            done();
        });
    });

    it('should parse exist', function ()
    {
        expect(BitmapFontLoader.parse).to.be.a('function');
    });
});
