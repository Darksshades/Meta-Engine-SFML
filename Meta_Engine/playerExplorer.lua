local function toSingle(x, y)
	return x + y * map.w
end

local function toDouble(c)
	local y = math.floor(c / map.w)
	return c - y * map.w, y
end

local function showDelay(tempo)
  os.execute("sleep ".. tempo)
  map:forceShowMap()
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
  if openTiles[target_x+1][target_y+1] == false and tile.type > 0  then
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

--Checa se precisa efetuar outra pesquisa por rotas.
--Muda rota se chegar no destino. Tiver inimigos na visão.
--Ou não possuir novos tiles explorados
function checkExplore()
    
  if player:isRota() then 
    local posTarget = player:getRotaTarget()
    --Se não houver tiles novos, e estiver vendo o destino, beco.
    if player.mHasNewTiles == false and map:has_seens(posTarget.x, posTarget.y) then
      --print('Sem tiles novos, possivel beco.')
      return false
    end
    --print('N_Enemy/ENEMY ... ' .. n_enemy ..','..player.mHasEnemys)
    if player.mHasEnemys ~= n_enemy then
      --print('Inimigo novo avistado, explorando opções.')
      return false
    end
    --print('Rota ainda e valida, movendo.')
    return true
  end
  
  
  
    
  
  --print('Chegou ao alvo, obtendo nova rota..')
  return false

end

--Checa todos os tiles visiveis até encontrar um tile não explorado.
--explora extra_iters iterações adicionais por novos tiles antes de terminar.
--Cria lista de possiveis alvos e gera rota.
--Explora rota caso existente ao inves de buscar por tiles.
function autoExplore()

  if checkExplore() then
    player:moveRota()
    return
  end
  
  local running = true
  local iter = 1;
  local node = { player.x, player.y, 5 }
  local current_tiles = { node }
--new
	local values = {}
  local unseen_tiles = {}
	local unseen_singlets = {}
	local unseen_items = {}
	local unseen_enemys = {}
	local exits = {}
	local minval = 999999999999999
	local minval_items = 999999999999999
	local minval_enemys = 999999999999999
