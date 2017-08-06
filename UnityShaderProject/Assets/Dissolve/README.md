# 基本原理与实现
主要使用**噪声**和**透明度测试**，从噪声图中读取某个通道的值，然后使用该值进行透明度测试。
主要代码如下：
```
fixed cutout = tex2D(_NoiseTex, i.uvNoiseTex).r;
clip(cutout - _Threshold);
```
> [完整代码点这里](https://github.com/KaimaChen/Unity-Shader-Demo/blob/master/UnityShaderProject/Assets/Dissolve/Shaders/Basic.shader)

![Basic场景](http://upload-images.jianshu.io/upload_images/1278872-439d05e61a27299e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

---
# 边缘颜色
如果纯粹这样镂空，则效果太朴素了，因此通常要在镂空边缘上弄点颜色来模拟火化、融化等效果。
## 1. 纯颜色
第一种实现很简单，首先定义_EdgeLength和_EdgeColor两个属性来决定边缘多长范围要显示边缘颜色；然后在代码中找到合适的范围来显示边缘颜色。
主要代码如下：
```
//Properties
_EdgeLength("Edge Length", Range(0.0, 0.2)) = 0.1
_EdgeColor("Border Color", Color) = (1,1,1,1)
...
//Fragment
if(cutout - _Threshold < _EdgeLength)
	return _EdgeColor;
```
> [完整代码点这里](https://github.com/KaimaChen/Unity-Shader-Demo/blob/master/UnityShaderProject/Assets/Dissolve/Shaders/EdgeColor.shader)

![EdgeColor场景](http://upload-images.jianshu.io/upload_images/1278872-f77062e6239e6821.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 2. 两种颜色混合
第一种纯颜色的效果并不太好，更好的效果是混合两种颜色，来实现一种更加自然的过渡效果。
主要代码如下：
```
if(cutout - _Threshold < _EdgeLength)
{
	float degree = (cutout - _Threshold) / _EdgeLength;
	return lerp(_EdgeFirstColor, _EdgeSecondColor, degree);
}
```
> [完整代码点这里](https://github.com/KaimaChen/Unity-Shader-Demo/blob/master/UnityShaderProject/Assets/Dissolve/Shaders/TwoEdgeColor.shader)

![TwoEdgeColor场景](http://upload-images.jianshu.io/upload_images/1278872-af4c45009b702c43.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 3. 边缘颜色混合物体颜色
为了让过渡更加自然，我们可以进一步混合边缘颜色和物体原本的颜色。
主要代码如下：
```
float degree = saturate((cutout - _Threshold) / _EdgeLength); //需要保证在[0,1]以免后面插值时颜色过亮
fixed4 edgeColor = lerp(_EdgeFirstColor, _EdgeSecondColor, degree);

fixed4 col = tex2D(_MainTex, i.uvMainTex);

fixed4 finalColor = lerp(edgeColor, col, degree);
return fixed4(finalColor.rgb, 1);
```
> [完整代码点这里](https://github.com/KaimaChen/Unity-Shader-Demo/blob/master/UnityShaderProject/Assets/Dissolve/Shaders/BlendOriginColor.shader)

![BlendOriginColor场景](http://upload-images.jianshu.io/upload_images/1278872-7c0cb0798a802ab8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 4. 使用渐变纹理
为了让边缘颜色更加丰富，我们可以进而使用渐变纹理：
![](http://upload-images.jianshu.io/upload_images/1278872-7d5717861196ba68.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
然后我们就可以利用degree来对这条渐变纹理采样作为我们的边缘颜色：
```
float degree = saturate((cutout - _Threshold) / _EdgeLength);
fixed4 edgeColor = tex2D(_RampTex, float2(degree, degree));

fixed4 col = tex2D(_MainTex, i.uvMainTex);

fixed4 finalColor = lerp(edgeColor, col, degree);
return fixed4(finalColor.rgb, 1);
```
> [完整代码点这里](https://github.com/KaimaChen/Unity-Shader-Demo/blob/master/UnityShaderProject/Assets/Dissolve/Shaders/Ramp.shader)

![Ramp场景](http://upload-images.jianshu.io/upload_images/1278872-87afb2123581f284.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

---
# 从特定点开始消融
![DissolveFromPoint场景](http://upload-images.jianshu.io/upload_images/1278872-ab45be0e734ad50d.gif?imageMogr2/auto-orient/strip)
为了从特定点开始消融，我们需要把片元到特定点的距离考虑进clip中。
第一步需要先定义消融开始点，然后求出各个片元到该点的距离（本例子是在模型空间中进行）：
```
//Properties
_StartPoint("Start Point", Vector) = (0, 0, 0, 0) //消融开始点
...
//Vert
//把点都转到模型空间
o.objPos = v.vertex;
o.objStartPos = mul(unity_WorldToObject, _StartPoint); 
...
//Fragment
float dist = length(i.objPos.xyz - i.objStartPos.xyz); //求出片元到开始点距离
```
第二步是求出网格内两点的最大距离，用来对第一步求出的距离进行归一化。这一步需要在C#脚本中进行，思路就是遍历任意两点，然后找出最大距离：
```
public class Dissolve : MonoBehaviour {
	void Start () {
        Material mat = GetComponent<MeshRenderer>().material;
        mat.SetFloat("_MaxDistance", CalculateMaxDistance());
	}
	
    float CalculateMaxDistance()
    {
        float maxDistance = 0;
        Vector3[] vertices = GetComponent<MeshFilter>().mesh.vertices;
        for(int i = 0; i < vertices.Length; i++)
        {
            Vector3 v1 = vertices[i];
            for(int k = 0; k < vertices.Length; k++)
            {
                if (i == k) continue;

                Vector3 v2 = vertices[k];
                float mag = (v1 - v2).magnitude;
                if (maxDistance < mag) maxDistance = mag;
            }
        }

        return maxDistance;
    }
}
```
同时Shader里面也要同时定义_MaxDistance来存放最大距离的值：
```
//Properties
_MaxDistance("Max Distance", Float) = 0
//Pass
float _MaxDistance;
```
第三步就是归一化距离值
```
//Fragment
float normalizedDist = saturate(dist / _MaxDistance);
```
第四步要加入一个_DistanceEffect属性来控制距离值对整个消融的影响程度：
```
//Properties
_DistanceEffect("Distance Effect", Range(0.0, 1.0)) = 0.5
...
//Pass
float _DistanceEffect;
...
//Fragment
fixed cutout = tex2D(_NoiseTex, i.uvNoiseTex).r * (1 - _DistanceEffect) + normalizedDist * _DistanceEffect;
clip(cutout - _Threshold);
```
上面已经看到一个合适_DistanceEffect的效果了，下面贴出_DistanceEffect为1的效果图：
![_DistanceEffect = 1](http://upload-images.jianshu.io/upload_images/1278872-e1ed765dc7e73498.gif?imageMogr2/auto-orient/strip)
这就完成了从特定点开始消融的效果了，不过有一点要注意，消融开始点最好是在网格上面，这样效果会好点。
> [完整代码点这里](https://github.com/KaimaChen/Unity-Shader-Demo/blob/master/UnityShaderProject/Assets/Dissolve/Shaders/FromPoint.shader)

---
# 从特定方向开始消融
![DissolveFromDirectionX场景](http://upload-images.jianshu.io/upload_images/1278872-a9316e8d17528ad7.gif?imageMogr2/auto-orient/strip)
理解了上面的从特定点开始消融，那么理解从特定方向开始消融就很简单了。
下面实现X方向消融的效果。
第一步求出X方向的边界，然后传给Shader：
```
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

```
第二步定义是从X正方向还是负方向开始消融，然后求出各个片元在X分量上与边界的距离：
```
//Properties
_Direction("Direction", Int) = 1 //1表示从X正方向开始，其他值则从负方向
_MinBorderX("Min Border X", Float) = -0.5 //从程序传入
_MaxBorderX("Max Border X", Float) = 0.5  //从程序传入
...
//Vert
o.objPosX = v.vertex.x;
...
//Fragment
float range = _MaxBorderX - _MinBorderX;
float border = _MinBorderX;
if(_Direction == 1) //1表示从X正方向开始，其他值则从负方向
	border = _MaxBorderX;
```
> [完整代码点这里](https://github.com/KaimaChen/Unity-Shader-Demo/blob/master/UnityShaderProject/Assets/Dissolve/Shaders/FromDirection.shader)

---
# Trifox的镜头遮挡消融（未完成）

---
# 常见应用场景
### 角色的产生或消亡
![](https://thumbs.gfycat.com/AnimatedUnderstatedJunebug-size_restricted.gif)
![](http://upload-images.jianshu.io/upload_images/1278872-f8445b5c97e8ef9a.gif?imageMogr2/auto-orient/strip)
### 场景切换
![](http://upload-images.jianshu.io/upload_images/1278872-cad5ded4d6d2239c.gif?imageMogr2/auto-orient/strip)

---
# 项目代码
项目代码在Github上，[点这里查看](https://github.com/KaimaChen/Unity-Shader-Demo/tree/master/UnityShaderProject/Assets/Dissolve)，对你有点用就顺手点个Star吧。

---
# 参考
《Unity Shader 入门精要》
[Tutorial - Burning Edges Dissolve Shader in Unity](http://www.codeavarice.com/dev-blog/tutorial-burning-edges-dissolve-shader-in-unity)
[A Burning Paper Shader](http://kylehalladay.com/blog/tutorial/2015/11/10/Dissolve-Shader-Redux.html)
[Unity案例介绍:Trifox里的遮挡处理和溶解着色器(一)](http://gad.qq.com/program/translateview/7187984)
[《Trifox》中的遮挡处理和溶解着色器技术（下）](http://www.gad.qq.com/article/detail/25821)