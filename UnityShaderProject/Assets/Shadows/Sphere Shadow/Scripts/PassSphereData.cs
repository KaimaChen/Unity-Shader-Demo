using UnityEngine;
using System.Collections;

public class PassSphereData : MonoBehaviour {
    public Transform sphere;
    public Material sphereShadowMat;
    
	void Update () {
	    if(sphere != null && sphereShadowMat != null)
        {
            sphereShadowMat.SetVector("_SpherePos", sphere.transform.position);
            sphereShadowMat.SetFloat("_SphereRadius", sphere.localScale.x / 2);
        }
	}
}
