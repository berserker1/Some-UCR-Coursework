# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.27

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Produce verbose output by default.
VERBOSE = 1

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /opt/homebrew/Cellar/cmake/3.27.7/bin/cmake

# The command to remove a file.
RM = /opt/homebrew/Cellar/cmake/3.27.7/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = "/Users/berserker/Desktop/Courses/High Performance Computing/hw2-berserker1/lapack-3.11.0/INSTALL"

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = "/Users/berserker/Desktop/Courses/High Performance Computing/hw2-berserker1/build/INSTALL"

# Include any dependencies generated for this target.
include CMakeFiles/test_zcomplexmult.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include CMakeFiles/test_zcomplexmult.dir/compiler_depend.make

# Include the progress variables for this target.
include CMakeFiles/test_zcomplexmult.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/test_zcomplexmult.dir/flags.make

CMakeFiles/test_zcomplexmult.dir/test_zcomplexmult.f.o: CMakeFiles/test_zcomplexmult.dir/flags.make
CMakeFiles/test_zcomplexmult.dir/test_zcomplexmult.f.o: /Users/berserker/Desktop/Courses/High\ Performance\ Computing/hw2-berserker1/lapack-3.11.0/INSTALL/test_zcomplexmult.f
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --progress-dir="/Users/berserker/Desktop/Courses/High Performance Computing/hw2-berserker1/build/INSTALL/CMakeFiles" --progress-num=$(CMAKE_PROGRESS_1) "Building Fortran object CMakeFiles/test_zcomplexmult.dir/test_zcomplexmult.f.o"
	/opt/homebrew/bin/gfortran $(Fortran_DEFINES) $(Fortran_INCLUDES) $(Fortran_FLAGS) -c "/Users/berserker/Desktop/Courses/High Performance Computing/hw2-berserker1/lapack-3.11.0/INSTALL/test_zcomplexmult.f" -o CMakeFiles/test_zcomplexmult.dir/test_zcomplexmult.f.o

CMakeFiles/test_zcomplexmult.dir/test_zcomplexmult.f.i: cmake_force
	@echo "Preprocessing Fortran source to CMakeFiles/test_zcomplexmult.dir/test_zcomplexmult.f.i"
	/opt/homebrew/bin/gfortran $(Fortran_DEFINES) $(Fortran_INCLUDES) $(Fortran_FLAGS) -E "/Users/berserker/Desktop/Courses/High Performance Computing/hw2-berserker1/lapack-3.11.0/INSTALL/test_zcomplexmult.f" > CMakeFiles/test_zcomplexmult.dir/test_zcomplexmult.f.i

CMakeFiles/test_zcomplexmult.dir/test_zcomplexmult.f.s: cmake_force
	@echo "Compiling Fortran source to assembly CMakeFiles/test_zcomplexmult.dir/test_zcomplexmult.f.s"
	/opt/homebrew/bin/gfortran $(Fortran_DEFINES) $(Fortran_INCLUDES) $(Fortran_FLAGS) -S "/Users/berserker/Desktop/Courses/High Performance Computing/hw2-berserker1/lapack-3.11.0/INSTALL/test_zcomplexmult.f" -o CMakeFiles/test_zcomplexmult.dir/test_zcomplexmult.f.s

# Object files for target test_zcomplexmult
test_zcomplexmult_OBJECTS = \
"CMakeFiles/test_zcomplexmult.dir/test_zcomplexmult.f.o"

# External object files for target test_zcomplexmult
test_zcomplexmult_EXTERNAL_OBJECTS =

test_zcomplexmult: CMakeFiles/test_zcomplexmult.dir/test_zcomplexmult.f.o
test_zcomplexmult: CMakeFiles/test_zcomplexmult.dir/build.make
test_zcomplexmult: CMakeFiles/test_zcomplexmult.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --progress-dir="/Users/berserker/Desktop/Courses/High Performance Computing/hw2-berserker1/build/INSTALL/CMakeFiles" --progress-num=$(CMAKE_PROGRESS_2) "Linking Fortran executable test_zcomplexmult"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/test_zcomplexmult.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/test_zcomplexmult.dir/build: test_zcomplexmult
.PHONY : CMakeFiles/test_zcomplexmult.dir/build

CMakeFiles/test_zcomplexmult.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/test_zcomplexmult.dir/cmake_clean.cmake
.PHONY : CMakeFiles/test_zcomplexmult.dir/clean

CMakeFiles/test_zcomplexmult.dir/depend:
	cd "/Users/berserker/Desktop/Courses/High Performance Computing/hw2-berserker1/build/INSTALL" && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" "/Users/berserker/Desktop/Courses/High Performance Computing/hw2-berserker1/lapack-3.11.0/INSTALL" "/Users/berserker/Desktop/Courses/High Performance Computing/hw2-berserker1/lapack-3.11.0/INSTALL" "/Users/berserker/Desktop/Courses/High Performance Computing/hw2-berserker1/build/INSTALL" "/Users/berserker/Desktop/Courses/High Performance Computing/hw2-berserker1/build/INSTALL" "/Users/berserker/Desktop/Courses/High Performance Computing/hw2-berserker1/build/INSTALL/CMakeFiles/test_zcomplexmult.dir/DependInfo.cmake"
.PHONY : CMakeFiles/test_zcomplexmult.dir/depend

