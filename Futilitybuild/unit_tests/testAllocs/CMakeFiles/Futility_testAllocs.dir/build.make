# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.10

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /home/nfherrin/research/env/gcc-5.4.0/common_tools/cmake-3.10.2/bin/cmake

# The command to remove a file.
RM = /home/nfherrin/research/env/gcc-5.4.0/common_tools/cmake-3.10.2/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/nfherrin/research/MPACT/Futility

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/nfherrin/research/MPACT/Futility/Futilitybuild

# Include any dependencies generated for this target.
include unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/depend.make

# Include the progress variables for this target.
include unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/progress.make

# Include the compile flags for this target's objects.
include unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/flags.make

unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.o: unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/flags.make
unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.o: ../unit_tests/testAllocs/testAllocs.f90
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/nfherrin/research/MPACT/Futility/Futilitybuild/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building Fortran object unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.o"
	cd /home/nfherrin/research/MPACT/Futility/Futilitybuild/unit_tests/testAllocs && /home/nfherrin/research/env/gcc-5.4.0/toolset/mpich-3.2.1/bin/mpif90 $(Fortran_DEFINES) $(Fortran_INCLUDES) $(Fortran_FLAGS) -c /home/nfherrin/research/MPACT/Futility/unit_tests/testAllocs/testAllocs.f90 -o CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.o

unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing Fortran source to CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.i"
	cd /home/nfherrin/research/MPACT/Futility/Futilitybuild/unit_tests/testAllocs && /home/nfherrin/research/env/gcc-5.4.0/toolset/mpich-3.2.1/bin/mpif90 $(Fortran_DEFINES) $(Fortran_INCLUDES) $(Fortran_FLAGS) -E /home/nfherrin/research/MPACT/Futility/unit_tests/testAllocs/testAllocs.f90 > CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.i

unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling Fortran source to assembly CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.s"
	cd /home/nfherrin/research/MPACT/Futility/Futilitybuild/unit_tests/testAllocs && /home/nfherrin/research/env/gcc-5.4.0/toolset/mpich-3.2.1/bin/mpif90 $(Fortran_DEFINES) $(Fortran_INCLUDES) $(Fortran_FLAGS) -S /home/nfherrin/research/MPACT/Futility/unit_tests/testAllocs/testAllocs.f90 -o CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.s

unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.o.requires:

.PHONY : unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.o.requires

unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.o.provides: unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.o.requires
	$(MAKE) -f unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/build.make unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.o.provides.build
.PHONY : unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.o.provides

unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.o.provides.build: unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.o


# Object files for target Futility_testAllocs
Futility_testAllocs_OBJECTS = \
"CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.o"

# External object files for target Futility_testAllocs
Futility_testAllocs_EXTERNAL_OBJECTS =

unit_tests/testAllocs/Futility_testAllocs.exe: unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.o
unit_tests/testAllocs/Futility_testAllocs.exe: unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/build.make
unit_tests/testAllocs/Futility_testAllocs.exe: src/libUtils.a
unit_tests/testAllocs/Futility_testAllocs.exe: src/trilinos_interfaces/libTrilinosUtils.a
unit_tests/testAllocs/Futility_testAllocs.exe: src/libCUtils.a
unit_tests/testAllocs/Futility_testAllocs.exe: unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/nfherrin/research/MPACT/Futility/Futilitybuild/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking Fortran executable Futility_testAllocs.exe"
	cd /home/nfherrin/research/MPACT/Futility/Futilitybuild/unit_tests/testAllocs && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/Futility_testAllocs.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/build: unit_tests/testAllocs/Futility_testAllocs.exe

.PHONY : unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/build

unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/requires: unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/testAllocs.f90.o.requires

.PHONY : unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/requires

unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/clean:
	cd /home/nfherrin/research/MPACT/Futility/Futilitybuild/unit_tests/testAllocs && $(CMAKE_COMMAND) -P CMakeFiles/Futility_testAllocs.dir/cmake_clean.cmake
.PHONY : unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/clean

unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/depend:
	cd /home/nfherrin/research/MPACT/Futility/Futilitybuild && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/nfherrin/research/MPACT/Futility /home/nfherrin/research/MPACT/Futility/unit_tests/testAllocs /home/nfherrin/research/MPACT/Futility/Futilitybuild /home/nfherrin/research/MPACT/Futility/Futilitybuild/unit_tests/testAllocs /home/nfherrin/research/MPACT/Futility/Futilitybuild/unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : unit_tests/testAllocs/CMakeFiles/Futility_testAllocs.dir/depend
