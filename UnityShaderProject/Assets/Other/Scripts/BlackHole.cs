using UnityEngine;
using System.Collections;

[RequireComponent(typeof(MeshRenderer))]
public class BlackHole : MonoBehaviour {
    public Transform BlackHoleGO;

    private Material mMat = null;

	void Start () {
        mMat = GetComponent<MeshRenderer>().sharedMaterial;
	}
	
	void Update () {
        Vector3 pos = BlackHoleGO.position;
        mMat.SetVector("_BlackHolePos", new Vector4(pos.x, pos.y, pos.z, 1.0f));
	}
}
