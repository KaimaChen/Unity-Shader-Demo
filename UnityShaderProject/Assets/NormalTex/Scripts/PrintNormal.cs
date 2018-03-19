using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class PrintNormal : MonoBehaviour {
    public Material mat;

	void Start () {
	    Camera.main.depthTextureMode = DepthTextureMode.DepthNormals;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (mat != null)
            Graphics.Blit(source, destination, mat);
        else
            Graphics.Blit(source, destination);
    }
}
