#ifndef EASING_INCLUDED
#define EASING_INCLUDED

//效果查看：http://www.xuanfengge.com/easeing/easeing/
//具体函数查看：http://www.iquilezles.org/apps/graphtoy/
//参考：https://thebookofshaders.com/edit.php#06/easing.frag

#define PI 3.141592653589793
#define HALF_PI 1.5707963267948966

float EaseInSine(float t)
{
	return sin((t - 1.0) * HALF_PI) + 1.0;
}

float EaseOutSine(float t)
{
	return sin(t * HALF_PI);
}

float EaseInOutSine(float t)
{
	return -0.5 * (cos(PI * t) - 1.0);
}

//Quadratic Curve 二次曲线
float EaseInQuad(float t)
{
	return t * t;
}

float EaseOutQuad(float t)
{
	return -t * (t - 2.0);
}

float EaseInOutQuad(float t)
{
	float p = 2.0 * t * t;
	return t < 0.5 ? p : -p + (4.0 * t) - 1.0;
}

//Cubic Curve 三次曲线
float EaseInCubic(float t)
{
	return t * t * t;
}

float EaseOutCubic(float t)
{
	float v = t - 1.0;
	return v * v * v + 1.0;
}

float EaseInOutCubic(float t)
{
	float v1 = 4.0 * t * t * t;
	float v2 = 0.5 * pow(2.0 * t - 2.0, 3.0) + 1.0;
	return t < 0.5 ? v1 : v2;
}

//Quartic Curve 四次曲线
float EaseInQuart(float t)
{
	return pow(t, 4.0);
}

float EaseOutQuart(float t)
{
	return pow(t - 1.0, 3.0) * (1.0 - t) + 1.0;
}

float EaseInOutQuart(float t)
{
	float v1 = 8.0 * pow(t, 4.0);
	float v2 = -8.0 * pow(t - 1.0, 4.0) + 1.0;
	return t < 0.5 ? v1 : v2;
}

//Quintic Curve 五次曲线
float EaseInQuint(float t)
{
	return pow(t, 5.0);
}

float EaseOutQuint(float t)
{
	return (pow(t - 1.0, 5.0)) + 1.0;
}

float EaseInOutQuint(float t)
{
	float v1 = 16.0 * pow(t, 5.0);
	float v2 = 0.5 * pow(2.0 * t - 2.0, 5.0) + 1.0;
	return t < 0.5 ? v1 : v2;
}

//Exponential Curve 指数曲线
float EaseInExpo(float t)
{
	return t == 0.0 ? 0.0 : pow(2.0, 10.0 * (t - 1.0));
}

float EaseOutExpo(float t)
{
	return t == 1.0 ? 1.0 : 1.0 - pow(2.0, -10.0 * t);
}

float EaseInOutExpo(float t)
{
	float v1 = 0.5 * pow(2.0, (20.0 * t) - 10.0);
	float v2 = -0.5 * pow(2.0, 10.0 - (t * 20.0)) + 1.0;
	return t == 0.0 || t == 1.0 
		? t
		: t < 0.5 ? v1 : v2;
}

//Circle Curve 圆形曲线
float EaseInCirc(float t)
{
	return 1.0 - sqrt(1.0 - t * t);
}

float EaseOutCirc(float t)
{
	return sqrt((2.0 - t) * t);
}

float EaseInOutCirc(float t)
{
	float v1 = 0.5 * (1.0 - sqrt(1.0 - 4.0 * t * t));
	float v2 = 0.5 * (sqrt((3.0 - 2.0 * t) * (2.0 * t - 1.0)) + 1.0);
	return t < 0.5 ? v1 : v2;
}

//Back Curve 
float EaseInBack(float t)
{
	return pow(t, 3.0) - t * sin(t * PI);
}

float EaseOutBack(float t)
{
	float v = 1.0 - t;
	return 1.0 - (pow(v, 3.0) - v * sin(v * PI));
}

float EaseInOutBack(float t)
{
	float v = t < 0.5 
		? 2.0 * t 
		: 1.0 - (2.0 * t - 1.0);

	float g = pow(v, 3.0) - v * sin(v * PI);

	return t < 0.5
		? 0.5 * g
		: 0.5 * (1.0 - g) + 0.5;
}

//Elastic Curve 弹性曲线
float EaseInElastic(float t)
{
	return sin(13.0 * t * HALF_PI) * pow(2.0, 10.0 * (t - 1.0));
}

float EaseOutElastic(float t)
{
	return sin(-13.0 * (t + 1.0) * HALF_PI) * pow(2.0, -10.0 * t) + 1.0;
}

float EaseInOutElastic(float t)
{
	float v1 = 0.5 * sin(13.0 * HALF_PI * 2.0 * t) * pow(2.0, 10.0 * (2.0 * t - 1.0));
	float v2 = 0.5 * sin(-13.0 * HALF_PI * ((2.0 * t - 1.0) + 1.0)) * pow(2.0, -10.0 * (2.0 * t - 1.0)) + 1.0;
	return t < 0.5 ? v1 : v2;
}

//Bounce Curve 反弹曲线
//像是有个球在地面上逐渐弹动到静止
float EaseOutBounce(float t)
{
	const float a = 4.0 / 11.0;
	const float b = 8.0 / 11.0;
	const float c = 9.0 / 10.0;

	const float ca = 4356.0 / 361.0;
	const float cb = 35442.0 / 1805.0;
	const float cc = 16061.0 / 1805.0;

	float t2 = t * t;

	return t < a
		? 7.5625 * t2
		: t < b 
			? 9.075 * t2 - 9.9 * t + 3.4
			: t < c
				? ca * t2 - cb * t + cc
				: 10.8 * t * t - 20.52 * t + 10.72;
}

float EaseInBounce(float t)
{
	return 1.0 - EaseOutBounce(1.0 - t);
}

float EaseInOutBounce(float t)
{
	return t < 0.5
		? 0.5 * (1.0 - EaseOutBounce(1.0 - t * 2.0))
		: 0.5 * EaseOutBounce(t * 2.0 - 1.0) + 0.5;
}

#endif