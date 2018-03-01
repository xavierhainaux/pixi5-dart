import System from '../System';

/**
 * @class
 * @extends PIXI.System
 * @memberof PIXI.systems
 */
export default class StencilSystem extends System
{
    /**
     * @param {PIXI.Renderer} renderer - The renderer this System works for.
     */
    constructor(renderer)
    {
        super(renderer);
        this.stencilMaskStack = [];
    }

    /**
     * Changes the mask stack that is used by this System.
     *
     * @param {PIXI.Graphics[]} stencilMaskStack - The mask stack
     */
    setMaskStack(stencilMaskStack)
    {
        const gl = this.renderer.gl;

        if (stencilMaskStack.length !== this.stencilMaskStack.length)
        {
            if (stencilMaskStack.length === 0)
            {
                gl.disable(gl.STENCIL_TEST);
            }
            else
            {
                gl.enable(gl.STENCIL_TEST);
            }
        }

        this.stencilMaskStack = stencilMaskStack;
    }

    /**
     * Applies the Mask and adds it to the current stencil stack. @alvin
     *
     * @param {PIXI.Graphics} graphics - The mask
     */
    pushStencil(graphics)
    {
        this.renderer.batch.setObjectRenderer(this.renderer.plugins.graphics);

        //        this.renderer._activeRenderTarget.attachStencilBuffer();

        const gl = this.renderer.gl;
        const prevMaskCount = this.stencilMaskStack.length;

        if (prevMaskCount === 0)
        {
            gl.enable(gl.STENCIL_TEST);
        }

        this.stencilMaskStack.push(graphics);

        // Increment the refference stencil value where the new mask overlaps with the old ones.
        gl.colorMask(false, false, false, false);
        gl.stencilFunc(gl.EQUAL, prevMaskCount, this._getBitwiseMask());
        gl.stencilOp(gl.KEEP, gl.KEEP, gl.INCR);
        this.renderer.plugins.graphics.render(graphics);

        this._useCurrent();
    }

    /**
     * Removes the last mask from the stencil stack. @alvin
     */
    popStencil()
    {
        this.renderer.batch.setObjectRenderer(this.renderer.plugins.graphics);

        const gl = this.renderer.gl;
        const graphics = this.stencilMaskStack.pop();

        if (this.stencilMaskStack.length === 0)
        {
            // the stack is empty!
            gl.disable(gl.STENCIL_TEST);
            gl.clear(gl.STENCIL_BUFFER_BIT);
            gl.clearStencil(0);
        }
        else
        {
            // Decrement the refference stencil value where the popped mask overlaps with the other ones
            gl.colorMask(false, false, false, false);
            gl.stencilOp(gl.KEEP, gl.KEEP, gl.DECR);
            this.renderer.plugins.graphics.render(graphics);

            this._useCurrent();
        }
    }

    /**
     * Setup renderer to use the current stencil data.
     */
    _useCurrent()
    {
        const gl = this.renderer.gl;

        gl.colorMask(true, true, true, true);
        gl.stencilFunc(gl.EQUAL, this.stencilMaskStack.length, this._getBitwiseMask());
        gl.stencilOp(gl.KEEP, gl.KEEP, gl.KEEP);
    }

    /**
     * Fill 1s equal to the number of acitve stencil masks.
     *
     * @return {number} The bitwise mask.
     */
    _getBitwiseMask()
    {
        return (1 << this.stencilMaskStack.length) - 1;
    }

    /**
     * Destroys the mask stack.
     *
     */
    destroy()
    {
        super.destroy(this);

        this.stencilMaskStack = null;
    }
}
