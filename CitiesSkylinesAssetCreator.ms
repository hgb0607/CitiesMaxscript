/*
Cities: Skylines Asset Creation Tool
This script automatically adjusts the pivot point of your asset and exports the 
UVW diffuse map and model to the folder where your SketchUp file was saved.
*/
if selection.count != 1 then
(
	messageBox "You have more than one object in your scene or don't have your asset selected.\n\nPlease delete all layers and make sure your asset is selected." title:"Wrong number of assets"
)
else(
	messageBox "This script will export your texture file and FBX file. The prompt following this message will ask you to select your SketchUp file. Select the file and click 'Open'. \n\nAt the end of the export, you will be prompted to export the FBX file. Clicking 'OK' will export the file correctly." title:"Cities: Skylines Export" beep:false
	f = getOpenFileName caption:"Select your SketchUp file" \
	fullPathName = getFilenamePath f
	fullFileName = getFilenameFile f
	
	asset = selection;	
	obj = $
	x = 90
	y = 0
	z = 0
	absolute = true
	
	p = obj.pos
	
	
	if absolute do
	(
		offsetrot = inverse (obj.rotation * inverse (matrix3 1))
		obj.rotation *= offsetrot
		obj.objectoffsetrot *= offsetrot
	)
	rot = inverse ((eulerangles x y z) as quat)
	obj.rotation *= rot
	obj.objectoffsetrot *= rot
	obj.pos = p
  
	assetD = (asset.max - asset.min);
	pivotX = assetD[1]/2;
	
	extendsBeyond = queryBox "Does your asset extend beyond the x axis?"
	if extendsBeyond == true then (
		pivotY = 0
	)
	if extendsBeyond == false then(
		pivotY = assetD[2]/2;
	)
	
	asset.pivot = [pivotX,pivotY,0];
	
	max modify mode
	modPanel.addModToSelection (Unwrap_UVW ()) ui:on
	$.modifiers[#unwrap_uvw].unwrap.setMapChannel 3
	$.modifiers[#unwrap_uvw].unwrap2.setFreeFormMode on
	$.modifiers[#unwrap_uvw].edit()
	$.modifiers[#unwrap_uvw].flattenmapnoParams();
	
	objs = #($)
	for o in objs do
	(
	o.iNodeBakeProperties.removeAllBakeElements()
	be1 = diffusemap()
	be1.outputSzX = be1.outputSzY = 1024
	be1.fileType = (fullPathName + fullFileName + "_d.png")
	be1.fileName = filenameFromPath be1.fileType
	be1.filterOn = true
	be1.shadowsOn = false
	be1.lightingOn = false
	be1.enabled = true
	o.INodeBakeProperties.addBakeElement be1
	o.INodeBakeProperties.bakeEnabled = true
	o.INodeBakeProperties.bakeChannel = 3
	o.INodeBakeProperties.nDilations = 0
	)
	select objs
	render rendertype:#bakeSelected vfb:off progressBar:true outputSize:[1024,1024]
	
	$.modifiers[#unwrap_uvw].unwrap.setMapChannel 1
	$.modifiers[#unwrap_uvw].unwrap2.setFreeFormMode on
		
	$.material = NULL
	
	newFileName = fullFileName
	newFilePath = fullPathName
	completeFilePath = (fullPathName + fullFileName)
	
	exportFile completeFilePath selectedOnly:false using:FBXEXP

	messageBox "All done! Your files can be found in the same directory as your SketchUp file." title:"Success!!!" beep:false
	

)--end else
