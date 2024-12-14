#! /bin/bash

# Ensure the current working directory
initdir=/home/nimbix/data/SU2/
cd $initdir
git clone --branch fix_cornernode_normal https://github.com/su2code/SU2.git
wkdir=/home/nimbix/data/SU2/SU2
cd $wkdir

# Set the initial environmental variables
export MPICC=/opt/JARVICE/openmpi/bin/mpicc
export MPICXX=/opt/JARVICE/openmpi/bin/mpicxx
export CC=$MPICC
export CXX=$MPICXX
export CXXFLAGS="-O2 -funroll-loops -march=native -mtune=native"

# Set the appropriate flags for the desired install options
flags="-Dwith-mpi=enabled -Denable-autodiff=true -Denable-directdiff=true -Denable-mixedprec=true"

# Compile and verify the above flags compiled correctly
build_counter=0

while [ "$build_counter" -le 3 ]; do

	# Keep track of the build attempts to prevent an infinite loop
	((build_counter++))
			
	# Create a directory for meson
	mkdir -p $wkdir/build
	chmod -R 0777 $wkdir
	
	# Compile with meson
	# (note that meson adds 'bin' to the --prefix directory during build)
	./meson.py build $flags --prefix=$initdir/install | tee -a build_log.txt

	# Set environmental variables from meson build
	export SU2_DATA=/home/nimbix/data/SU2/
	export SU2_HOME=/home/nimbix/data/SU2/SU2
	export SU2_RUN=/home/nimbix/data/SU2/SU2/bin
	export PATH=$PATH:$SU2_RUN
	export PYTHONPATH=$PYTHONPATH:$SU2_RUN
	# Set environmental variable to allow multi-node use
	export SU2_MPI_COMMAND="mpirun --hostfile /etc/JARVICE/nodes -np %i %s"

	# Install with ninja
	./ninja -C build install
	
	build_counter=10
	
	break
	
done

if [ $build_counter -eq 4 ]; then

	# Exit the script if build unsuccessful
	echo "Unable to correctly compile SU2 after 3 attempts."
	exit 1

elif [ $build_counter -eq 10 ]; then

    echo "SU2 successfully compiled."
	
fi

# Record a ready status
touch /home/nimbix/data/node_ready_status.txt
