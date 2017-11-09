#!/bin/sh
cd ${0%/*} || exit 1    # Run from this directory

surfboardUrl="$1"
depth=$2
roll=$3
numProcs=$4
numberOfIterations=$5
mpiArgs=$6

wget "$surfboardUrl" -O - > constant/triSurface/board-original.stl
pvpython ./orient_board.py constant/triSurface/board-original.stl constant/triSurface/board.stl $depth $roll
sed -i "s/__NUMPROCS__/$numProcs/g" system/decomposeParDict
sed -i "s/__ENDTIME__/$numberOfIterations/g" system/controlDict

# Source tutorial run functions
. $WM_PROJECT_DIR/bin/tools/RunFunctions

runApplication surfaceFeatureExtract

runApplication blockMesh

for i in 1 2 3
do
    runApplication -s $i \
        topoSet -dict system/topoSetDict.${i}

    runApplication -s $i \
        refineMesh -dict system/refineMeshDict -overwrite
done

runApplication snappyHexMesh -overwrite

rm -rf 0
cp -r 0.orig 0

runApplication setFields

runApplication decomposePar

mpirun -np $numProcs $mpiArgs renumberMesh -parallel -overwrite >log.renumberMesh 2>&1

mpirun -np $numProcs $mpiArgs $(getApplication) -parallel >log.$(getApplication) 2>&1

runApplication reconstructPar

#------------------------------------------------------------------------------
