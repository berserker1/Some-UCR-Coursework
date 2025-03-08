#include<iostream>
#include<vector>
#include<algorithm>
#include<cmath>
#include<cfloat>
using namespace std;

int sign(float a)
{
	if(a < 0)
	{
		return -1;
	}
	if(a > 0)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}
vector<float> naive(float a, float b, float c)
{
	float D = b * b - 4 * a * c;
	vector<float> answer;
	if(D>=0)
	{
		float root_1 = (-b + sqrt(D)) / (2 * a);
		float root_2 = (-b - sqrt(D)) / (2 * a);
		answer.push_back(root_1);
		answer.push_back(root_2);
	}
	return answer;
}
vector<float> advanced(float a, float b, float c)
{
	vector<float> answer;
	// Solving catastrophic cancellation of -b +- sqrt(D)
	// Solving catastrophic cancellation in Discriminant D
	float v1 = 4*a*c;
	float v2 = fma(-(4*a), c, v1);
	float v3 = fma(b, b, -v1);
	float corrected_D = sqrt(v3 + v2);
	if(corrected_D >= 0)
	{
		float r1 = (-b - sign(b) * corrected_D) / (2*a);
		float r2 = c / (r1 * a);
		answer.push_back(r1);
		answer.push_back(r2);
	}
	return answer;
}
int main()
{
	vector<float> answer;
	cout << "Input format:" << endl << "Write values for a, b, c individually, press enter after writing value for each variable" << endl;
	float a, b, c;
	cin >> a;
	cin >> b;
	cin >> c;
	cout << "Written values (in float) are" << endl << "a is " << a << endl << "b is " << b << endl << "c is " << c << endl;
	// Taking case of edge cases of one of the a,b or c == 0
	// NOTE: Unreliable function isnan
	if(isnan(a) || isnan(b) || isnan(c))
	{
		cout << "one of the a or b or c is NaN" << endl;
		exit(1);
	}
	else if(a == 0)
	{
		cout << "EDGE CASES ARE TREATED DIFFERENTLY" << endl;
		if((c == 0) && (b == 0))
		{
			cout << "all coefficients 0" << endl;
			exit(1);
		}
		float r1 = -c / b;
		answer.push_back(r1);
		cout << answer[0] << endl;
		return 0;
	}
	else if(b == 0)
	{
		cout << "EDGE CASES ARE TREATED DIFFERENTLY" << endl;
		int sign_output = sign(a) * sign(c);
		if(sign_output <= 0)
		{
			float r1 = sqrt(-c/a);
			float r2 = -r1;
			answer.push_back(r1);
			answer.push_back(r2);
			cout << answer[0] << " " << answer[1] << endl;
		}
		else
		{
			cout << "roots are complex" << endl;
		}
		return 0;
	}
	else if(c == 0)
	{
		cout << "EDGE CASES ARE TREATED DIFFERENTLY" << endl;
		float r1 = 0;
		float r2 = -b/a;
		answer.push_back(r1);
		answer.push_back(r2);
		cout << answer[0] << " " << answer[1] << endl;
		return 0;
	}
	cout << "First, the naive function" << endl;
	answer = naive(a, b, c);
	if(answer.size() == 0)
	{
		cout << "Roots are not real" << endl;
	}
	else
	{
		cout << answer[0] << " " << answer[1] << endl;
	}
	cout << "Now trying the advance function" << endl;
	answer = advanced(a, b, c);
	if(answer.size() == 0)
	{
		cout << "Roots are not real" << endl;
	}
	else
	{
		cout << answer[0] << " " << answer[1] << endl;
	}
	return 0;
}

