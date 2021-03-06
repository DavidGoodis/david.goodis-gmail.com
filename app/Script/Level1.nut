 /*
	File: Script/Level1.nut
	Author: DG
*/

/*Include("Script/gui.nut")
Include("Script/globals.nut")
*/

Include("Script/pattern.nut")

usePad   <- 1

/*!
	@short	ss1_9_tr_ss1_9_tr
	@author	DG
*/

gLifes 			<- 10
gLifesMax		<- 10
gLifesWindow	<- 0
gScore			<- 0
g_ui_IDs		<- 0
gShipCanBarrel	<- 1
game_over		<- 0
//gFFON			<- 0
gFFenergy		<- 100
lifeBar			<- 0
low_dt_compensation <-0
targetList		<- 0
pause			<- 0

//Engine 
g_timer		  <- 0.0
g_clock_scale <- 0.0

class	Level1
{
	
//=== number of ennemies generated in one wave
	max_ennemies	= 20
	base_item		= 0
	new_item		= 0
	gShipCanBarrel	= 1
	channel_music	= 0
	helpLabel		= 0
	helpLabel2		= 0
	helpCounter		= 0
	opa				= 1
//=== ui ===//
	ui				= 0
	scoreWindow     = 0
	boostWindow		= 0
	oneupWindow		= 0
	lblEnergy		= 0
	lblGameOver		= 0
	lblRetry		= 0
	lblQuit			= 0
	lblGetReady		= 0
	lblPause		= 0
	lblPauseQuit	= 0
	lblPauseResume	= 0
	lblLoading		= 0
	energyBar		= 0
	lblDestr		= 0
//=== debug ===//
	lblDbgEnemies	= 0
	lblDbgTargetList = 0
	lblDbgBiru		= 0
	lblDbgSlice		= 0
//===  ===//
	Xbutton			= 84
	phase			= 0
	timer			= g_clock
	seqTimer		= g_clock
	boost			= 0
	boostON			= 0
	rockON			= false
//=== score ===
	scorTimer		= 0
	oneupScore		= 5000
	scoreCounter	= 1
//=== city ===
	c_terrain_height	= -100
	wait					= 0
	citigenCount		= 0
	biruArray			= []
//=== tunnel ===
	arrTunnel		= []
	maxTunnelSlice		= 10
	tunnelSliceCol 		= 0
	tunnelSliceMesh		 = 0
	tunnelScale				= 0
//=== cubes ===
	beveled_cube	= 0
	destroyed		= 0
//=== walls ===
	wallTimer		= 0
	wallFreq			= 0
	wallPieces		= 0

//=== grid ====
//	gridArLoc		= [] //Array of locations. size = gridDendity*gridDensity
	gridArPat1		= []
	objVelocity		= 4

	patobjs			= []
	to				= []

	objCount			= 0
	itemCount			= 0

	currentEntityCount	= 0
	baseItem			= 0

	patTimer		= 0
	frameTimer		= 0
//	patWait			= 1.8
	patWait			= 1
	seq				= 1

	beatScore		= 0
	scoreLocked		= false

// Sounds
	sounds			= []
	channels			= []
	syncBit			= 0.4285
	syncBitTimer	= 0

// colors
	limitCol1 = Vector(0.09,0.57,1,0.3)
//	limitCol2 = Vector(0.38,0.74,0.94,0.3)
	limitCol2 = Vector(0.09,0.57,1,0.3)
	limitCol3 = Vector(1,1,1,0.3)
	limitCol4 = Vector(1,1,1,0.3)
	limitColF = Vector(0.38,0.74,0.94,0.3)
	limitColB = Vector(1,1,1,0.3)

