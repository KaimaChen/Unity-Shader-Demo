using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class PostProcessing : MonoBehaviour {
    public Material mat;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(mat != null)
        {
            Graphics.Blit(src, dest, mat);
        }
        else
        {
            Graphics.Blit(src, dest, mat);
        }
    }
}
