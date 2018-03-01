import System from '../System';
import { Matrix } from '@pixi/math';

/**
 * @class
 * @extends PIXI.System
 * @memberof PIXI.systems
 */

export default class ProjectionSystem extends System
{
    /**
     * @param {PIXI.Renderer} renderer - The renderer this System works for.
     */
    constructor(renderer)
    {
        super(renderer);

        this.projectionMatrix = new Matrix();
    }

    update(destinationFrame, sourceFrame, resolution, root)
    {
        this.destinationFrame = destinationFrame || this.destinationFrame || this.defaultFrame;
        this.sourceFrame = sourceFrame || this.sourceFrame || destinationFrame;

        this.calculateProjection(this.destinationFrame, this.sourceFrame, resolution, root);

        this.renderer.globalUniforms.uniforms.projectionMatrix = this.projectionMatrix;
        this.renderer.globalUniforms.update();
    }

    /**
     * Updates the projection matrix based on a projection frame (which is a rectangle)
     *
     * @param {Rectangle} destinationFrame - The destination frame.
     * @param {Rectangle} sourceFrame - The source frame.
     */
    calculateProjection(destinationFrame, sourceFrame, resolution, root)
    {
        const pm = this.projectionMatrix;

        // I don't think we will need this line..
        // pm.identity();

        if (!root)
        {
            pm.a = (1 / destinationFrame.width * 2) * resolution;
            pm.d = (1 / destinationFrame.height * 2) * resolution;

            pm.tx = -1 - (sourceFrame.x * pm.a);
            pm.ty = -1 - (sourceFrame.y * pm.d);
        }
        else
        {
            pm.a = (1 / destinationFrame.width * 2) * resolution;
            pm.d = (-1 / destinationFrame.height * 2) * resolution;

            pm.tx = -1 - (sourceFrame.x * pm.a);
            pm.ty = 1 - (sourceFrame.y * pm.d);
        }
    }

    /**
     * Sets the transform of the active render target to the given matrix
     *
     * @param {PIXI.Matrix} matrix - The transformation matrix
     */
    setTransform()// matrix)
    {
        // this._activeRenderTarget.transform = matrix;
    }
}