	worldLimit	= { min=Vector(0,0,0), max=Vector(0,0,0)}


//	========================================================================================================
	function	ComputeLowDeltaFrameCompensation()
//	========================================================================================================
	{
		//	low_dt_compensation is a factor (btw 0.0 and 1.0)
		//	that you might need when apply forces, impulses & torques.
		low_dt_compensation = Clamp(1.0 / (60.0 * g_dt_frame), 0.0, 1.0)

	}

//	========================================================================================================
	function	UpdateLifes(lifes)
//	========================================================================================================
	{
//		TextSetText(gLifesWindow[1], lifes.tostring())
		WindowSetSize(lifeBar,gLifes*25,20)
	}

//	========================================================================================================
	function	Pause(scene)
//	========================================================================================================
	{
		if (!pause)
		{
			g_clock_scale = SceneGetClockScale(scene)
			SceneSetClockScale(scene, 0.0)
//			EngineSetClockScale(g_engine, 0.0)
			pause = true
			SpriteSetOpacity(lblPause[0], 0.8)
			SpriteSetOpacity(lblPauseQuit[0], 0.8)
			SpriteSetOpacity(lblPauseResume[0], 0.8)

			local s  = ResourceFactoryLoadSound(g_factory, "data/pause.wav")
			MixerSoundStart(g_mixer, s)
		}
		else
		{
			SceneSetClockScale(scene, g_clock_scale)
//			EngineSetClockScale(g_engine, g_clock_scale)
			pause = false
			SpriteSetOpacity(lblPause[0],0)
			SpriteSetOpacity(lblPauseQuit[0], 0)
			SpriteSetOpacity(lblPauseResume[0], 0)
			local s  = ResourceFactoryLoadSound(g_factory, "data/resume.wav")
			MixerSoundStart(g_mixer, s)
		}
	}


//	========================================================================================================
	function	GameOver(scene)
//	========================================================================================================
	{
			game_over = 1				
			SceneSetClockScale(scene, 0.0)
			SpriteSetOpacity(lblGameOver[0],0.8)
			SpriteSetOpacity(lblRetry[0],0.8)
			SpriteSetOpacity(lblQuit[0],0.8)
	}


//	========================================================================================================
	function	SpawnItem(scene, item, spawn_loc,spawn_scale, spawn_rot, spawn_dir, spawn_tor)
//	========================================================================================================
	{
		local spawned = SceneDuplicateItem(scene, item)

		ItemSetupScript(spawned)
//		ItemSetup(spawned)
		ItemRenderSetup(spawned, g_factory)
		SceneSetupItem(scene, spawned)
		ItemPhysicResetTransformation(spawned, spawn_loc, spawn_rot)
		ItemSetScale(spawned, spawn_scale)
		ItemApplyLinearImpulse(spawned, spawn_dir)
//		ItemApplyTorque(spawned, spawn_tor)
//		ItemSetLinearVelocity(spawned, Vector(0,0,-1))
		ItemSetAngularVelocity(spawned,Vector(1,0,0))

		return(spawned)
	}


//	========================================================================================================
	function	GotAchievement(scene, achievement)
//	========================================================================================================
	{

		if (achieved.find(achievement) == null)
		{
			local tex 		= ResourceFactoryLoadTexture(g_factory, "Tex/achievement_" + achievement + ".png")
			local achiSprit = UIAddNamedSprite(SceneGetUI(scene), "spr", tex, 500, -200, TextureGetWidth(tex), TextureGetHeight(tex))
			WindowSetCommandList(achiSprit, "toposition 2,500,50; toposition 5,500,50; toposition 2,500,-200;")
			achieved.append(achievement)
		} else return
	}


//	========================================================================================================
	function	GenerateCity(scene, xmin, xmax, ymin, ymax, xcount, ycount, opacity)
//	========================================================================================================
	{
		local new_biru
		local street_width_ratio = 2 //street will be 1/street_width_ratio of a building's side

		//computes the sides of a building
		local x = street_width_ratio*(xmax-xmin)/(5*xcount-1)
		local y = street_width_ratio*(ymax-ymin)/(5*ycount-1)

		for(local i=ymin;i<ymax;i+=5*y/street_width_ratio)
			for(local j=xmin;j<xmax;j+=5*x/street_width_ratio)
				if ((j < -100) || (j > 100))
			{
				if (Rand(1,10).tointeger() == 5)
//						MaterialSetDiffuse(GeometryGetMaterialFromIndex(ItemGetGeometry(new_biru), 0), Vector(255,0,0,255))
					new_biru = SceneDuplicateItem(scene, SceneFindItem(scene,"Building-red"))
				else
					new_biru = SceneDuplicateItem(scene, SceneFindItem(scene,"Building"))

				ItemSetupScript(new_biru)
				ItemRenderSetup(new_biru, g_factory)

				local scalex = x/(ItemGetMinMax(new_biru).max.x - ItemGetMinMax(new_biru).min.x)
				local scaley = y/(ItemGetMinMax(new_biru).max.y - ItemGetMinMax(new_biru).min.y)
				local scalez = Rand(10,200)
				ItemSetScale(new_biru, Vector(scalex,scaley,scalez))
				ItemSetPosition(new_biru, Vector(Mtr(j), Mtr(c_terrain_height+scalez), Mtr(i)))
				ItemSetOpacity(new_biru, opacity)
//				ItemSetCommandList(new_biru, "loop; toscale 1," + scalex + "," + scaley + "," + scalez*1.5 + "; toscale 1," + scalex + "," + scaley + "," + scalez + "; next;")
				biruArray.append(new_biru)
			} 

		return(y)
	}

//	========================================================================================================
	function	CleanCity(scene)
//	========================================================================================================
	{
		foreach(id, biru in biruArray)
			if (ItemGetPosition(biru).z < -100)
			{
				SceneDeleteItem(scene, biru)
				biruArray.remove(id)
			}
	}

//	========================================================================================================
	function	GenerateTunnelSlice(scene, tunnelArray, scale)
//	========================================================================================================
	{
//		if (tunnelArray.len() < maxTunnelSlice)
		{
			local lastSlice 	= tunnelArray.top()
			local lastSlicePos 	= ItemGetPosition(lastSlice)
//			print("ItemGetPosition(lastSlice).z =" + lastSlicePos.z)

			local sliceCol = SceneDuplicateItem(scene, lastSlice)
//			local sliceCol = SceneDuplicateItem(scene, tunnelSliceCol)
			local sliceMesh = SceneDuplicateItem(scene,tunnelSliceMesh)
			ItemSetParent(sliceMesh, sliceCol)
			ItemSetScript(sliceCol, "Script/tunnelCol.nut", "tunnelCol")
			ItemSetupScript(sliceCol)
			ItemRenderSetup(sliceCol, g_factory)
			ItemRenderSetup(sliceMesh, g_factory)
			SceneSetupItem(scene, sliceCol)
			SceneSetupItem(scene, sliceMesh)

			ItemSetPosition(sliceMesh, Vector(0,0,500))

			local mm 			= ItemGetMinMax(sliceMesh)

			print("A.ItemGetPosition(sliceCol).z =" + ItemGetPosition(sliceCol).z + "mm.min=" + mm.min.z + "mm.max=" + mm.max.z)
			ItemPhysicResetTransformation(sliceCol, Vector(lastSlicePos.x, lastSlicePos.y, lastSlicePos.z + scale*(mm.max.z - mm.min.z)), Vector(0,0,0))
			print("B.ItemGetPosition(sliceCol).z =" + ItemGetPosition(sliceCol).z)

			foreach(id, slice in tunnelArray)
				print("Right before append->ID=" + id + "::" + ItemGetPosition(slice).z)
		
			tunnelArray.append(sliceCol)

//			foreach(id, slice in tunnelArray)
//				print("Right after append->ID=" + id + "::" + ItemGetPosition(slice).z)

		}

		return(tunnelArray)
	}


//	========================================================================================================
	function	CleanTunnel(scene, tunnelArray)
//	========================================================================================================
	{
		foreach(id, slice in tunnelArray)
		{
//			print("Before deletion->ID=" + id + "::" + ItemGetPosition(slice).z)
			if (ItemGetWorldPosition(slice).z < 0)
			{
				//delete mesh
				SceneDeleteItem(scene, ItemGetChild(slice,"TunnelDivisionSolid"))
				//delete colshapes
				SceneDeleteItem(scene, slice)
				tunnelArray.remove(id)
//				print("--->delete::" + id + "::" + ItemGetPosition(slice).z)
			}
		}
	}

//	========================================================================================================
	function	SpawnWall(refi, scene, nx, ny)
//	========================================================================================================
	{
		local refix = ItemGetMinMax(refi).max.x - ItemGetMinMax(refi).min.x
		local refiy = ItemGetMinMax(refi).max.y - ItemGetMinMax(refi).min.y
		local scale_ = ItemGetScale(refi)
		local startx = -(refix*nx*scale_.x)/2
		local starty = -(refiy*ny*scale_.y)/2

		for(local j=0;j<ny;j++)
			for(local i=0;i<nx;i++)
			{
				local cub_ = SceneDuplicateItem(scene, refi)
				ItemSetScript(cub_, "Script/cube2.nut" , "Cube2")
				ItemSetupScript(cub_)
				ItemRenderSetup(cub_, g_factory)
				SceneSetupItem(scene, cub_)

				wallPieces.append(cub_)

				ItemPhysicResetTransformation(cub_, Vector(startx+i*refix*scale_.x, starty+j*refiy*scale_.y, 4000.0), Vector(0,0,0))
			}
	}

//	========================================================================================================
	function	CleanWall(scene)
//	========================================================================================================
	{
		foreach(id, piece in wallPieces)
			if (ItemGetWorldPosition(piece).z < -100)
			{
				//delete item
				SceneDeleteItem(scene, piece)

				wallPieces.remove(id)
			}
	}



//	========================================================================================================
	function	PushPattern(scene, patternID, tableOfItems)
//	========================================================================================================
	{
		local pattern = []
		local obj = SceneAddObject(scene, "PatternGravityCenter" + patternID)
		
		ItemSetPosition(obj, Vector(0,0,g_spawnZ))

		foreach(id, loc in g_patlocs[patternID])
		{
			local dot = g_patfs[patternID][id]
 	  		if ( dot.w != 0 ) //The dot is not void
			{

				local new_item = g_availCubesPool.pop() //removes and return the last value from the back of the array of available cubes
				local key = dot.x + "_" + dot.y + "_" + dot.z + "_" + dot.w

				ItemRenderSetup(new_item, g_factory)
		 		SceneSetupItem(scene, new_item)

				local mat = GeometryGetMaterialFromIndex(g_geo[key.tostring()], 0)
				local c = MaterialGetSelf(mat)

				ObjectSetGeometry(ItemCastToObject(new_item), g_geo[key.tostring()])

				itemCount++
				SceneItemActivate(scene, new_item, true)
				ItemCollisionActivate(new_item, false)

				ItemGetScriptInstanceFromClass(new_item, "Cube").savedSelf = Vector(dot.x, dot.y, dot.z)
				
				//switch( RoundFloatValue(dot.w*10, 1)) //depending on the alpha of the pixel
				switch( floor(dot.w*10))
				{
					case 0: ItemSetCommandList(new_item, "nop " + 0.005*id + "; loop; toscale " + syncBit*2 + ",1,1,1; toscale " + syncBit*2 + ",0,0,0; next;")
					case 1:	ItemSetCommandList(new_item,"loop; offsetposition " + syncBit + ",0,"  + tileSize*5 + ",0; offsetposition " + syncBit + ",0,-" + tileSize*5 + ",0;  next;"); break; // up
					case 2:	ItemSetCommandList(new_item,"loop; offsetposition " + syncBit + ",0,-"  + tileSize + ",0; offsetposition " + syncBit + ",0," + tileSize + ",0;  next;"); break; // down
					case 3:	ItemSetCommandList(new_item,"loop; offsetposition " + syncBit + ",-"  + tileSize + ",0,0; offsetposition " + syncBit + "," + tileSize + ",0,0;  next;"); break; // left
					case 4:	ItemSetCommandList(new_item,"loop; offsetposition " + syncBit + ","  + tileSize + ",0,0; offsetposition " + syncBit + ",-" + tileSize + ",0,0;  next;"); break; // right
					case 5:	ItemSetCommandList(new_item,"loop; offsetposition " + syncBit + ",0,-"  + tileSize*6 + ",0; nop " + syncBit + "; offsetposition " + syncBit + ",0,-" + tileSize*6 + ",0; nop " + syncBit + "; offsetposition " + syncBit + ",0," + tileSize*6 + ",0; nop " + syncBit + "; offsetposition " + syncBit + ",0," + tileSize*6 + ",0;  next;"); break; // down
					case 6:	ItemSetCommandList(new_item,"loop; offsetposition " + syncBit + ",0,"  + tileSize*6 + ",0; nop " + syncBit + "; offsetposition " + syncBit + ",0," + tileSize*6 + ",0; nop " + syncBit + "; offsetposition " + syncBit + ",0,-" + tileSize*6 + ",0; nop " + syncBit + "; offsetposition " + syncBit + ",0,-" + tileSize*6 + ",0;  next;"); break; // down
					case 8:	ItemSetCommandList(new_item,"loop; offsetposition " + syncBit*2 + ","  + tileSize*9 + ",0,0; offsetposition " + syncBit*2 + ",-" + tileSize*9 + ",0,0;  next;"); break; // right
//					case 10: ItemSetCommandList(new_item, "nop " + 0.005*id + "; loop; toscale " + syncBit*2 + ",1,1,1; toscale " + syncBit*2 + ",0,0,0; next;")
					default: break;
				}

//				ItemSetCommandList(new_item , "loop; torotation " + syncBit + ",0,0," + 90 + ";nop " + syncBit + ";torotation " + syncBit + ",0,0," + 180 + ";nop " + syncBit + ";torotation " + syncBit + ",0,0," + 270 + ";nop " + syncBit*2 + ";torotation " + syncBit*2 + ",0,0," + 360 + ";nop " + syncBit*2 + ";next;")

				ItemSetPosition(new_item, loc)

				pattern.append(new_item)

				ItemSetParent(new_item, obj)
			}
		}

//		ItemSetCommandList(obj, "loop; torotation " + syncBit + ",0,0," + 90 + ";nop " + syncBit + ";torotation " + syncBit + ",0,0," + 180 + ";nop " + syncBit + ";torotation " + syncBit + ",0,0," + 270 + ";nop " + syncBit*2 + ";torotation " + syncBit*2 + ",0,0," + 360 + ";nop " + syncBit*2 + ";next;")

		//Add the parent object to the array of parents
		local firstitem = g_patlocs[patternID][0]
		local l = g_patlocs[patternID].len()-1
		local lastitem = g_patlocs[patternID][l]
		patobjs.append(Pattern(obj,pattern,lastitem.x-firstitem.x,firstitem.y-lastitem.y))
		
		//Add the array of new items to the array of item arrays
		tableOfItems.append(pattern)

		return(tableOfItems)
	}


//	========================================================================================================
	function	OnUpdate(scene)
//	========================================================================================================
	{
//		ComputeLowDeltaFrameCompensation()

		local	keyboard 	= GetKeyboardDevice(),
				pad			= GetInputDevice("xinput0"),
				padlt 		= DeviceInputValue(pad, DeviceAxisLT)

		local posX = WindowGetPosition(lblGetReady[0]).x
		local posY = WindowGetPosition(lblGetReady[0]).y

		if (DeviceKeyPressed(pad, keyBack) || DeviceKeyPressed(keyboard, KeyPause ))
			Pause(scene)

		if (DeviceKeyPressed(keyboard, KeyTab))
			if (debug)
				debug = false
			else
				debug = true

		frameTimer	= SystemGetClock()
		if (phase == 0)
			while( TickToSec(SystemGetClock() - frameTimer) < g_dt_frame )
				if (currentEntityCount < g_maxEntities)
				{
					local new_item = SceneDuplicateItem(scene, baseItem)

					itemCount++

					g_availCubesPool.append(new_item)

					ItemRenderSetup(new_item, g_factory)
		 			SceneSetupItem(scene, new_item)
					ItemActivate(new_item, false)

					currentEntityCount++
					TextSetText(lblLoading[1], "Loading... " + currentEntityCount*100/g_maxEntities + "%")
					print("Loading... " + currentEntityCount*100/g_maxEntities + "%")
				}
				else
					phase = 1

		if (phase == 1 )
		{
			SpriteSetOpacity(lblLoading[0], 0.0)
		}

		//compute boost
		local usePad
		if (!("usePad" in getroottable()))
			usePad = 1
		if ( (padlt > 0.0) || (usePad&&DeviceIsKeyDown(keyboard, KeySpace)) )
			{
				boostON = 1
				GotAchievement(scene, "boost")
			}
		else
			boostON = 0

		//visual feedback of boost
		if (boostON)
			if (padlt > 0.0)
				{ boost = padlt*30; WindowSetOpacity(boostWindow[0],1); TextSetText(boostWindow[1], "BOOST X"+abs(padlt*10)) }
			else
				{ boost += 0.1; WindowSetOpacity(boostWindow[0],1) }
		else
			{ boost += -0.6; WindowSetOpacity(boostWindow[0],0) }
		boost = Clamp(boost,0,objVelocity)

		if (phase == 1)
		{

			UpdateLifes(gLifes)

			if ((gLifes < 5) && (gLifes > 0))
			{
				SceneGetScriptInstanceFromClass(scene,"bgblink").step = 10/gLifes
				SceneGetScriptInstanceFromClass(scene,"bgblink").active = true
			}
			else SceneGetScriptInstanceFromClass(scene,"bgblink").active = false

			// Pattern generation
//			if (TickToSec(g_clock-patTimer) >= patWait )
			if (TickToSec(g_clock-patTimer) >= syncBit*4 )
				switch(seq)
				{
					case 1: g_usedCubesPool = PushPattern(scene, 0, g_usedCubesPool); seq = 2; patTimer = g_clock; break;
					case 2: g_usedCubesPool = PushPattern(scene, 1, g_usedCubesPool); seq = 3; patTimer = g_clock; break;
					case 3: g_usedCubesPool = PushPattern(scene, 2, g_usedCubesPool); seq = 4; patTimer = g_clock; break;
					case 4: g_usedCubesPool = PushPattern(scene, 3, g_usedCubesPool); seq = 5; patTimer = g_clock; break;
					case 5: g_usedCubesPool = PushPattern(scene, 4, g_usedCubesPool); seq = 6; patTimer = g_clock; break;
					case 6: g_usedCubesPool = PushPattern(scene, 5, g_usedCubesPool); seq = 7; patTimer = g_clock; break;
					case 7: g_usedCubesPool = PushPattern(scene, 6, g_usedCubesPool); seq = 8; patTimer = g_clock; break;
					case 8: g_usedCubesPool = PushPattern(scene, 7, g_usedCubesPool); seq = 9; patTimer = g_clock; break;
					case 9: g_usedCubesPool = PushPattern(scene, 8, g_usedCubesPool); seq = 10; patTimer = g_clock; break;
					case 10: g_usedCubesPool = PushPattern(scene, 9, g_usedCubesPool); seq = 1; patTimer = g_clock; break;
				}

			objCount = patobjs.len()

			//Activate collisions on the first object
			if (patobjs.len()!= 0)
			{
				local cubes = ItemGetChildList(patobjs[0].object)
				foreach(idx, item in cubes)
					ItemCollisionActivate(item, true)
			}


			foreach(idx,pattern in patobjs)
			{
				local children = ItemGetChildList(pattern.object)

				local r = ItemGetRotation(pattern.object)
				local p = ItemGetWorldPosition(pattern.object)

//				print("IDX=" + idx + "::Z=" + ItemGetWorldPosition(obj).z)

				local cpos = ItemGetWorldPosition(SceneGetCurrentCamera(scene))

				local rot = 0.02
				switch(objCount)
				{
					case 2: rot = -rot
					case 3: rot = rot*1.5
					case 5: rot = -0.02
				}

				//Transform pattern parrent object
				if (TickToSec(g_clock-SyncTimer) >= syncBit )
				{
//					ItemSetRotation(obj, Vector(r.x,r.y,r.z-(Deg(90)*g_dt_frame/syncBit)))
//					ItemSetPosition(obj, Vector(p.x,p.y,p.z))
					ItemSetPosition(pattern.object, Vector(p.x,p.y,p.z-(objVelocity-boost)*g_dt_frame*60))
				}
				else
				{
//					ItemSetRotation(obj, Vector(r.x,r.y,r.z+Deg(3)))
					ItemSetPosition(pattern.object, Vector(p.x,p.y,p.z-(objVelocity-boost)*g_dt_frame*60))
				}
				if (TickToSec(g_clock-SyncTimer) >= syncBit*2)
					SyncTimer = g_clock


				//Collision detection
/*
				if (idx == 0) //only on the first visible pattern
					foreach(ic, child in children)
					{
						local childp = ItemGetWorldPosition(child)
						local col =	SceneCollisionRaytrace(g_scene,childp,Vector(0,0,-1),-1,CollisionTraceAll,Mtr(spawnZ))
						if ((col.hit) && (ItemGetName(col.item) == "Spacecraft"))
						{
							//Set the item as being in the ship's trajectory
							ItemGetScriptInstanceFromClass(child, "Cube").willHit = 1
						}
						else
							ItemGetScriptInstanceFromClass(child, "Cube").willHit = 0
					}
*/


				//delete object and all his children if behind camera
				local r = ItemGetRotation(pattern.object)
				local p = ItemGetWorldPosition(pattern.object)

				//If we pass the object
				if (p.z <= 0) //the obj passes us (or we pass the obj)
					if (!scoreLocked)
					{
						scoreLocked = true
						beatScore = RoundFloatValue(beatScore+1, 1)
					}


				//Remove the object and recycle the cubes once behind camera
				if (p.z < -50)
//				if (p.z < ItemGetWorldPosition(SceneGetCurrentCamera(scene)).z)	
				{
					scoreLocked = false
//					print("IDX=" + idx + "::Z=" + ItemGetWorldPosition(obj).z)

					foreach(ic, child in children)
					{
//						print("--->Child " + ic + "::Z=" + ItemGetWorldPosition(child).z)
						g_availCubesPool.append(child)
						ItemResetCommandList(child)
						SceneItemActivate(scene, child, false)
//						SceneDeleteItem(scene, child)
					}

					SceneDeleteObject(scene,pattern.object)
					patobjs.remove(idx)
//					to.remove(idx)

					local itemArray = g_usedCubesPool[idx]
					itemCount -= itemArray.len()
					g_usedCubesPool[idx].clear()
					g_usedCubesPool.remove(idx)
				}
			}

/*
			//Code for individual block and collision detection
			foreach(idx1,enemyGrp in g_usedCubesPool)
				foreach(idx2,enemy in enemyGrp)
				{
   					local wp = ItemGetWorldPosition(enemy)
   					local ri = ItemGetRotation(enemy)
					local r = ItemGetOpacity(enemy)
					local opa = Clamp(wp.z/g_spawnZ,0,1)+0.1

					local offset = Deg(90)*g_dt_frame/syncBit
					if (ItemGetName(enemy) == "BeveledCubeRed")
					if (TickToSec(g_clock-SyncTimer) >= syncBit )
					{
//						ItemSetPosition(enemy, Vector(wp.x,wp.y,wp.z + g_dt_frame*60))
						ItemSetRotation(enemy, Vector(ri.x+offset,ri.y+offset,ri.z+offset))
//						local s = ItemGetScale(enemy)
//						ItemSetScale(enemy,s*0.99)
					}
					else
					{
//						ItemApplyLinearImpulse(enemy,Vector(0,0,-objVelocity))
//						ItemSetLinearVelocity(enemy,Vector(0,0,-objVelocity))

//						ItemSetPosition(enemy, Vector(wp.x,wp.y,wp.z - 10*g_dt_frame*60))
						ItemSetRotation(enemy, Vector(ri.x-offset,ri.y-offset,ri.z-offset))
					}

					if (TickToSec(g_clock-SyncTimer) >= syncBit*2 )
						SyncTimer = g_clock


					//if enemy is dead
//					if (ItemGetLinearVelocity(enemy).z == 0 )
					if (ItemGetScriptInstance(enemy).hit)
					{
						local _snd  = ResourceFactoryLoadSound(g_factory, snd_fx_wall)
						MixerSoundStart(g_mixer, _snd)
						gScore += 50
						ItemGetScriptInstance(enemy).hit = 0
					}

					if (ItemGetScriptInstance(enemy).dead)
					{
						local _snd  = ResourceFactoryLoadSound(g_factory, snd_fx_dead)
						MixerSoundStart(g_mixer, _snd)

						enemyGrp.remove(idx)
						SceneDeleteItem(scene,enemy)
						destroyed++

						gScore += 100
					}

					local position = ItemGetWorldPosition(enemy)

				} //End foreach(idx,enemy in enemyGrp)
*/
		}


		//game over
		if (gLifes == 0)
	//		GameOver(scene)
			local g = 1
		else
			if (!pause)
				{
					//update score
					if (TickToSec(g_clock-scorTimer) >= 0.01)
					{
						gScore += 1+boost*2
						gScore = abs(gScore)
						local gScore = beatScore*10
						TextSetText(scoreWindow[1], gScore.tostring())
						scorTimer = g_clock
					}
				}

		//Lifes : 1 up every scoreCounter points
		if (gScore >= oneupScore*scoreCounter)
			{
				scoreCounter++
				if (gLifes < gLifesMax)
					{
						gLifes++
						WindowSetPosition(oneupWindow[0], 200, 350)
						WindowSetOpacity(oneupWindow[0], 1)
						local newy = WindowGetPosition(oneupWindow[0]).y - 200
						WindowSetCommandList(oneupWindow[0] , "loop; toalpha 1,0.0+toposition 1," + WindowGetPosition(oneupWindow[0]).x.tostring() + "," + newy + "; next;")
						UpdateLifes(gLifes)
						local oneup  = ResourceFactoryLoadSound(g_factory, "data/oneup.wav")
						MixerSoundStart(g_mixer, oneup)
					}
			}


		//energy 
		WindowSetSize(energyBar,gFFenergy/4,20)
		if (gFFenergy <= 1)
			{
				local loene  = ResourceFactoryLoadSound(g_factory, "data/noenergy.wav")
				MixerSoundStart(g_mixer, loene)
			}
			
		//display help
/*		helpCounter++
		if ( DeviceIsKeyDown(keyboard, KeyF1) || DeviceIsKeyDown(pad, KeyButton2) )
			{
				if (opa > 0)
					opa+=-0.02
				else
					opa=1
				WindowSetOpacity(helpLabel[0], opa)
			}
		else
			SpriteSetOpacity(helpLabel[0],0)

		if ((helpCounter > 550) && (helpCounter < 1000))
			{
				if (opa > 0)
					opa+=-0.02
				else
					opa=1
				SpriteSetOpacity(helpLabel2[0], opa)
			}
		else
			SpriteSetOpacity(helpLabel2[0],0)

*/
	}


