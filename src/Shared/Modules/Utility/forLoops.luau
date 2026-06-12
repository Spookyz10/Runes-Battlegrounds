return {
	
	pairsForLoop = function(func, _table)
		for i,v in pairs(_table) do
			_table[i] = func(v)
		end
		
		return _table
	end,
	
	tableForLoop = function(func, _table)
		for i,v in _table do
			_table[i] = func(v)
		end
		
		return _table
	end,
	
}
