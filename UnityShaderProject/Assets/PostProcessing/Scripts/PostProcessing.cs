using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class PostProcessing : MonoBehaviour {
    public Material mat;

    protected void Start()
    {
        enabled = CheckSupport();
    }

    //[ImageEffectOpaque] //在渲染完不透明物体后马上执行
    protected virtual void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(mat != null)
        {
            Graphics.Blit(src, dest, mat);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

    protected bool CheckSupport()
    {
        if(SystemInfo.supportsImageEffects == false || SystemInfo.supportsRenderTextures == false)
        {
            Debug.LogWarning("This platform dont support postprocssing");
            return false;
        }

        return true;
    }
}
