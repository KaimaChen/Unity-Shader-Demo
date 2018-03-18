using UnityEngine;
using System.Collections;

public class GaussianBlur : PostProcessing
{
    public int downSample = 4;
    public int iterations = 4;

    protected override void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(mat != null)
        {
            int w = src.width / downSample;
            int h = src.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(w, h, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(src, buffer0);
            for(int i = 0; i < iterations; i++)
            {
                RenderTexture buffer1 = RenderTexture.GetTemporary(w, h, 0);

                Graphics.Blit(buffer0, buffer1, mat, 0);
                Graphics.Blit(buffer1, buffer0, mat, 1);

                RenderTexture.ReleaseTemporary(buffer1);
            }
            Graphics.Blit(buffer0, dest);

            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
