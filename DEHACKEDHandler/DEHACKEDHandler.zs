// Copyright 2020 3saster
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

//===========================================================================
//
// DEHACKED Handler
// by 3saster
//
// This event handler runs on GZDoom startup and determines which actors were
// likely modified by DEHACKED (this only works for internal lumps, but this
// should not be a big deal). Use the isDehacked method to check if an actor
// is suspected to be modified by DEHACKED.
//
// This requires the DEHACKEDTables file, remember to include it.
//
// This eventhandler currently checks for DEHACKED modified monsters in three ways:
// 1. Thing XX
// 2. Frame XX
// 3. Pointer XX
// False positives are possible (false negatives shouldn't be), but should be fairly rare.
//
// You are welcome to to use this in your mods, no need to ask for permission,
// as long as the above copyright notice is included, and credit is given.
//
//===========================================================================

Class DEHACKEDHandler : StaticEventHandler
{
	// List of likely modified actors
	Array<string> dehackedActors;

	// Was this actor likely modified by DEHACKED?
	bool isDehacked(string classname)
	{
		// Special handling for Hell Knight...
		if(classname ~== "HellKnight")
		{
			return (dehackedActors.Find(classname) != dehackedActors.Size());
		}
		else
		{
			class<Actor> cls = classname;
			for(int i=0; i<dehackedActors.Size(); i++)
			{
				// Must be done this way to check for inheritance
				if(cls && cls is dehackedActors[i])
					return true;
			}
			return false;
		}
	}
	
	override void OnRegister()
	{
		setConstants();
		
		int currLump = Wads.FindLump("DEHACKED",0,1);
		while( currLump != -1 )
		{
			addDEHACKED(currLump);
			currLump = Wads.FindLump("DEHACKED",currLump+1,1);
		}
		/*
		console.printf("-------------------------------");
		for(int i=0; i<dehackedActors.Size(); i++)
			console.printf("%s", dehackedActors[i]);
		console.printf("-------------------------------");
		*/
	}
	
	void addDEHACKED(int lump)
	{
		string data = Wads.ReadLump(lump);
		// Delete comments
		while(data.IndexOf("#") != -1)
		{
			int start = data.IndexOf("#");
			int end   = data.IndexOf("\n",start);
			data.Remove(start,end-start);
		}
		// Split Lines
		Array<String> lines;
		data.Split(lines, "\n");
		
		// Parse each line
		for(int i=0; i<lines.Size(); i++)
		{
			// Remove superflous spaces
			string cleandata = lines[i];
			cleandata.Replace("  "," ");
			while(lines[i] != cleandata)
			{
				lines[i] = cleandata;
				cleandata.Replace("  "," ");
			}
			// Remove leading whitespace
			while( lines[i].length() > 0 && lines[i].Left(1) == " " )
				lines[i].Remove(0,1);
			// Tokenize
			Array<String> tokens;
			lines[i].Split(tokens, " ");
			if( tokens.Size() >= 2) // Thing XX, etc.
			{
				int num = tokens[1].ToInt(10);
				// not a proper number; skip
				if (num < 0)
					continue;
				// Check the number isn't actually 0, since a failed conversion also returns 0
				if (num == 0)
				{
					string s = tokens[1].."1";
					if( s.ToInt(10) == 0 )
						continue;
				}

				if ( tokens[0] ~== "Thing" )
				{
					if( dehackedActors.Find(InfoNames[num]) == dehackedActors.Size() )
						dehackedActors.Push(InfoNames[num]);
				}
				else if ( tokens[0] ~== "Frame" )
				{
					string state = num < 1076 ? StateMap[num] : 'Deh_Actor_250';
					if( dehackedActors.Find(state) == dehackedActors.Size() )
						dehackedActors.Push(state);
				}
				else if ( tokens[0] ~== "Pointer" )
				{
					num = CodePConv[num];
					string state = num < 1076 ? StateMap[num] : 'Deh_Actor_250';
					if( dehackedActors.Find(state) == dehackedActors.Size() )
						dehackedActors.Push(state);
				}
			}
			if( tokens.Size() >= 3 && tokens[0] ~== "Text" && tokens[1] ~== "4" && tokens[1] ~== "4" ) // "Text 4 4" to change a sprite name
			{
				if( i+1<lines.Size() )
				{
					string modActors = spriteMapping.At( lines[i+1].Left(4).MakeUpper() );
					if( modActors.Length () > 0)
					{
						Array<String> actors;
						modActors.Split(actors, ",");
						for(int i=0; i<actors.Size(); i++)
						{
							if( dehackedActors.Find(actors[i]) == dehackedActors.Size() )
								dehackedActors.Push(actors[i]);
						}
					}
				}
			}
		}
	}
}