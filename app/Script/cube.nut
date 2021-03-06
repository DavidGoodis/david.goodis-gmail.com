/*
	File: cube.nut
	Author: DG
*/

/*!
	@short	Cube
	@author	DG
*/

class	Cube
{
	r_step = Rand(-0.1,0.1) //rotation step
	p_step = Rand(5,150) //position step

	captured 	= 0
	cst_ship1 	= 0
	cst_ship2 	= 0
	cst_ship3 	= 0

	RT_released	= 0

	hit			= 0
	dead		= 0

	mat				= 0
	savedSelf		= 0
	movePattern		= 0

	zPos		= 0
	distanceLbl	= 0
	distance	= 0


	/*!
		@short	OnUpdate
		Called during the scene update, each frame.
	*/
	function 	OnCollision(item,with_item)
	{
		if (ItemGetName(with_item) == "bullet" )
			{
				ItemSetCollisionMask(item, 0)
				hit = 1
			}
	}
/*
	function	OnPhysicStep(item, dt)
	{
		local	keyboard 	= GetKeyboardDevice(),
				mouse 		= GetMouseDevice(),
				pad 		= GetInputDevice("xinput0"),
				padrt 		= DeviceInputValue(pad, DeviceAxisRT)

		if (usePad&&(padrt == 0.0))
			RT_released = 1

		if (!captured)
		{
//			local rot = ItemGetRotation(item)
//			ItemApplyTorque(item, Vector(rot.x+0.01, rot.y+0.01, rot.z+0.01))
		}
		else
		{
			if	(DeviceKeyPressed(keyboard, KeyC) || DeviceKeyPressed(pad, KeyButton0))
			{
				RT_released = 0
				ItemSetName(item, "bullet")

				ItemGetScriptInstance(SceneFindItem(g_scene, "Spacecraft")).armed = 0

				local _shape = ItemGetShapeFromIndex(item, 0)
				ShapeSetMass(_shape, 1000)
				SceneSetupItem(g_scene, item)
				
				ConstraintEnable(cst_ship1, false)
				ConstraintEnable(cst_ship2, false)
				ConstraintEnable(cst_ship3, false)
				captured = 0
				
				local booost = SceneGetScriptInstanceFromClass(ItemGetScene(item), "Level1" ).boost

				ItemPhysicSetLinearFactor(item, Vector(0,0,1))
				ItemApplyLinearImpulse(item, Vector(0,0,400))
			}
		}
	}
*/

	function	OnUpdate(item)
	{

/*
		if (ItemGetScriptInstanceFromClass(item, "Trajectory").willHit == 0)
		{
			MaterialSetSelf(GeometryGetMaterialFromIndex(ItemGetGeometry(item), 0), savedSelf)
		}
*/

	}

	/*!
		@short	OnSetup
		Called when the item is about to be setup.
	*/
	function	OnSetup(item)
	{
		captured = 0

//		item = SceneDuplicateItem(scene, baseItem)

/*
		local geo = ItemGetGeometry(item)

		mat = GeometryGetMaterialFromIndex(geo, 0)
		savedSelf	 = MaterialGetSelf(mat)
		MaterialSetSelf(mat, savedSelf)
*/
	}
}