-- parametros
	local extra_iters = 5     -- numero de iterações exras depois de achar um item ou tile não visto
	local singlet_greed = 5   -- numero de passos disposto a se mover para explorar um tile solitario
	local item_greed = 5      -- numero de passos disposto a se mover para pegar um item ao inves de explorar um tiel
  local fear_factor = 2     -- numero de inimigos por perto máximo para executar um ataque.
  -- Realizar conta de fear_factor baseado em atk,def,hp do inimigo futuramente
  -- Fazer com que fugir não entre num loop
  
  n_enemy = player.mHasEnemys
  
  while running do
    local cardinal_tiles = {}
    local diagonal_tiles = {}	
    local current_tiles_next = {}

    for _, node in ipairs(current_tiles) do
			    adjacentTiles[node[3]](node[1],node[2], cardinal_tiles, diagonal_tiles)
			    --print(_)
    end
    
    ----showDelay(0.5);
  
    --Cria um mapa de distancia para achar tiles não vistos e itens não vistos
    for _, tile_list in ipairs({cardinal_tiles, diagonal_tiles}) do
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
              -- map:setTile(x,y,5,-1)
              -- showDelay(100)
            else
              -- map:setTile(x,y,6,-1)
              -- showDelay(100)
            end
            
            --Se não estiver na lista de iterados
            if not values[c] then
              if not map:has_remembers(x, y) then
                --Se não visto, coloca como escolha de exploração
						    unseen_tiles[#unseen_tiles + 1] = c
						    values[c] = iter
						    if iter < minval then
							    minval = iter
						    end
                -- Tenta não abandonar tiles solitarios
						    local is_singlet = true
						    local single_n = 1
						    for _, anode in ipairs(listAdjacentTiles(x,y,false,false)) do
							    if not map:has_remembers(anode[1], anode[2]) then
								    if single_n > 1 then -- Se tiver 2 tiles visiveis em volta, não é singlet 
								      is_singlet = false
								      break
								    end
								    single_n = single_n+1
							    end
						    end
						    if is_singlet then
							    unseen_singlets[#unseen_singlets + 1] = c
							    ----map:setTile(x,y,-1,7)
							    --print("singlet")
						    end
						  else --Se já tile visto e não for bloco, propaga para proxima iteração
					      --Se objeto for um item, adiciona a lista de itens
                local obj = map:getItem(x, y, 0)
                
				        if obj then
				          if obj.type == Obj.ITEM then
					          unseen_items[#unseen_items + 1] = c
					          values[c] = iter
					          if iter < minval_items then
						          minval_items = iter
					          end
					        end
					      end
					      
					      local obj = map:getObj(x,y)
				        if obj then --É um inimigo
				          unseen_enemys[#unseen_enemys + 1] = c
				          values[c] = iter
				          if iter < minval_enemys then
					          minval_enemys = iter
				          end
				        end --end inimigo			
				        
				        
				        if tile.type == Tile.END then
				          unseen_tiles[#unseen_tiles + 1] = c
					        values[c] = iter
					        if iter < minval then
						        minval = iter
					        end
				        end
						    if tile.type ~= 0 then
                  current_tiles_next[#current_tiles_next+1] = node
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
    local priorityChoise = {}
    local choices = {}
		local distances = {}
		local mindist = 999999999999999
		-- Tenta não deixar tiles sozinhos
		for _, c in ipairs(unseen_singlets) do
		  local x, y = toDouble(c)
		  ----map:setTile(x,y, -1, 6+values[c])
		  ----os.execute("sleep 0.3")
      ----map:forceShowMap()
      
			if values[c] <= minval + singlet_greed then
				choices[#choices + 1] = c
				local dist = values[c]
				distances[c] = dist
				if dist < mindist then
					mindist = dist
				end
			end
		end -- for Singlets
		-- So entra se valorMinimo + item_greed, e se singlets não entram.
		if #choices == 0 or minval_items <= minval + item_greed then
		  for _, c in ipairs(unseen_items) do
		    choices[#choices+1] = c
		    local dist = values[c]
				distances[c] = dist
		    if dist < mindist then
		       mindist = dist
		    end
		  end
		end -- fim For itens
		--Pesquisa tiles se 0 escolhas, ou seja, itens não entraram.
		if #choices == 0 then
		  for _, c in ipairs(unseen_tiles) do
		    local x, y = toDouble(c)
		    ----map:setTile(x,y, -1, 6+values[c])
		    ----os.execute("sleep 0.1")
		    ----map:forceShowMap()
		    choices[#choices + 1] = c
		    local dist = values[c]
				distances[c] = dist
        if dist < mindist then
		       mindist = dist
		    end
        
        local tile = map:getTile(x,y)
        if tile.type == Tile.END then
          priorityChoise[#priorityChoise + 1] = c
        end
		  end -- for Tiles
		end -- fim if Choices
		
    --print('escolhendo alvos(#' .. #choices ..' alvos)')
    if #choices > 1 then
      local choices2 = {}
      for _, c in ipairs(choices) do
        if distances[c] == mindist then
          choices2[#choices2+1] = c
        end
      end --fim for
      choices = choices2
    end--fim if
-- Aqui entra a logica de escolha de caminho, já filtrando por menor.
    local target = #choices > 1
    if target == true then
		   target = math.random(#choices)
		else 
		   target = 1
		end
		
		if target == 0 then
		  return
		else
		  local t_x, t_y = toDouble(choices[target])
		  --Sempre prioritiza a saida
		  if #priorityChoise ~= 0 then
		    t_x, t_y = toDouble(priorityChoise[1])
		  end
		  
		  --print('alvo escolhido(' .. t_x .. ',' .. t_y .. ')')
		  player:geraRota(t_x,t_y)
		  player:moveRota()
		end
		
  end -- if has_seens
  
end

function autoExploreOld()
    local moved = false
    for _, node in ipairs(listAdjacentTiles(player.x, player.y,false, false)) do
      local tile = map:getTile(node[1], node[2])
      -- Se puder andar no tile, puder ver, e não tiver passado
      
      if tile.type ~= 0 and map:has_seens(node[1], node[2]) and map:has_passed(node[1], node[2]) == false then 
        print('movendo ' .. node[1] .. ',' .. node[2] .. ' para ' .. node[3])
        player:move(node[3])
        moved = true
        break
      end
    end
    if moved == false then
      local dir = math.random(8)
      if(dir == 5) then 
        dir = dir+1
      end
      player:move(dir);
    end
end





clearOpenTiles()
autoExplore()
--autoExploreOld()

