
--Start of Global Scope---------------------------------------------------------

-- Setting global values
-- luacheck: globals gCAM_IP gRECORD_FOLDER gConfig gCam gViewer
gCAM_IP = '192.168.1.100' -- Must be adapted to match the actual device
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
gViewer = View.create('viewer2D1')

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

---Declaration of the 'main' function as an entry point for the event loop
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

---Definition of the callback function which is registered at the provider
---img contains the image itself
---sensorData contains additional information about the image
local function handleNewImage(img, sensorData)
  -- clear view from earlier pictures
  gViewer:clear()

  -- Create name for the output file
  local ts = SensorData.getTimestamp(sensorData)
  local fileName = gRECORD_FOLDER .. '/record_' .. ts .. '.bmp'

  -- Store the image to a file
  Image.save(img, fileName)
  print("Recorded new Image file '" .. fileName .. "'")

  -- present the image in the image viewer
  gViewer:addImage(img)
  gViewer:present()
end
--Registration of the 'handleNewImage' function to the cameras 'OnNewImage' event
Image.Provider.RemoteCamera.register(gCam, 'OnNewImage', handleNewImage)

--End of Function and Event Scope------------------------------------------------
