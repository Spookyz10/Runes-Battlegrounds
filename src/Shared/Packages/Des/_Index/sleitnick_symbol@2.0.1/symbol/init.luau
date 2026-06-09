-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Bytecode (Base64):
-- BgMHB1N5bWJvbCgBKQhuZXdwcm94eQAMZ2V0bWV0YXRhYmxlCl9fdG9zdHJpbmcGU3ltYm9sAAMEAAEAAAAFbwEAAPsCAABvAwEAcwABA4IAAgACAwEDAgAyAAEYAAAAAAAzAAAAAAQBAAAABgMAAAUBgxGkAQEAAAAAQKkCAQCfAQICKwABAG8AAgC7PAEDUgMBAKQCBAAAADBAnwICAtkDAAASAQD/MAMCBgUAAADBAAAAggECAAYDAwQAAABAAwQDBQQAADBAAwYBAC0HARgAAAAAAQECAAAAAAAAAAADAC4AAAAAAQAAAQIAA6MAAADAAAAAggACAAEGAQEBAQABGAAsCwEAAAAAAjndnSGTHBX7Cxn3tRz/J5r8Wbp7Ki4WnRnm9fTAEawQdNzPPnHuneU=

return function(v0) --[[ Line: 45 ]] --[[ Name: Symbol ]]
    local v1 = newproxy(true);
    if not v0 then
        v0 = "";
    end;
    getmetatable(v1).__tostring = function() --[[ Line: 50 ]]
        -- upvalues: v0 (ref)
        return "Symbol(" .. v0 .. ")";
    end;
    return v1;
end;