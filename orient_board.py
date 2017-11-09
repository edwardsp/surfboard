import sys
from paraview.simple import *
paraview.simple._DisableFirstRenderCameraReset()

in_filename = sys.argv[1]
print "STL file in: ", in_filename
out_filename = sys.argv[2]
print "STL file out: ", out_filename
depth = float(sys.argv[3])
print "depth: ", depth
roll = float(sys.argv[4])
print "roll: ", roll

in_basename = in_filename.split('/')[-1]

# create a new 'STL Reader'
surfboard = STLReader(FileNames=[in_filename])

# find source
surfboard_1 = FindSource(in_basename)

# create a new 'Transform'
transform = Transform(Input=surfboard_1)
transform.Transform = 'Transform'

# Properties modified on transform2.Transform
transform.Transform.Translate = [0.0, 0.0, depth]
transform.Transform.Rotate = [roll, 0.0, 0.0]
transform.Transform.Scale = [0.0254, 0.0254, 0.0254]

# save data
SaveData(out_filename, proxy=transform)
