import { TextureCache } from '@pixi/utils';
import { LoaderResource } from '@pixi/loaders';
import BitmapText from './BitmapText';

/**
 * {@link PIXI.Loader Loader} middleware for loading
 * bitmap-based fonts suitable for using with {@link PIXI.BitmapText}.
 * @class
 * @memberof PIXI
 * @extends PIXI.Loader~LoaderPlugin
 */
export default class BitmapFontLoader
{
    /**
     * Register a BitmapText font from loader resource.
     *
     * @param {PIXI.LoaderResource} resource - Loader resource.
     * @param {PIXI.Texture} texture - Reference to texture.
     */
    static parse(resource, texture)
    {
        resource.bitmapFont = BitmapText.registerFont(resource.data, texture);
    }

    /**
     * Called when the plugin is installed.
     *
     * @see PIXI.Loader.registerPlugin
     */
    static add()
    {
        LoaderResource.setExtensionXhrType('fnt', LoaderResource.XHR_RESPONSE_TYPE.DOCUMENT);
    }

    /**
     * Replacement for NodeJS's path.dirname
     * @private
     * @param {string} url Path to get directory for
     */
    static dirname(url)
    {
        const dir = url
            .replace(/\/$/, '') // replace trailing slash
            .replace(/\/[^\/]*$/, ''); // remove everything after the last

        // File request is relative, use current directory
        if (dir === url)
        {
            return '.';
        }
        // Started with a slash
        else if (dir === '')
        {
            return '/';
        }

        return dir;
    }

    /**
     * Called after a resource is loaded.
     * @see PIXI.Loader~loaderMiddleware
     * @param {PIXI.LoaderResource} resource
     * @param {function} next
     */
    static use(resource, next)
    {
        // skip if no data or not xml data
        if (!resource.data || resource.type !== LoaderResource.TYPE.XML)
        {
            next();

            return;
        }

        // skip if not bitmap font data, using some silly duck-typing
        if (resource.data.getElementsByTagName('page').length === 0
            || resource.data.getElementsByTagName('info').length === 0
            || resource.data.getElementsByTagName('info')[0].getAttribute('face') === null
        )
        {
            next();

            return;
        }

        let xmlUrl = !resource.isDataUrl ? BitmapFontLoader.dirname(resource.url) : '';

        if (resource.isDataUrl)
        {
            if (xmlUrl === '.')
            {
                xmlUrl = '';
            }

            if (this.baseUrl && xmlUrl)
            {
                // if baseurl has a trailing slash then add one to xmlUrl so the replace works below
                if (this.baseUrl.charAt(this.baseUrl.length - 1) === '/')
                {
                    xmlUrl += '/';
                }
            }
        }

        // remove baseUrl from xmlUrl
        xmlUrl = xmlUrl.replace(this.baseUrl, '');

        // if there is an xmlUrl now, it needs a trailing slash. Ensure that it does if the string isn't empty.
        if (xmlUrl && xmlUrl.charAt(xmlUrl.length - 1) !== '/')
        {
            xmlUrl += '/';
        }

        const textureUrl = xmlUrl + resource.data.getElementsByTagName('page')[0].getAttribute('file');

        if (TextureCache[textureUrl])
        {
            // reuse existing texture
            BitmapFontLoader.parse(resource, TextureCache[textureUrl]);
            next();
        }
        else
        {
            const loadOptions = {
                crossOrigin: resource.crossOrigin,
                loadType: LoaderResource.LOAD_TYPE.IMAGE,
                metadata: resource.metadata.imageMetadata,
                parentResource: resource,
            };

            // load the texture for the font
            this.add(`${resource.name}_image`, textureUrl, loadOptions, (res) =>
            {
                BitmapFontLoader.parse(resource, res.texture);
                next();
            });
        }
    }
}
