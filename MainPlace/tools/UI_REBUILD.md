# Interfaces novas

Sincronize os scripts e, fora do Play, execute cada arquivo inteiro na Command Bar do Studio:

1. GenerateShopUI.luau
2. GenerateCosmeticsUI.luau
3. GenerateKillSoundUI.luau
4. GenerateLogUI.luau

Salve o place. N?o crie Store: a ScreenGui Shop substitui as duas lojas e usa um ?nico bot?o na topbar. Os geradores s?o independentes, n?o precisam de m?dulos em edit mode e recusam sobrescrever uma ScreenGui existente. Se precisar gerar novamente, mova a vers?o antiga para ServerStorage como backup.

Todas come?am desativadas, usam ScreenInsets = DeviceSafeInsets, n?o t?m backdrop e usam Scale/TextScaled. Main captura a intera??o sobre a janela; o resto do cen?rio continua livre. O X, Escape e bot?o B fecham a janela. A topbar sincroniza o estado ao fechar e mant?m apenas uma dessas janelas aberta.

Shop: abas Auras, Rune cosmetics, Rune skins e Robux. O cat?logo gold continua em Shared.Info.Shop. O cat?logo de passes est? em Shared.Info.Store, com os tr?s passes encontrados no c?digo: VIP, Early Access e Kill Sound. Pre?os e imagens v?m do MarketplaceService, e a compra abre o prompt Roblox. OwnedPasses ? atualizado pelo servi?o existente no servidor, n?o pelo cliente. Produtos de doa??o da UI Misc continuam no fluxo existente.

Cosmetics: cat?logo em Shared.Info.Cosmetics. Rune cosmetics usam ModelPath ou Resources.RuneCosmetics.<Id>; auras usam Image. Campos opcionais Description, Image e ModelPath personalizam os cards. Itens bloqueados oferecem Visit shop; itens possu?dos permitem Equip/Unequip via servi?o existente. O estado Equipped vem dos atributos replicados pelo servidor. Rune skins continua em Coming soon.

KillSound: entrada de ID ou URL, Preview/Stop local de at? dez segundos e Save sound. A pr?via para ao fechar. Apenas donos do passe veem o bot?o na topbar, e o servidor verifica o passe ao salvar. A pr?via depende das permiss?es do ?udio no Roblox.

Log: dados em Shared.Info.Log. UpdateLog, Roadmap e Version alimentam as duas abas e os cards numerados.

Edite as UIs e Templates diretamente no StarterGui. Os templates Item e Entry come?am com Visible=false; a l?gica clona e mostra apenas as inst?ncias necess?rias. Para inspecionar um template no editor, duplique para seu Content e ative Visible temporariamente. Remova a c?pia antes de salvar.

Valida??o manual no Studio: conferir as quatro janelas em desktop/celular, X e topbar, alternar entre gold e Robux, conferir pre?o e propriedade dos passes, cancelar um prompt, equipar/desequipar Crown, testar ?udio e salvar ID, abrir Updates/Roadmap e respawnar. Confirmar que nenhuma janela/template aparece no startup.

Foram conferidos a codifica??o sem BOM, os contratos de nomes entre geradores e l?gica, a aus?ncia de depend?ncias de Store/Backdrop e git diff --check. N?o houve execu??o ou inspe??o visual no Studio nesta sess?o.

Refer?ncias de API verificadas: https://create.roblox.com/docs/reference/engine/classes/MarketplaceService e https://create.roblox.com/docs/reference/engine/enums/ScreenInsets.