	function	OnPhysicStep(scene, dt)
	{


		if (phase == 1)
		{

			if (TickToSec(g_clock - syncBitTimer) >= syncBit*2)
			{
				syncBitTimer = g_clock

//				MixerChannelSetGain(g_mixer, channels[6], RangeAdjustClamped(beatScore, 0, 100, 0, 1))
					
				if (beatScore <18)
					MixerChannelResume(g_mixer, channels[0])
				else
					MixerChannelPause(g_mixer, channels[0])

				if ((beatScore >= 2) && (beatScore <18))
					MixerChannelResume(g_mixer, channels[1])
				else
					MixerChannelPause(g_mixer, channels[1])
				if ((beatScore >= 4) && (beatScore <18))
					MixerChannelResume(g_mixer, channels[2])
				else
					MixerChannelPause(g_mixer, channels[2])
				if ((beatScore >= 6) && (beatScore <18))
					MixerChannelResume(g_mixer, channels[3])
				else
					MixerChannelPause(g_mixer, channels[3])
				if ((beatScore >= 8) && (beatScore <18))
					MixerChannelResume(g_mixer, channels[4])
				else
					MixerChannelPause(g_mixer, channels[4])
				if ((beatScore >= 10) && (beatScore <18))
					MixerChannelResume(g_mixer, channels[5])
				else
					MixerChannelPause(g_mixer, channels[5])
//				if ((beatScore >= 12) && (beatScore <18))
//					MixerChannelResume(g_mixer, channels[6])
//					MixerChannelSetGain(g_mixer, channels
//				else
//					MixerChannelPause(g_mixer, channels[6])
				if ((beatScore >= 14) && (beatScore <18))
					MixerChannelResume(g_mixer, channels[7])
				else
					MixerChannelPause(g_mixer, channels[7])
				if (beatScore >= 16)
					MixerChannelResume(g_mixer, channels[8])
				else
					MixerChannelPause(g_mixer, channels[8])
				if (beatScore >= 24)
				{
					for(local i=0; i<9; i++)
						MixerChannelResume(g_mixer, channels[i])
				}
			}

//collision test
			local ship = SceneFindItem(scene,"Spacecraft")
			local iwmm = ItemGetWorldMinMax(ship)
//			local sitem = ItemGetWorldPosition(SceneFindItem(scene,"Spacecraft"))
//			local col =	SceneCollisionRaytrace(scene,sitem,Vector(0,0,1),-1,CollisionTraceCuboid,Mtr(spawnZ))
			local col =	SceneCollisionRaytrace(scene,iwmm.min ,Vector(0,0,1),-1,CollisionTraceCuboid,Mtr(g_spawnZ))
			if ((col.hit) && ItemHasScript(col.item, "Trajectory"))
			{
				//Set the item as being in the ship's trajectory
				ItemGetScriptInstanceFromClass(col.item, "Trajectory").willHit = 1
				ItemGetScriptInstanceFromClass(col.item, "Trajectory").distance = col.d
			}
			local col =	SceneCollisionRaytrace(scene,Vector(iwmm.min.x, iwmm.max.y, iwmm.min.z) ,Vector(0,0,1),-1,CollisionTraceCuboid,Mtr(g_spawnZ))
			if ((col.hit) && ItemHasScript(col.item, "Trajectory"))
			{
				//Set the item as being in the ship's trajectory
				ItemGetScriptInstanceFromClass(col.item, "Trajectory").willHit = 1
				ItemGetScriptInstanceFromClass(col.item, "Trajectory").distance = col.d
			}
			local col =	SceneCollisionRaytrace(scene,Vector(iwmm.max.x, iwmm.min.y, iwmm.min.z) ,Vector(0,0,1),-1,CollisionTraceCuboid,Mtr(g_spawnZ))
			if ((col.hit) && ItemHasScript(col.item, "Trajectory"))
			{
				//Set the item as being in the ship's trajectory
				ItemGetScriptInstanceFromClass(col.item, "Trajectory").willHit = 1
				ItemGetScriptInstanceFromClass(col.item, "Trajectory").distance = col.d
			}
			local col =	SceneCollisionRaytrace(scene,iwmm.max ,Vector(0,0,1),-1,CollisionTraceCuboid,Mtr(g_spawnZ))
			if ((col.hit) && ItemHasScript(col.item, "Trajectory"))
			{
				//Set the item as being in the ship's trajectory
				ItemGetScriptInstanceFromClass(col.item, "Trajectory").willHit = 1
				ItemGetScriptInstanceFromClass(col.item, "Trajectory").distance = col.d
			}



		}
	}


