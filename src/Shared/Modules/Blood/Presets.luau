-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Bytecode (Base64):
-- BgMRBEZhY2ULU3ByZWFkQW5nbGUGQW1vdW50CFBvb2xTaXplBEVudW0ITm9ybWFsSWQFRnJvbnQHVmVjdG9yMgNuZXcPRmxvd2luZ1dhdGVySGl0B1NwaXRPdXQDVG9wCERvd25TbGFtBVBvd2VyEEJlYXRkb3duRmluaXNoZXIKQmlnU3BpdE91dAdEcmFnZ2VkAAEFAAABAgCJAaMAAAD/AAQAAAAAAOIBBACkAggABxhQwDACAQUAAAAApAILAAAokICMAw8AjAQPAJ8CAwIwAgHPAQAAAKQCCwAAKJCAjAMCAIwEAwCfAgMCMAIBKwIAAACMAgEAMAIBbAMAAAAwAQAHDAAAAOIBDQCkAggABxhQwDACAQUAAAAApAILAAAokICMAwQAjAQGAJ8CAwIwAgErAgAAAG8CDgAwAgFsAwAAADABADsPAAAA4gENAKQCEQAQGFDAMAIBBQAAAACkAgsAACiQgIwDBACMBAYAnwIDAjACASsCAAAAbwIOADACAWwDAAAAMAEAqxIAAADiARQApAIRABAYUMAwAgEFAAAAAKQCCwAAKJCAjANoAYwEaAGfAgMCMAIBzwEAAACkAgsAACiQgIwDDwCMBBQAnwIDAjACASsCAAAAbwIOADACAWwDAAAAjAIoADACAdMTAAAAMAEAnRUAAADiAQQApAIIAAcYUMAwAgEFAAAAAKQCCwAAKJCAjAM8AIwEPACfAgMCMAIBzwEAAACkAgsAACiQgIwDBgCMBAgAnwIDAjACASsCAAAAjAICADACAWwDAAAAMAEAnBYAAADiAQQApAIRABAYUMAwAgEFAAAAAKQCCwAAKJCAjANBAIwEQQCfAgMCMAIBzwEAAACkAgsAACiQgIwDAQCMBAIAnwIDAjACASsCAAAAbwIXADACAWwDAAAAMAEAqRgAAACCAAIAGQMBAwIDAwMEBQQAAQIDAwUDBgMHBAcYUMADCAMJBAAokIADCgUDAAIDAgAAAAAAAPg/AwsDDAQQGFDAAw0DDgUFAAECAxMDDwMQAgAAAAAAAPQ/AxEAAQABGAAAAAEBAAAAAAAAAAAAAAAAAAAAAAAAAAD/AAQBAAAAAAAAAAAAAAAAAP8ABAEAAAAAAAAAAAAAAAAA/wAEAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/wAEAQAAAAAAAAAAAAAAAAAAAAAAAAAA/wAEAQAAAAAAAAAAAAAAAAAAAAAAAAAA/wAAAQAAAAAAySY9umPntWD74lcubc2sHsw1vf8Amfkjqqt61OXlrq79YQkzf6HRCQ==

return {
    FlowingWaterHit = {
        Face = Enum.NormalId.Front, 
        SpreadAngle = Vector2.new(15, 15), 
        Amount = Vector2.new(2, 3), 
        PoolSize = 1
    }, 
    SpitOut = {
        Face = Enum.NormalId.Front, 
        Amount = Vector2.new(4, 6), 
        PoolSize = 1.5
    }, 
    DownSlam = {
        Face = Enum.NormalId.Top, 
        Amount = Vector2.new(4, 6), 
        PoolSize = 1.5
    }, 
    BeatdownFinisher = {
        Face = Enum.NormalId.Top, 
        SpreadAngle = Vector2.new(360, 360), 
        Amount = Vector2.new(15, 20), 
        PoolSize = 1.5, 
        Power = 40
    }, 
    BigSpitOut = {
        Face = Enum.NormalId.Front, 
        SpreadAngle = Vector2.new(60, 60), 
        Amount = Vector2.new(6, 8), 
        PoolSize = 2
    }, 
    Dragged = {
        Face = Enum.NormalId.Top, 
        SpreadAngle = Vector2.new(65, 65), 
        Amount = Vector2.new(1, 2), 
        PoolSize = 1.25
    }
};