eturn {
	["BezierCurve"] = function(p52, p53, p54, p55)
		return p52:Lerp(p53, p55):Lerp(p53:Lerp(p54, p55), p55)
	end
}
