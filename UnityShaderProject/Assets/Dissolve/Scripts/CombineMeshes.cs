using UnityEngine;
using System.Collections;

public class CombineMeshes : MonoBehaviour {
    void Awake()
    {
        Combine();
    }

    void Combine()
    {
        MeshFilter[] meshFilters = GetComponentsInChildren<MeshFilter>();       //获取自身和所有子物体中所有MeshFilter组件
        CombineInstance[] combine = new CombineInstance[meshFilters.Length];    //新建CombineInstance数组

        for (int i = 0; i < meshFilters.Length; i++)
        {
            combine[i].mesh = meshFilters[i].sharedMesh;
            combine[i].transform = meshFilters[i].transform.localToWorldMatrix;
            meshFilters[i].gameObject.SetActive(false);
        }

        transform.GetComponent<MeshFilter>().mesh = new Mesh();
        transform.GetComponent<MeshFilter>().mesh.CombineMeshes(combine);       //合并
        transform.gameObject.SetActive(true);
    }
}
