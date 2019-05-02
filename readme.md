## ImageRecorder
Recording images from a remote camera sensor to file.
### Description
This application connects to a remote camera sensor and records images which are
then stored on a private AppData folder in the device memory. The remote camera is
configured to have a frame rate of 5Hz.  The current image is viewed on the webpage.
This is useful to record a set of images in a real environment for playing later in
development environment.
### How to Run
To run this sample a camera sensor has to be connected. The configuration of the camera
have to be adapted to meet the actual requirements.
The last 10 images are stored on the device. To retrieve from within AppStudio, the
location is found in "AppData" tab under "ImageRecorder" in the subfolder "LastRecord".
It must be noted, that the device memory should not be used for regular, cyclic write
operations, if possible mounted storage, e.g. an SD card should be used instead

### Topics
Remote-Device, Acquisition, Recording, Sample, SICK-AppSpace