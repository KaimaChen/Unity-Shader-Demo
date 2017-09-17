using UnityEngine;
using System.Collections;

public class PassPlaneMatrix : MonoBehaviour {
    public Renderer planeRenderer;

    private Material mMat;

	void Start () {
        mMat = GetComponent<Renderer>().sharedMaterial;
	}
	
	void Update () {
	    if(planeRenderer != null && mMat != null)
        {
            mMat.SetMatrix("_World2Ground", planeRenderer.worldToLocalMatrix);
            mMat.SetMatrix("_Ground2World", planeRenderer.localToWorldMatrix);
        }
	}
}
