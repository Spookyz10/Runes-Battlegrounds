local ClientContext = {}

ClientContext.LungeConnection = nil

ClientContext.SolarAimActive = false
ClientContext.SolarAimDirection = nil

ClientContext.LunarAimActive = false
ClientContext.LunarAimDirection = nil
ClientContext.LunarAimRestoreCamera = nil

ClientContext.Indicators = {}

ClientContext.DestroyedParts = {}

ClientContext.IsMobile = false
ClientContext.CustomShiftlockActive = false

return ClientContext
