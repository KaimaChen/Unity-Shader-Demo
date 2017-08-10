using UnityEngine;
using System.Collections;

public class Trifox : MonoBehaviour {
    Transform mPlayer;
    Transform mCamera;
    Material mMat;

	void Start () {
        mPlayer = GameObject.FindGameObjectWithTag("Player").transform;
        mCamera = GameObject.FindGameObjectWithTag("MainCamera").transform;
        mMat = GetComponent<MeshRenderer>().material;

        //Texture2D noiseTex = null;
        //NoiseTool.CreatePerlinNoise(ref noiseTex, 256, 256, 10, Vector2.zero);
        //mMat.SetTexture("_MainTex", noiseTex);
    }
	
	void Update () {
        float distance = (mPlayer.position - mCamera.position).magnitude;
        mMat.SetFloat("_PlayerToCameraDistance", distance);
	}
}
