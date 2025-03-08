#pragma once

#include <iostream>
#include <iterator>
#include <sstream>
#include <cstdlib>
#include <cmath>
#include <chrono>
#include <cstring>
#include <limits.h>
#include <fstream>
#include <vector>
#include <cuda_runtime.h>
#include <cuda_gl_interop.h>
#include <assert.h>

#define cudacheck(val)    checkCudaResult((val), #val, __FILE__, __LINE__)

template<typename T>
bool checkCudaResult(T result, char const *const func, const char *const file, int const line) {
		if (result) {
			if (result == cudaErrorCudartUnloading) {
				// Do not try to print error when program is shutting down.
				return false;
			}

			std::stringstream ss;
			ss << "CUDA error at " << file << ":" << line << " code=" << static_cast<unsigned int>(result)
				<< " \"" << func << "\"";
			std::cerr << ss.str() << std::endl;
			return false;
		}
		return true;
}