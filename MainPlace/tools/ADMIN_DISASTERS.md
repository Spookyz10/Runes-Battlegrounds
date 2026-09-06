# Admin panel and volcanic eruption

Run tools/GenerateAdminUI.luau in the Studio Command Bar outside Play, then save the place. Keep the Notifications ScreenGui generated previously; the event uses the same notification system. No extra disaster UI generator is needed: impact indicators and lava are temporary world effects.

Only UserIds 531376199 and 1016292619 get the Admin topbar icon. Other clients remove the panel, and the server independently rejects every unauthorized Admin RemoteFunction request. IDs are configured in Shared.AdminAccess. The panel uses English, DeviceSafeInsets, Scale/TextScaled and no backdrop.

Required place assets:

- Workspace.VolcanoPart: a BasePart positioned at the volcano outlet.
- VolcanoPart.Passive: children ParticleEmitters, enabled during the event and disabled when stopped.
- Workspace.Map.Arena: a BasePart, Model or folder containing the arena ground. Target raycasts include this hierarchy. Terrain/map geometry is also considered when checking projectile collisions.
- ReplicatedStorage.Resources.Effects.VolcanoExplosion: BasePart, Model or Attachment containing emitters with the usual EmitCount/EmitDelay/EmitDuration attributes. The clone is removed after two seconds.
- Lighting's existing Atmosphere, Bloom, DepthOfField and SunRays are changed and restored. Sky instances are never edited or replaced.

Admin commands:

- Target accepts a UserId or exact username, not DisplayName.
- Gold adds 1-100000000 to the saved balance. Admin grants also work in private servers; gameplay gold rewards remain disabled there.
- Cosmetic/Aura use case-sensitive IDs from Shared.Info.Cosmetics (Crown/VIP currently).
- Skin records an ID in OwnedRuneSkins. There is still no rune skin renderer or equip system.
- Gamepass accepts configured pass IDs from Shared.Info.Store. These are in-game entitlement grants, not purchases or transfers of Roblox platform ownership. VIP also grants Crown and VIP aura immediately.
- Kick and Ban require a second click to confirm. Ban duration is days, or -1 for permanent; a reason is required. Unban removes an experience-wide ban. Enable Players.BanningEnabled in Studio for the native Ban API.
- Start/Stop eruption uses This server or All servers. Starting during an eruption replaces the previous event and starts a fresh five-minute duration.

Cross-server grants and kicks use Data.Service:sendGlobalMessage and addGlobalCallback. Local targets are handled directly. Queued reward commands expire after 24 hours, kick commands after 60 seconds. Rewards may therefore apply on rejoin within that window. Processed command IDs are stored alongside player data to reject duplicate deliveries. The UI reports queued, not delivered, for remote targets. Ban/unban uses Roblox's native experience-wide API. Global disasters use MessagingService and target active subscribed servers; new servers start their own local timer. MessagingService delivery is asynchronous and not guaranteed by Roblox. Cross-server behavior must be tested in a published experience with the necessary API access, not assumed from one Studio session.

Automatic schedule: ten-minute rest, warnings at ten and five minutes, then every second from ten to one. Eruption lasts five minutes, then all active projectiles/indicators are cleared, passive emission stops, lighting returns to its saved values and a fresh ten-minute timer starts. Joining players receive a current-event/timer notice. Countdown notices replace the previous disaster notice instead of stacking ten toasts.

During eruption each three-second volley snapshots the server player count N and launches 3N lava cubes of 20x20x20: one aimed near each living player inside Arena, plus 2N with random arena targets. The targeted slot also uses a random point if that player is dead, has no character or is outside Arena. Empty servers launch no cubes. Targets are raycast onto Arena; failed ground searches skip that projectile. The server computes a gravity-based arc and checks a swept 10-stud sphere against map geometry. Clients render the timed arc and spin smoothly; the indicator fades from transparency one toward zero over flight time. Obstacles may intercept a rock before its marked destination. On impact the server applies a 20x20x20 area for 15 environmental damage, strong upward/outward knockback and five seconds of ragdoll, respecting iFrames. There is no player credited for environmental kills. The explosion is cosmetic and cannot cause client-authoritative damage.

Extend disasters by adding a module under Modules.Disasters and registering it in DisasterService.Catalog. A disaster exports Name, Duration and Start returning a cleanup function. The current Lighting preset is in DisasterLighting; add per-event lighting presets when adding other event types.

Validation completed: git diff --check, UTF-8 without BOM, generator/controller name contracts and 1000 randomized ballistic endpoint calculations. Studio execution, visual inspection, actual collisions/ragdoll, ban API calls and delivery between two published servers remain untested. No real moderation action or grant was executed during development.

Manual test: open Admin using an authorized account, start locally, confirm all four Lighting children change, inspect Passive, target indicators and impacts, stop early, verify lighting/particles/projectiles clean up, restart and let the full five minutes finish. Use two published test servers for remote grants/kick and a global eruption. A non-admin calling the remote must receive Not authorized.

API references:
https://leifstout.github.io/dataServiceTyped/docs/service-functions/
https://create.roblox.com/docs/reference/engine/classes/Players
