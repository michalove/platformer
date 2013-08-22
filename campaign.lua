Campaign = {	
	--'n45.dat', -- fixed cannon	
	
	'n13.dat',
	'n1.dat',
	'n10.dat',
	'n2.dat',
	'n3.dat',
	'n15.dat',
	'n38.dat',
	'n11.dat',
	'n12.dat',
	'n5.dat',
	'n24.dat',	
	'n6.dat',
	'n7.dat',
	'n8.dat',
	'n9.dat',
	'n14.dat',
	'n17.dat',	
	'n18.dat',
	'n16.dat',
	'n20.dat',
	'n19.dat',
	'n21.dat',
	'n23.dat',
	'n27.dat',
	'n26.dat',
	'n28.dat',
	'n25.dat',
	'n22.dat',
	'n29.dat',
	'n31.dat',
	'n30.dat',
	'n32.dat',
	'n33.dat',
	'n34.dat', -- button
	'n35.dat',
	'n36.dat',
	'n37.dat', -- imitator
	'n39.dat',
	'n40.dat',	
	'n41.dat', -- wind
	'n42.dat', -- breaking block
	'n44.dat', -- glass tutorial
	'n43.dat', -- glass long level			
	'n45.dat', -- fixed cannon	
	
	}

Campaign.current = 0

function Campaign:reset()
  self.current = 1
  myMap = Map:LoadFromFile(self[self.current])  
end

function Campaign:proceed()
  self.current = self.current + 1
  if self[self.current] then
    myMap = Map:LoadFromFile(self[self.current])
    myMap:start(p)
  else
    mode = 'menu'
		menu.initWorldMap()    
  end
	-- remember the level which was last played
	config.setValue( "level", self[self.current] )

	-- if this level is further down the list than the
	-- saved "last level", then save the current level
	-- as the "last level":
	local lastLevel = config.getValue( "lastLevel")
	if not lastLevel then
		--print("saving new last level:", self[self.current])
		config.setValue( "lastLevel", self[self.current])
	else
		curIndex = tableFind(self, self[self.current]) 
		lastIndex = tableFind(self, lastLevel)
		--print("curIndex, lastIndex", curIndex, lastIndex, #lastLevel, #self[self.current])
		if curIndex and lastIndex and curIndex > lastIndex then
			config.setValue( "lastLevel", self[self.current])
		end
	end
end
Campaign.names = {}
Campaign.names['n13.dat'] = 'learn to walk'
Campaign.names['n1.dat'] = 'jump'
Campaign.names['n10.dat'] = 'the chimney'
Campaign.names['n2.dat'] = 'le parcours'
Campaign.names['n3.dat'] = 'by the way, you can die'
Campaign.names['n15.dat'] = 'leap of faith 1'
Campaign.names['n38.dat'] = 'jumping advanced'
Campaign.names['n11.dat'] = 'all you can eat'
Campaign.names['n12.dat'] = 'tight'
Campaign.names['n5.dat'] = 'where is the ground?'
Campaign.names['n24.dat']	 = 'free climbing'
Campaign.names['n6.dat'] = 'the launcher'
Campaign.names['n7.dat'] = 'zig zag'
Campaign.names['n8.dat'] = 'vertical'
Campaign.names['n9.dat'] = 'ascension'
Campaign.names['n14.dat'] = 'up, up, around'
Campaign.names['n17.dat'] = 'get over it'
Campaign.names['n18.dat'] = 'no pain, no gain'
Campaign.names['n16.dat'] = 'leap of faith 11'
Campaign.names['n20.dat'] = 'its a trap'
Campaign.names['n19.dat'] = 'bowel'
Campaign.names['n21.dat'] = 'uprising'
Campaign.names['n23.dat'] = 'vertical 11'
Campaign.names['n27.dat'] = 'following'
Campaign.names['n26.dat'] = 'the one'
Campaign.names['n28.dat'] = 'stairway'
Campaign.names['n25.dat'] = 'calm'
Campaign.names['n22.dat'] = 'weeeee'
Campaign.names['n29.dat'] = 'the crown'
Campaign.names['n31.dat'] = 'leap of faith 111'
Campaign.names['n30.dat'] = 'half pipe'
Campaign.names['n32.dat'] = 'dont hesitate'
Campaign.names['n33.dat'] = 'where am i?'
Campaign.names['n34.dat'] = 'push the button'-- button
Campaign.names['n35.dat'] = 'timed'
Campaign.names['n36.dat'] = 'back and forth'
Campaign.names['n37.dat'] = 'i wanna be like you' -- imitator
Campaign.names['n39.dat'] = 'who is faster?'
Campaign.names['n40.dat']	 = 'meditation'
Campaign.names['n41.dat'] = 'upwind' -- wind
Campaign.names['n42.dat']  = 'only once'-- breaking block
Campaign.names['n44.dat'] = 'the elephant' -- glass tutorial
Campaign.names['n43.dat'] = 'dig' -- glass long level			
Campaign.names['n45.dat'] = 'station' -- fixed cannon	

