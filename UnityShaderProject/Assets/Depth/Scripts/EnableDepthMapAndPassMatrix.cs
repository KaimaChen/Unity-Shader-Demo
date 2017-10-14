using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class EnableDepthMapAndPassMatrix : MonoBehaviour {
    public Material mat;

    private Matrix4x4 mLastVP;
    
    private Matrix4x4 VPMatrix
    {
        get { return Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix; }
    }

	void Start () {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
        mLastVP = VPMatrix;
	}

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(mat != null)
        {
            Matrix4x4 currentVP = VPMatrix;
            Matrix4x4 currentInverseVP = VPMatrix.inverse;
            mat.SetMatrix("_CurrentInverseVP", currentInverseVP);
            mat.SetMatrix("_LastVP", mLastVP);
            mLastVP = currentVP;
            Graphics.Blit(source, destination, mat);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
