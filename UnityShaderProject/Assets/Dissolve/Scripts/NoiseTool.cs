using UnityEngine;
using System.Collections;

/// <summary>
/// 创建Perlin Noise
/// </summary>
public class NoiseTool {
    public static void CreatePerlinNoise(ref Texture2D noise, int w, int h, float frequency, Vector2 seed)
    {
        float xOrg = seed.x;
        float yOrg = seed.y;
        Color[] randomColor = new Color[w * h];
        int y = 0;
        while (y < w)
        {
            int x = 0;
            while (x < h)
            {
                float xCoord = xOrg + (float)x / (float)w * frequency;
                float yCoord = yOrg + (float)y / (float)h * frequency;
                float sample = PerlinNoise2D(4, 1.0f, xCoord, yCoord) * 0.5f + 0.5f;
                randomColor[y + x * w] = new Color(sample, sample, sample);
                x++;
            }
            y++;
        }
        noise = new Texture2D(w, h, TextureFormat.ARGB32, false, true);
        noise.filterMode = FilterMode.Bilinear;
        noise.wrapMode = TextureWrapMode.Repeat;
        noise.SetPixels(randomColor);
        noise.Apply();
    }

    static float PerlinNoise2D(int octaves, float amp, float x, float y)
    {
        float noise = 0.0f;
        float persistence = 0.5f;
        float lacunarity = 2.0f;
        for (int i = 0; i < octaves; i++)
        {
            float frequency = Mathf.Pow(lacunarity, i);
            float amplitude = Mathf.Pow(persistence, i);
            noise += (InterpolateNoise2D(x * frequency, y * frequency) * amplitude);
        }
        return noise;
    }

    static float InterpolateNoise2D(float x, float y)
    {
        int intergerX = (int)x;
        float fracX = x - intergerX;

        int intergerY = (int)y;
        float fracY = y - intergerY;

        float v1 = SmoothRandomNoise2D(intergerX, intergerY);
        float v2 = SmoothRandomNoise2D(intergerX + 1, intergerY);
        float v3 = SmoothRandomNoise2D(intergerX, intergerY + 1);
        float v4 = SmoothRandomNoise2D(intergerX + 1, intergerY + 1);

        float i1 = Interpolate(v1, v2, fracX);
        float i2 = Interpolate(v3, v4, fracX);

        return Interpolate(i1, i2, fracY);
    }

    static float SmoothRandomNoise2D(int x, int y)
    {
        float corners = (RandomNoise2D(x - 1, y - 1) + RandomNoise2D(x + 1, y - 1) + RandomNoise2D(x - 1, y + 1) + RandomNoise2D(x + 1, y + 1)) / 16.0f;
        float slides = (RandomNoise2D(x, y - 1) + RandomNoise2D(x, y + 1) + RandomNoise2D(x - 1, y) + RandomNoise2D(x + 1, y)) / 8.0f;
        float center = RandomNoise2D(x, y) / 4.0f;
        return corners + slides + center;
    }

    static float RandomNoise2D(int x, int y)
    {
        int n = x + y * 57;
        n = (n << 13) ^ n;
        return (1.0f - ((n * (n * n * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0f);
    }

    static float Interpolate(float a, float b, float t)
    {
        //五次样条线插值
        float f = t * t * t * (t * (t * 6.0f - 15.0f) + 10.0f);
        return a * (1 - f) + b * f;
    }
}
