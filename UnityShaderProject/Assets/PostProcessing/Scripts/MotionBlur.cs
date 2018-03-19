using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class MotionBlur : PostProcessing {
    private RenderTexture mLastRT;

    protected override void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (mat != null)
        {
            if(mLastRT == null || mLastRT.width != src.width || mLastRT.height != src.height)
            {
                DestroyImmediate(mLastRT);
                mLastRT = new RenderTexture(src.width, src.height, 0);
                mLastRT.hideFlags = HideFlags.HideAndDontSave; //渲染纹理完全由我们脚本控制，Unity不用插手
                Graphics.Blit(src, mLastRT);
            }

            mLastRT.MarkRestoreExpected(); //告诉Unity上一帧的纹理不需要清理
            Graphics.Blit(src, mLastRT, mat);
            Graphics.Blit(mLastRT, dest);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

    void OnDisable()
    {
        DestroyImmediate(mLastRT);
    }
}
