using UnityEngine;
using System.Collections;

public class Bloom : PostProcessing
{
    public int downSample = 4;
    public int iterations = 4;

    const int EXTRACT_PASS = 0;
    const int GAUSSIAN_HOR_PASS = 1;
    const int GAUSSIAN_VERT_PASS = 2;
    const int BLOOM_PASS = 3;

    protected override void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (mat != null)
        {
            int w = src.width / downSample;
            int h = src.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(w, h, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(src, buffer0, mat, EXTRACT_PASS);
            for (int i = 0; i < iterations; i++)
            {
                RenderTexture buffer1 = RenderTexture.GetTemporary(w, h, 0);

                Graphics.Blit(buffer0, buffer1, mat, GAUSSIAN_HOR_PASS);
                Graphics.Blit(buffer1, buffer0, mat, GAUSSIAN_VERT_PASS);

                RenderTexture.ReleaseTemporary(buffer1);
            }
            mat.SetTexture("_BloomTex", buffer0);
            Graphics.Blit(src, dest, mat, BLOOM_PASS);

            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
