using UnityEngine;
using System.Collections;

public class DissolveDirection : MonoBehaviour {

	void Start () {
        Material mat = GetComponent<Renderer>().material;
        float minX, maxX;
        CalculateMinMaxX(out minX, out maxX);
        mat.SetFloat("_MinBorderX", minX);
        mat.SetFloat("_MaxBorderX", maxX);
	}
	
    void CalculateMinMaxX(out float minX, out float maxX)
    {
        Vector3[] vertices = GetComponent<MeshFilter>().mesh.vertices;
        minX = maxX = vertices[0].x;
        for(int i = 1; i < vertices.Length; i++)
        {
            float x = vertices[i].x;
            if (x < minX)
                minX = x;
            if (x > maxX)
                maxX = x;
        }
    }
}
