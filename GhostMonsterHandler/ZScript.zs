//===========================================================================
//
// GhostMonsterHandler (requires GZDoom 4.5.0+ or equivalent)
// by 3saster
//
// An eventhandler that allows vanilla style ghost monsters to be
// deliberately put back into GZDoom, emulating the "vileghosts" automatic
// compatibility option. The "compat_corpsegibs" compatibility CVAR, which
// can be controlled using MAPINFO, is required for ghosts to work.
// Additionally, to not tie the "compat_corpsegibs" CVAR to ghost monsters,
// in WorldThingGround below, there are cases; add/change the cases to
// whichever maps you want to have ghost monsters on. Don't forget to use
// MAPINFO to also add the eventhandler!
//
// This is intended for map creators who wish to use ghost monsters in GZDoom
// without needing the map added to GZDoom's automatic compatibility. While
// this can also be used for old maps that relied on ghost monsters, it is
// recommended that the user also reports that to the GZDoom devs so that
// it can be added to GZDoom's automatic compatibility.
//
// You are welcome to to use this in your mods, no need to ask for permission.
// Credit is appreciated but not required.
//
//===========================================================================

Version "4.5.0"

Class ReviveAsGhost : Inventory
{
	Default
	{
		FloatBobPhase 0;
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
	}
}

Class GhostMonsterHandler : EventHandler
{
	override void WorldThingGround(WorldEvent e)
	{
		if(e && e.thing && e.thing.bIsMonster)
		{
			switch( Name(level.MapName) )
			{
			// Change these to whichever maps you want to have vileghosts.
			// Don't forget to force "compat_corpsegibs" in MAPINFO as well!
			case 'MAP14':
			case 'MAP25':
				e.thing.A_GiveInventory("ReviveAsGhost", 1);
			default:
				break;
			}
		}
	}
	
	override void WorldThingRevived(WorldEvent e)
	{
		if(e && e.thing && e.thing.bIsMonster)
		{
			let mo = e.thing;
			if(mo && mo.FindInventory("ReviveAsGhost"))
			{
				mo.TakeInventory("ReviveAsGhost",1);
				mo.A_SetSize(0,0);
				
				// Make raised corpses look ghostly
				if (mo.Alpha > 0.5)
					mo.Alpha /= 2;
				// This will only work if the render style is changed as well.
				if (mo.GetRenderStyle() == STYLE_Normal)
					mo.A_SetRenderStyle(mo.Alpha,STYLE_Translucent);
			}
		}
	}
}