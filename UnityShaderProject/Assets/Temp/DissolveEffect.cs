/*
Copyright (c) 2015 Kyle Halladay

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

using UnityEngine;
using System.Collections;

public class DissolveEffect : MonoBehaviour 
{
	private float _value = 1.0f;
	private bool _isRunning = false;
	private Material _dissolveMaterial = null;
	public float timeScale = 1.0f;

	void Start()
	{
		float maxVal = 0.0f;
		_dissolveMaterial = GetComponent<Renderer>().material;
		var verts = GetComponent<MeshFilter>().mesh.vertices;
		for (int i = 0; i < verts.Length; i++)
		{
			var v1 = verts[i];
			for (int j = 0; j < verts.Length; j++)
			{
				if (j == i) continue;
				var v2 = verts[j];
				float mag = (v1-v2).magnitude;
				if ( mag > maxVal ) maxVal = mag;
				
			}
		}
		 
		_dissolveMaterial.SetFloat("_LargestVal", maxVal * 0.5f);
	}

	public void Reset()
	{
		_value = 1.0f;
		_dissolveMaterial.SetFloat("_DissolveValue", _value);
	}

	public void TriggerDissolve(Vector3 hitPoint)
	{
		_value = 1.0f;
		_dissolveMaterial.SetVector("_HitPos", (new Vector4(hitPoint.x, hitPoint.y, hitPoint.z, 1.0f)));
		_isRunning = true;
	}

	void Update()
	{
		if (_isRunning && _dissolveMaterial != null)
		{
			_value = Mathf.Max(0.0f, _value - Time.deltaTime*timeScale);
			_dissolveMaterial.SetFloat("_DissolveValue", _value);
		}

	}
}