	function RendererDrawQuad(renderer, v0, v1, v2, v3, c0, c1, c2, c3, MatBlendMode, MatRendMode)
	{
		RendererDrawTriangle(renderer,v0, v1, v3, c0, c1, c3, MatBlendMode, MatRendMode)
		RendererDrawTriangle(renderer,v1, v2, v3, c1, c2, c3, MatBlendMode, MatRendMode)
	}


	function	OnRenderUser(scene)
	{
		RendererApplyCamera(g_render)
		RendererSetIdentityWorldMatrix(g_render)

		local f0,f1,f2,f3
		local b0,b1,b2,b3

		if (patobjs.len())
		{
			local min = patobjs[0].GetMinMax().min
			local max = patobjs[0].GetMinMax().max
			f0 = Vector(min.x,min.y, -50)
			f1 = Vector(min.x,max.y, -50)
			f2 = Vector(max.x,max.y, -50)
			f3 = Vector(max.x,min.y, -50)
			b0 = min
			b1 = Vector(min.x,max.y,max.z)
			b2 = max
			b3 = Vector(max.x,min.y,max.z)

			//store min and max for ship movement limitation
			worldLimit.min = b0
			worldLimit.max = b2

			RendererDrawQuad(g_render, f0, b0, b1, f1, limitColF, limitColF, limitColB, limitColB, MaterialBlendAlpha, MaterialRenderDoubleSided)
			RendererDrawQuad(g_render, f1, b1, b2, f2, limitColF, limitColF, limitColB, limitColB, MaterialBlendAlpha, MaterialRenderDoubleSided)
			RendererDrawQuad(g_render, f2, b2, b3, f3, limitColF, limitColF, limitColB, limitColB, MaterialBlendAlpha, MaterialRenderDoubleSided)
			RendererDrawQuad(g_render, f3, b3, b0, f0, limitColF, limitColF, limitColB, limitColB, MaterialBlendAlpha, MaterialRenderDoubleSided)

			for(local i=0; i<(patobjs.len()-1); i++)
			{
				f0 = b0
				f1 = b1
				f2 = b2
				f3 = b3

				local min = patobjs[i+1].GetMinMax().min
				local max = patobjs[i+1].GetMinMax().max
				b0 = min
				b1 = Vector(min.x,max.y,max.z)
				b2 = max
				b3 = Vector(max.x,min.y,max.z)

				RendererDrawQuad(g_render, f0, b0, b1, f1, limitColF, limitColF, limitColB, limitColB, MaterialBlendAlpha, MaterialRenderDoubleSided)
				RendererDrawQuad(g_render, f1, b1, b2, f2, limitColF, limitColF, limitColB, limitColB, MaterialBlendAlpha, MaterialRenderDoubleSided)
				RendererDrawQuad(g_render, f2, b2, b3, f3, limitColF, limitColF, limitColB, limitColB, MaterialBlendAlpha, MaterialRenderDoubleSided)
				RendererDrawQuad(g_render, f3, b3, b0, f0, limitColF, limitColF, limitColB, limitColB, MaterialBlendAlpha, MaterialRenderDoubleSided)
			}

		}

		// Reset all rendering matrices to identity (no transformation)
		RendererSetAllMatricesToIdentity(g_render)

//		RendererSetIdentityWorldMatrix(g_render)
//		RendererSetIdentityProjectionMatrix(g_render)
//		RendererSetIdentityViewMatrix(g_render)


		if (debug)
		{
			RendererWrite(g_render, g_debugFont, "	clock = " + g_clock, 1, 0, 0.5, true, WriterAlignRight, Vector(1, 1, 1, 1))
			RendererWrite(g_render, g_debugFont, "SyncTimer = " + TickToSec(g_clock-SyncTimer), 1, 0.04, 0.5, true, WriterAlignRight, Vector(1, 1, 1, 1))
			RendererWrite(g_render, g_debugFont, "	 FPS  = " + 1/g_dt_frame , 1, 0.08, 0.5, true, WriterAlignRight, Vector(1, 1, 1, 1))
			objCount = patobjs.len()
			RendererWrite(g_render, g_debugFont, " objCount = " + objCount , 1, 0.12, 0.5, true, WriterAlignRight, Vector(1, 1, 1, 1))
			RendererWrite(g_render, g_debugFont, "itemCount = " + itemCount , 1, 0.16, 0.5, true, WriterAlignRight, Vector(1, 1, 1, 1))

			RendererWrite(g_render, g_debugFont, "beatScore = " + beatScore , 1, 0.20, 0.5, true, WriterAlignRight, Vector(1, 1, 1, 1))
			RendererWrite(g_render, g_debugFont, "pool(avail.) = " + g_availCubesPool.len() , 1, 0.24, 0.5, true, WriterAlignRight, Vector(1, 1, 1, 1))
			RendererWrite(g_render, g_debugFont, "pool(used) = " + g_usedCubesPool.len() , 1, 0.28, 0.5, true, WriterAlignRight, Vector(1, 1, 1, 1))
			RendererWrite(g_render, g_debugFont, "Lifes = " + gLifes , 1, 0.32, 0.5, true, WriterAlignRight, Vector(1, 1, 1, 1))

//			local p = ItemGetScriptInstanceFromClass(SceneFindItem(scene, "Spacecraft"), "spacecraft").ShipScreenPosition

//			RendererWrite(g_render, debugFont, "X = " + ItemGetScriptInstanceFromClass(SceneFindItem(scene, "Spacecraft"), "spacecraft").position.x , p.x, p.y-0.1, 0.4, true, WriterAlignRight, Vector(1, 1, 1, 1))
//			RendererWrite(g_render, debugFont, "Y = " + ItemGetScriptInstanceFromClass(SceneFindItem(scene, "Spacecraft"), "spacecraft").position.y , p.x, p.y-0.14, 0.4, true, WriterAlignRight, Vector(1, 1, 1, 1))

//			RendererWrite(g_render, debugFont, "x = " + p.x , p.x, p.y-0.18, 0.4, true, WriterAlignRight, Vector(1, 1, 1, 1))
//			RendererWrite(g_render, debugFont, "y = " + p.y , p.x, p.y-0.22, 0.4, true, WriterAlignRight, Vector(1, 1, 1, 1))
		}
//		RendererDrawLine(g_render,ItemGetPosition(SceneFindItem(scene,"BeveledCube")), Vector(0,0,0) )
	}


//	========================================================================================================
	function	OnSetup(scene)
//	========================================================================================================
	{
		//Unpause for the pad
		pause = false

		g_usedCubesPool  = []
		targetList = []

		wallTimer		= [g_clock,g_clock]
		wallFreq		= [10,15]
		wallPieces		= []

		scorTimer		= g_clock
		scoreWindow		= 0

		//Generates the city
//		wait = GenerateCity(scene,-1000,1000,0,1000,10,5,0.1)

		// Load UI fonts.
		ui = SceneGetUI(scene)
		UISetInternalResolution(ui, UIWidth, UIHeight)

//		local BGsprite = CreateSprite(ui,"ui/overlay.png",0,0,1)

		helpLabel = CreateLabel(ui, "Up,Down,Left,Right,X/V(Roll),C(Shield),R(Restart),F1(Help)", 400, 700, 24, 900, 96,255,255,255,200,"Aldrich",TextAlignCenter)
		helpLabel2 = CreateLabel(ui, "STAY ALIVE ! ", 500, 800, 40, 900, 96,255,255,255,255,"Aldrich",TextAlignCenter)
		SpriteSetOpacity(helpLabel[0],0)
		SpriteSetOpacity(helpLabel2[0],0)


		local ScoreWindow = UIAddNamedWindow(ui, "sw", 0, 20, 180,140)
		WindowSetBackgroundColor(ScoreWindow, RGBAToHex(Vector(255,85,225,255)))
		WindowRenderSetup(ScoreWindow, g_factory)

		CreateLabel(ui, "LIFE", 50, 40, 24, 120, 96,0,0,0,255,"Aldrich",TextAlignRight)
		CreateLabel(ui, "ENERGY", 50, 80, 24, 120, 96,0,0,0,255,"Aldrich",TextAlignRight)
		CreateLabel(ui, "SCORE", 50, 0, 24, 120, 96,0,0,0,255,"Aldrich",TextAlignRight)

		scoreWindow 	= CreateLabel(ui, gScore.tostring(), 200, 0, 24, 120, 96,0,0,0,255,"Aldrich",TextAlignLeft)
		boostWindow 	= CreateLabel(ui, "BOOST", 850, 120, 40, 300, 40,50,195,255,255,"Aldrich",TextAlignLeft)
		oneupWindow 	= CreateLabel(ui, "1 UP !!", 200, 350, 50, 300, 40,255,84,0,255,"Aldrich",TextAlignCenter)
		WindowSetOpacity(boostWindow[0],0)
		WindowSetOpacity(oneupWindow[0],0)
		WindowSetOpacity(scoreWindow[0],1)

		local fullBarTex	= ResourceFactoryLoadTexture(g_factory, "Tex/nrgBarFull.png")
		local fillBarTex	= ResourceFactoryLoadTexture(g_factory, "Tex/nrgBarFill.png")

		local energyBarFull		= UIAddSprite(ui, g_ui_IDs++, fullBarTex, 200, 115, 250, 20)
			  energyBar			= UIAddSprite(ui, g_ui_IDs++, fillBarTex, 200, 115, 250, 20)
		local lifeBarFull		= UIAddSprite(ui, g_ui_IDs++, fullBarTex, 200, 75, 250, 20)
			  lifeBar			= UIAddSprite(ui, g_ui_IDs++, fillBarTex, 200, 75, 250, 20)

//		lblGameOver = CreateLabel(ui, "GAME OVER !", 450, 250, 70, 900, 500,0,0,0,255,"JosefinSansBold",TextAlignCenter)
		lblGameOver = CreateLabelWithBgColor(ui, "GAME OVER", (UIWidth-600)/2, (UIHeight-320)/2, 48, 600, 320, 255, 255, 255, 255, "Aldrich",TextAlignCenter,0, 0, 0, 255)
		lblRetry = CreateLabelWithBgColor(ui, "RETRY", (UIWidth-600)/2+40, (UIHeight-320)/2+240, 24, 200, 48, 0, 0, 0, 255, "Aldrich",TextAlignCenter,255, 225, 82, 255)
		lblQuit = CreateLabelWithBgColor(ui, "QUIT", (UIWidth+600)/2-240, (UIHeight-320)/2+240, 24, 200, 48, 255, 255, 255, 255, "Aldrich",TextAlignCenter,0, 0, 0, 255)
//		lblPause 	= CreateLabel(ui, "PAUSE", 450, 200, 70, 900, 500,0,0,0,255,"Aldrich",TextAlignCenter)
		lblPause = CreateLabelWithBgColor(ui, "PAUSE", (UIWidth-600)/2, (UIHeight-320)/2, 48, 600, 320, 255, 255, 255, 255, "Aldrich",TextAlignCenter,0, 0, 0, 255)
		lblPauseResume = CreateLabelWithBgColor(ui, "Resume", (UIWidth-600)/2+40, (UIHeight-320)/2+240, 24, 200, 48, 0, 0, 0, 255, "Aldrich",TextAlignCenter,255, 225, 82, 255)
		lblPauseQuit = CreateLabelWithBgColor(ui, "Quit", (UIWidth+600)/2-240, (UIHeight-320)/2+240, 24, 200, 48, 255, 255, 255, 255, "Aldrich",TextAlignCenter,0, 0, 0, 255)
		lblGetReady = CreateLabel(ui, "Get Ready !", -2000, 500, 150, 1500, 500,50,195,255,255,"Aldrich",TextAlignCenter)
		lblLoading = CreateLabelWithBgColor(ui, "Loading...", (UIWidth-300)/2, (UIHeight-160)/2, 24, 300, 48, 255, 255, 255, 255, "Aldrich",TextAlignCenter,0, 0, 0, 255)

		SpriteSetOpacity(lblGameOver[0],0)
		SpriteSetOpacity(lblRetry[0],0)
		SpriteSetOpacity(lblQuit[0],0)
		SpriteSetOpacity(lblPause[0],0)
		SpriteSetOpacity(lblPauseQuit[0],0)
		SpriteSetOpacity(lblPauseResume[0],0)
		SpriteSetOpacity(lblGetReady[0],0)
		SpriteSetOpacity(lblLoading[0],1.0)



// Objects init
		baseItem = SceneFindItem(scene, "cubeTile")
		tileSize = ItemGetMinMax(baseItem).max.x - ItemGetMinMax(baseItem).min.x



/***************************************************
//The following loop initialises
// * g_patfs	: array of arrays with the pixel values (from bitmap files)
// * g_patlocs	: array of arrays of physical locations
// * g_geo		: table of unique colors/geometries
****************************************************/
/*
		for(local pid=0;pid<maxPatterns;pid++)
		{
			local p = LoadPicture("Sav/pattern" + pid + ".png")
			local w = PictureGetRect(p).GetWidth()
			local h = PictureGetRect(p).GetHeight()
			local patf = []
			local gridArLoc = [] //Initialize the location array of this pattern

			local offsetx = (w*tileSize)/2// - tileSize/2
			local offsety = (h*tileSize)/2// - tileSize/2

			for(local i=0; i<w; i++)
				for(local j=0; j<h; j++)
				{
					patf.append(PictureGetPixel(p,i,j))

					local x = i*tileSize - offsetx
					local y = offsety - j*tileSize
					gridArLoc.append(Vector(x,y,0))

					local px = PictureGetPixel(p,i,j)
					local key = px.x + "_" + px.y + "_" + px.z + "_" + px.w

					if ((px.w != 0) && !(key in g_geo))					//If first occurance of this color, create an item and store it in g_cubes
					{
						local id = g_geo.len() + 1
						local new_geo  = ResourceFactoryLoadGeometryEx(g_factory, "Mesh/CubeGeo" + id + ".nmg" , false)
						local new_mat  = ResourceFactoryLoadMaterialEx(g_factory, "Mesh/CubeMat" + id + ".nmm" , false)
						MaterialSetSelf(new_mat, Vector(px.x,px.y,px.z,1))
						GeometrySetMaterial(new_geo, 0, new_mat)

						g_geo.rawset(key,new_geo)
					}
				}
			
			//Append this location array to the array of locations
			g_patlocs.append(gridArLoc)
	
			//Append the pixel to the array of pixels
			g_patfs.append(patf)
		}

		print(g_geo.len() + " different geometries have been registered")
*/

	
//		local mf = MetafileNew()
//		try(MetafileLoad(mf, "@app/patterns.txt")) catch(e) {throw(e)}
/*		SystemMountLocalPath("H:/wrk/GS/schmup1/schmup/Sav/", "@Sav/")
		print(SystemHasMountPoint("@Sav/"))
		if (MetafileLoad(mf, "@Sav/save.nml"))
		{
			local tag = MetafileGetTag(mf, "save;")

			if	(ObjectIsValid(tag))
				local tab = deserializeObjectFromMetatag(tag)
			print(tab)
		} 
*/
//		SceneSetFog(g_scene, true, Vector(0.5, 0.7, 0.9), Mtr(200), Mtr(1000))


// PHYSICS INIT
		//prevents objets from falling down
		SceneSetGravity(scene, Vector(0,0,0))
		SceneSetPhysicFrequency(scene, 60.0)
		SceneSetFixedDeltaFrame(scene, 1/30)


// Sound init
		MixerChannelStopAll(g_mixer)

		print(g_sounds.len()-1)
		for (local i=0; i<g_sounds.len()-1;i++)
		{
//			sounds.append(ResourceFactoryLoadSound(g_factory, snd_p[i]))
			channels.append(MixerPlaySound(g_mixer, g_sounds[i]))
			MixerChannelPause(g_mixer, channels[i])
			//MixerStartStream(g_mixer, snd_stream_p[i])
			MixerChannelSetLoopMode(g_mixer,channels[i],LoopRepeat)
//			local chan = MixerStartStream(g_mixer, snd_stream_p[i])
//			MixerChannelSetLoopMode(g_mixer,chan,LoopRepeat)
//			channels.append(chan)
		}


//Timers init
		syncBitTimer = g_clock
	}
}