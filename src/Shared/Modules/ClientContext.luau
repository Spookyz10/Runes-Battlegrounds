local ClientContext = {}

ClientContext.IsMobile = false

ClientContext.LungeConnection = nil

ClientContext.SolarAimActive = false
ClientContext.SolarAimDirection = nil

ClientContext.LunarAimActive = false
ClientContext.LunarAimDirection = nil
ClientContext.LunarAimRestoreCamera = nil

ClientContext.Indicators = {}

ClientContext.DestroyedParts = {}

ClientContext.repfire = nil
ClientContext.clearVelocities = nil
ClientContext.detectAir = nil

ClientContext.addshake = nil
ClientContext.sustainshake = nil
ClientContext.shake = nil

ClientContext.triggerHotbar = nil
ClientContext.triggerAwkbar = nil
ClientContext.triggerTopbar = nil

return ClientContext
