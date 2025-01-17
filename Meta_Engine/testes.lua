local function toSingle(x, y)
	return x + y * map.w
end

local function toDouble(c)
	local y = math.floor(c / map.w)
	return c - y * map.w, y
end


-- Lista tiles adjacentes

local function listAdjacentTiles(target_x, target_y, no_diagonal, no_cardinal)
	local tiles = {}
	local x = target_x
	local y = target_y

	local left_okay = x > 0
	local right_okay = x < map.w - 1
	local lower_okay = y > 0
	local upper_okay = y < map.h - 1

	if not no_cardinal then
		if upper_okay then tiles[1]        = {x,     y + 1,                       2 } end
		if left_okay  then tiles[#tiles+1] = {x - 1, y,                           4 } end
		if right_okay then tiles[#tiles+1] = {x + 1, y,                           6 } end
		if lower_okay then tiles[#tiles+1] = {x,     y - 1,                       8 } end
	end
	if not no_diagonal then
		if left_okay  and upper_okay then tiles[#tiles+1] = {x - 1, y + 1,        1 } end
		if right_okay and upper_okay then tiles[#tiles+1] = {x + 1, y + 1,        3 } end
		if left_okay  and lower_okay then tiles[#tiles+1] = {x - 1, y - 1,        7 } end
		if right_okay and lower_okay then tiles[#tiles+1] = {x + 1, y - 1,        9 } end
	end
	return tiles
end


-- Itera tiles adjacentes, pulando a abertura dos tiles que originaram o movimento
local adjacentTiles = {
  --Dir 1
  function(target_x, target_y, cardinal_tiles, diagonal_tiles)
    local x = target_x
    local y = target_y
    
    if y < map.h - 1 then
      if isOpenTiles(x,y+1) then cardinal_tiles[#cardinal_tiles+1]         = {x,     y + 1,                2 } end
			if isOpenTiles(x+1,y+1) then diagonal_tiles[#diagonal_tiles+1]         = {x + 1, y + 1,                3 } end
			if x > 0 then
			  if isOpenTiles(x-1,y+1) then diagonal_tiles[#diagonal_tiles+1] = {x - 1,  y + 1,                     1 } end
			  if isOpenTiles(x-1,y) then cardinal_tiles[#cardinal_tiles+1] = {x - 1,  y,                         4 } end
			  if isOpenTiles(x-1,y-1) then diagonal_tiles[#diagonal_tiles+1] = {x - 1,  y - 1,                     7 } end
			end
		elseif x > 0 then
			if isOpenTiles(x-1,y) then cardinal_tiles[#cardinal_tiles+1]         = {x - 1, y,                    4 } end
			if isOpenTiles(x-1,y-1) then diagonal_tiles[#diagonal_tiles+1]         = {x - 1, y - 1,                7 } end
		end
	end,
	--Dir 2
	function(target_x, target_y, cardinal_tiles, diagonal_tiles)
	  local x = target_x
	  local y = target_y
	  
	  if y > map.h - 2 then return end
	  
    if x > 0 and isOpenTiles(x-1,y+1) then diagonal_tiles[#diagonal_tiles+1]         = {x-1, y+1,        1} end
	  if isOpenTiles(x,y+1) then cardinal_tiles[#cardinal_tiles+1]      = {x,   y+1,        2} end
	  if x < map.w -1 and isOpenTiles(x+1,y+1) then diagonal_tiles[#diagonal_tiles+1]  = {x+1, y+1,       3} end
	end,
	--Dir 3
	function(target_x, target_y, cardinal_tiles, diagonal_tiles)
	  local x = target_x
	  local y = target_y
	  
	  if y < map.h - 1 then 
      if isOpenTiles(x-1,y+1) then diagonal_tiles[#diagonal_tiles+1]         = {x-1, y+1,        1} end
      if isOpenTiles(x,y+1) then cardinal_tiles[#cardinal_tiles+1]                       = {x,   y+1,        2} end
      if x < map.w - 1 then
        if isOpenTiles(x+1,y+1) then diagonal_tiles[#diagonal_tiles+1]                     = {x+1, y+1,        3} end
        if isOpenTiles(x+1,y) then cardinal_tiles[#cardinal_tiles+1]                     = {x+1, y,          6} end
        if isOpenTiles(x+1,y-1) then diagonal_tiles[#diagonal_tiles+1]                     = {x+1, y-1,        9} end
      end
    elseif x < map.w - 1 then
      if isOpenTiles(x+1,y) then cardinal_tiles[#cardinal_tiles+1]                     = {x+1, y,          6} end
      if isOpenTiles(x+1,y-1) then diagonal_tiles[#diagonal_tiles+1]       = {x+1, y-1,        9} end
      end
    end,
    --Dir 4
    function(target_x, target_y, cardinal_tiles, diagonal_tiles)
      local x = target_x
      local y = target_y
      
      if x < 1 then return end
      
      if y < map.h -1 and isOpenTiles(x-1,y+1) then diagonal_tiles[#diagonal_tiles+1] = {x-1, y+1,         1} end
      if isOpenTiles(x-1,y) then cardinal_tiles[#cardinal_tiles+1]                      = {x-1, y,           4} end
      if y > 0 and isOpenTiles(x-1,y-1) then diagonal_tiles[#diagonal_tiles+1]        = {x-1, y-1,         7} end
    end,
    --Dir 5
    function(target_x, target_y, cardinal_tiles, diagonal_tiles)
      local x = target_x
	    local y = target_y

	    local left_okay = x > 0
	    local right_okay = x < map.w - 1
	    local lower_okay = y > 0
	    local upper_okay = y < map.h - 1


	    if upper_okay and isOpenTiles(x,y+1) then cardinal_tiles[#cardinal_tiles+1]                = {x,     y + 1,        2 } end
	    if left_okay  and isOpenTiles(x-1,y) then cardinal_tiles[#cardinal_tiles+1]                = {x - 1, y,            4 } end
	    if right_okay and isOpenTiles(x+1,y) then cardinal_tiles[#cardinal_tiles+1]                = {x + 1, y,            6 } end
	    if lower_okay and isOpenTiles(x,y-1) then cardinal_tiles[#cardinal_tiles+1]                = {x,     y - 1,        8 } end


	    if left_okay  and upper_okay and isOpenTiles(x-1,y+1)  then diagonal_tiles[#diagonal_tiles+1] = {x - 1, y + 1,        1 } end
	    if right_okay and upper_okay and isOpenTiles(x+1,y+1) then diagonal_tiles[#diagonal_tiles+1] = {x + 1, y + 1,        3 } end
	    if left_okay  and lower_okay and isOpenTiles(x-1,y-1) then diagonal_tiles[#diagonal_tiles+1] = {x - 1, y - 1,        7 } end
	    if right_okay and lower_okay and isOpenTiles(x+1,y-1) then diagonal_tiles[#diagonal_tiles+1] = {x + 1, y - 1,        9 } end

    end,
    --Dir 6
    function(target_x, target_y, cardinal_tiles, diagonal_tiles)
      local x = target_x
      local y = target_y
      
      if x > map.w -2 then return end
      
      if y < map.h - 1 and isOpenTiles(x+1,y+1) then diagonal_tiles[#diagonal_tiles+1]             = {x+1, y+1,            3} end
      if isOpenTiles(x+1,y) then cardinal_tiles[#cardinal_tiles+1]                                   = {x+1, y,              6} end
      if y > 0 and isOpenTiles(x+1,y-1) then diagonal_tiles[#diagonal_tiles+1]                     = {x+1, y-1,            9} end
    end,
    --Dir 7
    function(target_x, target_y, cardinal_tiles, diagonal_tiles)
      local x = target_x
      local y = target_y
      
      if x > 0 then
        if isOpenTiles(x-1,y+1) then diagonal_tiles[#diagonal_tiles+1]                                 = {x-1, y+1,            1} end
        if isOpenTiles(x-1,y) then cardinal_tiles[#cardinal_tiles+1]                                   = {x-1, y,              4} end
        if y > 0 then
          if isOpenTiles(x-1,y-1) then diagonal_tiles[#diagonal_tiles+1]                               = {x-1, y-1,            7} end
          if isOpenTiles(x,y-1) then cardinal_tiles[#cardinal_tiles+1]                                 = {x,   y-1,            8} end
          if isOpenTiles(x+1,y-1) then diagonal_tiles[#diagonal_tiles+1]                               = {x+1,   y-1,          9} end
        end
      elseif y > 0 then
          if isOpenTiles(x,y-1) then cardinal_tiles[#cardinal_tiles+1]                                 = {x,   y-1,            8} end
          if isOpenTiles(x+1,y-1) then diagonal_tiles[#diagonal_tiles+1]                               = {x+1,   y-1,          9} end
      end
    end,
    --Dir 8
	  function(target_x, target_y, cardinal_tiles, diagonal_tiles)
      local x = target_x
      local y = target_y
      
		  if y < 1 then return end

		  if x > 0 and isOpenTiles(x-1,y-1) then diagonal_tiles[#diagonal_tiles+1]                    = {x - 1, y - 1, 7 } end
		  if isOpenTiles(x,y-1) then cardinal_tiles[#cardinal_tiles+1]                                  = {x,     y - 1, 8 } end
		  if x < map.w - 1 and isOpenTiles(x+1,y-1) then diagonal_tiles[#diagonal_tiles+1]            = {x + 1, y - 1, 9 } end
	  end,
	  -- Dir 9
	  function(target_x, target_y, cardinal_tiles, diagonal_tiles)
      local x = target_x
      local y = target_y
      

		  if x < map.w - 1 then
			  if isOpenTiles(x+1,y+1) then diagonal_tiles[#diagonal_tiles+1]         = {x + 1, y + 1, 3 } end
			  if isOpenTiles(x+1,y) then cardinal_tiles[#cardinal_tiles+1]           = {x + 1, y    , 6 } end
			  if y > 0 then
				  if isOpenTiles(x-1,y-1) then diagonal_tiles[#diagonal_tiles+1]       = {x - 1, y - 1    , 7 } end
				  if isOpenTiles(x,y-1) then cardinal_tiles[#cardinal_tiles+1]         = {x,     y - 1    , 8 } end
				  if isOpenTiles(x+1,y-1) then diagonal_tiles[#diagonal_tiles+1]       = {x + 1, y - 1    , 9 } end
			  end
		  elseif y > 0 then
			  if isOpenTiles(x-1,y-1) then diagonal_tiles[#diagonal_tiles+1]         = {x - 1, y - 1, 7 } end
			  if isOpenTiles(x,y-1) then cardinal_tiles[#cardinal_tiles+1]           = {x,     y - 1, 8 } end
      end
	  end
}

function isOpenTiles(target_x, target_y)
  --print("doing " .. target_x ..','..target_y)
  local tile = map:getTile(target_x,target_y)
  if openTiles[target_x+1][target_y+1] == false and tile.id > 0  then
    openTiles[target_x+1][target_y+1] = true
    return true
  end
  return false
end

function clearOpenTiles() 
  openTiles = {}
  for x=1, map.w do
    openTiles[x] = {}
    for y=1, map.h do
      openTiles[x][y] = false    
      --print('open: ' .. x .. ',' .. y)
    end
  end  

end

function autoExplore()
  local running = true
  local iter = 1;
  local node = { player.x, player.y, 5 }
  local current_tiles = { node }
--new
	local values = {}
  local unseen_tiles = {}
	local unseen_singlets = {}
	local unseen_items = {}
	local exits = {}
	local minval = 999999999999999
	local minval_items = 999999999999999
-- parametros
	local extra_iters = 5     -- numero de iterações exras depois de achar um item ou tile não visto
	local singlet_greed = 5   -- numero de passos disposto a se mover para explorar um tile solitario
	local item_greed = 5      -- numero de passos disposto a se mover para pegar um item ao inves de explorar um tiel
  
  while running do
    local cardinal_tiles = {}
    local diagonal_tiles = {}	
    local current_tiles_next = {}

    for _, node in ipairs(current_tiles) do
			    adjacentTiles[node[3]](node[1],node[2], cardinal_tiles, diagonal_tiles)
			    --print(_)
    end
    
    os.execute("sleep 0.5")
    map:forceShowMap()
  
    --Cria um mapa de distancia para achar tiles não vistos e itens não vistos
    for id_Tipes, tile_list in ipairs({cardinal_tiles, diagonal_tiles}) do
        for id_Tile, node in ipairs(tile_list) do
            local x = node[1]
            local y = node[2]
            local c = toSingle(x,y)
            local from = node[3]
            
            if id_Tile > 2000 then
             print('2000 PLUS')
             break 
            end
            
            local tile = map:getTile(x,y)    
            if map:has_seens(x,y) then
              map:setTile(x,y,-1,5)
            else
              map:setTile(x,y,-1,6)
            end
            
            --Se não estiver na lista de iterados
            if not values[c] then
              if not map:has_seens(x, y) then
						    unseen_tiles[#unseen_tiles + 1] = c
						    values[c] = iter
						    if iter < minval then
							    minval = iter
						    end
                -- Tenta não abandonar tiles solitarios
						    local is_singlet = true
						    for _, anode in ipairs(listAdjacentTiles(x,y)) do
							    if not map:has_seens(anode[1], anode[2]) then
								    is_singlet = false
								    break
							    end
						    end
						    if is_singlet then
							    unseen_singlets[#unseen_singlets + 1] = c
							    map:setTile(x,y,-1,7)
							    print("singlet")
						    end
						  else --Se já tile visto, propaga para proxima iteração
						    if tile.id ~= 0 then
                  current_tiles_next[#current_tiles_next+1] = node
                end
                
                local obj = map:getObj(x, y, 0)
						    if obj and not obj.type == Obj.ENEMY then
							    unseen_items[#unseen_items + 1] = c
							    values[c] = iter
							    if iter < minval_items then
								    minval_items = iter
							    end
						    end
 						  end  --fim else
					  end  --fim values
					  
					end--endloop
				end--endloop
			
			
			--Continua se não encontrar itens ou tiles
			running = #unseen_tiles == 0 and #unseen_items == 0
			--Para se não houver mais tiles
			running = running and #current_tiles_next > 0
			--Itera mais vezes apos encontrar itens 
			if not running and extra_iters > 0 then
			  running = true
			  extra_iters = extra_iters - 1
		  end
			
	    current_tiles = current_tiles_next	    
      iter = iter + 1			
  end -- fim running
  
  --Escolhe alvo
  if #unseen_tiles > 0 or #unseen_items > 0 then
    local choices = {}
		local distances = {}
		local mindist = 999999999999999
		-- Tenta não deixar tiles sozinhos
		for _, c in ipairs(unseen_singlets) do
		  local x, y = toDouble(c)
		  map:setTile(x,y, -1, 6+values[c])
		  os.execute("sleep 0.3")
      map:forceShowMap()
      
			if values[c] <= minval + singlet_greed then
				choices[#choices + 1] = c
				local dist = values[c]
				distances[c] = dist
				if dist < mindist then
					mindist = dist
				end
			end
		end -- for Singlets
		--Pesquisa tiles
		for _, c in ipairs(unseen_tiles) do
		  local x, y = toDouble(c)
		  map:setTile(x,y, -1, 6+values[c])
		  os.execute("sleep 0.3")
      map:forceShowMap()
		end -- for Tiles
		
  end -- if has_seens
  
end



clearOpenTiles()

autoExplore()


