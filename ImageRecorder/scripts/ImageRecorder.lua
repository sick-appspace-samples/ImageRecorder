--[[----------------------------------------------------------------------------

  Application Name:
  ImageRecorder

  Summary:
  Recording images from a remote camera sensor to file.

  Description:
  This application connects to a remote camera sensor and records images which are
  then stored on a private AppData folder in the device memory. The remote camera is
  configured to have a frame rate of 5Hz.  The current image is viewed on the webpage.
  This is useful to record a set of images in a real environment for playing later in
  development environment.

  How to run:
  To run this sample a camera sensor has to be connected. The configuration of the camera
  have to be adapted to meet the actual requirements.
  The last 10 images are stored on the device. To retrieve from within AppStudio, the
  location is found in "AppData" tab under "ImageRecorder" in the subfolder "LastRecord".
  It must be noted, that the device memory should not be used for regular, cyclic write
  operations, if possible mounted storage, e.g. an SD card should be used instead.

  See also sample 'ImagePlayer'.
------------------------------------------------------------------------------]]
--Start of Global Scope---------------------------------------------------------

-- Setting global values
-- luacheck: globals gCAM_IP gRECORD_FOLDER gConfig gCam gViewer
gCAM_IP = '192.168.0.100' -- Must be adapted to match the actual device
gRECORD_FOLDER = 'private/LastRecord' -- App private folder on device memory

-- Camera Configuration 1
gConfig = Image.Provider.RemoteCamera.I2DConfig.create()
Image.Provider.RemoteCamera.I2DConfig.setShutterTime(gConfig, 2000)
Image.Provider.RemoteCamera.I2DConfig.setAcquisitionMode( gConfig, 'FIXED_FREQUENCY' )
Image.Provider.RemoteCamera.I2DConfig.setFrameRate(gConfig, 5)
--Additional configurations can be set according to the API

-- Createing a remote Camera
gCam = Image.Provider.RemoteCamera.create()
Image.Provider.RemoteCamera.setType(gCam, 'I2DCAM')
Image.Provider.RemoteCamera.setIPAddress(gCam, gCAM_IP)
Image.Provider.RemoteCamera.setConfig(gCam, gConfig)

-- Creating a viewer instance
gViewer = View.create()
gViewer:setID('viewer2D')

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

--Declaration of the 'main' function as an entry point for the event loop
--@main()
local function main()
  -- Preparing the record folder
  File.del(gRECORD_FOLDER)
  File.mkdir(gRECORD_FOLDER)

  -- Connecting the camera
  local connected = Image.Provider.RemoteCamera.connect(gCam)
  if connected then
    print('Successfully connected to camera.')
  else
    print('Camera not found.')
  end
  print('Starting image acquisition...')
  --Taking burst of 5 images
  local success = Image.Provider.RemoteCamera.start(gCam, 5)

  if not success then
    print('Could not start image acquisition from camera.')
  else
    print('Image acquisition from camera started.')
  end
end
--The following registration is part of the global scope which runs once after startup
--Registration of the 'main' function to the 'Engine.OnStarted' event
Script.register('Engine.OnStarted', main)

-- Definition of the callback function which is registered at the provider
-- img contains the image itself
-- sensorData contains additional information about the image
local function handleNewImage(img, sensorData)
  -- Create name for the output file
  local ts = SensorData.getTimestamp(sensorData)
  local fileName = gRECORD_FOLDER .. '/record_' .. ts .. '.bmp'

  -- Store the image to a file
  Image.save(img, fileName)
  print("Recorded new Image file '" .. fileName .. "'")

  -- present the image in the image viewer
  View.view(gViewer, img)
end
--Registration of the 'handleNewImage' function to the cameras 'OnNewImage' event
Image.Provider.RemoteCamera.register(gCam, 'OnNewImage', handleNewImage)

--End of Function and Event Scope------------------------------------------------
