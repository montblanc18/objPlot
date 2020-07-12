# objPlot
"objPlot" is a ruby program which draws the position of Sun(yellow sphere), Earth(blue sphere) and Object(red sphere) in 3D image with OpenGL.
A sky blue sphere shows a celestial sphere, and a yellow point shows an observatory you chose.

# Setup
```bash
$ gem install opengl glut glu
```

# How to use
```bash
$ ruby objPlot.rb -r <the ra of object> -d <the dec of object>  
$ ruby objPlot.rb -h  
Usage: objPlot [options]  
    -r, --ra X                       Right Accension [deg]  
    -d, --dec X                      Declination [deg]  
    -s, --stop                       Stop Spin  
```