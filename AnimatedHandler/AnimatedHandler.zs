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
// Animated Handler
// by 3saster
//
// This event handler runs on GZDoom startup and determines which textures are
// animated by reading through ANIMDEFS and ANIMATED lumps. Use the isAnimated
// method to determine whether or not a particular texture is animated.
//
// You are welcome to to use this in your mods, no need to ask for permission,
// as long as the above copyright notice is included, and credit is given.
//
//===========================================================================

Class AnimatedHandler : StaticEventHandler
{
	// These must be stored as numbers, in order to get the textures
	// from ANIMATED in between the start and end
	// Oddly, we can convert a TextureID to int, but not the other way
	Array<int> animNums;
	
	bool isAnimated(textureID tex)
	{
		return ( animNums.Find(int(tex)) != animNums.Size() );
	}

	override void OnRegister()
	{
		// ANIMATED
		int currLump = Wads.FindLump("ANIMATED",0,1);
		while( currLump != -1 )
		{
			addANIMATED(currLump);
			currLump = Wads.FindLump("ANIMATED",currLump+1,1);
		}
		
		// ANIMDEFS
		currLump = Wads.FindLump("ANIMDEFS",0,1);
		while( currLump != -1 )
		{
			addANIMDEFS(currLump);
			currLump = Wads.FindLump("ANIMDEFS",currLump+1,1);
		}
	}
	
	void addANIMATED(int lump)
	{
		string data = Wads.ReadLump(lump);
		// Read each record
		for(int pos = 0; data.ByteAt(pos) != 255; pos += 23 )
		{
			string start = data.Mid(pos+10,9);
			string end   = data.Mid(pos+1 ,9);
			
			int texStart = int(TexMan.CheckForTexture(start, TexMan.Type_Any));
			int texEnd   = int(TexMan.CheckForTexture(end,   TexMan.Type_Any));
				
			// If animated texture exists and is not in array, add it
			if( texStart > 0 && texEnd > 0 && texStart != texEnd )
				for(int i = texStart; i <= texEnd; i++)
				{
					if( animNums.Find(i) == animNums.Size() )
						animNums.Push(i);
				}
		}
	}
	
	void addANIMDEFS(int lump)
	{
		string data = Wads.ReadLump(lump);
		// Delete comments
		while(data.IndexOf("//") != -1)
		{
			int start = data.IndexOf("//");
			int end   = data.IndexOf("\n",start)+1;
			data.Remove(start,end-start);
		}
		while(data.IndexOf("/*") != -1)
		{
			int start = data.IndexOf("/*");
			int end   = data.IndexOf("*/",start)+2;
			data.Remove(start,end-start);
		}
		// Remove non-space whitespace
		for(int i = 0; i <= 31; i++)
			data.Replace(string.format("%c",i)," ");
		data.Replace(string.format("%c",127)," ");
		// Remove superflous spaces
		string cleandata = data;
		cleandata.Replace("  "," ");
		while(data != cleandata)
		{
			data = cleandata;
			cleandata.Replace("  "," ");
		}
		
		// Tokenize
		Array<String> tokens;
		data.Split(tokens, " ");
		
		// Search for token after texture/flat
		int i = 0;
		while(i < tokens.Size())
		{
			// texture.flat appears as next token; skip that
			if(tokens[i] ~== "warp" || tokens[i] ~== "warp2")
				i += 2;
			// Found an animated texture; read "pic" stuff until another token is found
			else if(tokens[i] ~== "texture" || tokens[i] ~== "flat")
			{
				while( i < tokens.Size() && !(tokens[i] ~== "pic") )
					i++;
				while( i < tokens.Size() && tokens[i] ~== "pic" )
				{
					int texture = int(TexMan.CheckForTexture(tokens[i+1], TexMan.Type_Any));
					if( texture > 0 && animNums.Find(texture) == animNums.Size() )
						animNums.Push(texture);
					i += 4;
				}
			}
			else
				i++;
		}
	}
}