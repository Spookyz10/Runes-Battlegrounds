# Shop e notificações

Com o Rojo sincronizado e o Studio fora do Play, copie e execute na Command Bar cada arquivo inteiro:

1. `tools/GenerateShopUI.luau`
2. `tools/GenerateNotificationUI.luau`

Salve o place. Os geradores criam `StarterGui.Shop` e `StarterGui.Notifications`. Não entram no jogo pelo Rojo e recusam sobrescrever interfaces existentes. Para gerar novamente, renomeie a interface anterior. Edite cores, posições, textos e templates diretamente no Explorer. O botão Shop aparece na topbar quando a interface está presente.

`Shop.Templates.Item` é o card reutilizável; `Notifications.Templates.Toast` é a notificação. Durante Play, a lógica clona esses templates. Para visualizar os templates no editor, duplique temporariamente Item para Main.Content ou Toast para Stack, ative Visible na cópia e Enabled na ScreenGui, e remova as cópias antes de salvar. Os templates originais devem permanecer com Visible desativado. Para visualizar a janela, habilite Shop; deixe Enabled desativado antes de salvar.

O catálogo fica em `src/Shared/Info/Shop.luau`. Adicione um item com Id, Category, Name, Description e Price. Auras usam Image com `rbxassetid://...`. RuneCosmetics usam ModelPath, uma lista de nomes a partir de ReplicatedStorage. Cadastre também o Id em `src/Shared/Info/Cosmetics.luau` para permitir compra/equipamento. O modelo da Crown usa `ReplicatedStorage.Resources.RuneCosmetics.Crown`. A prévia gira a câmera ao redor do modelo e ajusta a distância ao tamanho disponível.

RuneSkins tem apenas uma aba de “Em breve”; não há compra, inventário ou equipamento de skins implementado. Ativar essa categoria futuramente exige implementar seu sistema antes de liberar o catálogo.

Crown custa 100000 gold e entra em OwnedRuneCosmetics. Equipe pelo menu Cosmetics existente. VIP continua recebendo Crown gratuitamente; jogadores que já possuem a Crown veem “Owned”.

O servidor concede +10 gold ao jogador que causa o golpe fatal em outro jogador, uma vez por personagem morto. NPCs e suicídios não rendem gold. Também concede +25 a cada 300 segundos após carregar os dados, independentemente de respawn; sair reinicia o intervalo. Servidores privados e reservados não concedem nenhuma dessas recompensas. Compras continuam disponíveis nesses servidores.

Notificações são enviadas pelo servidor usando `require(game.ServerStorage.Modules.NotificationService).Send(player, true, "Mensagem")`; use false para erro. O RemoteEvent é `ReplicatedStorage.Remotes.Client.Notification`, criado pelo RemoteManager. Há no máximo três notificações visíveis, fechamento manual e typewriter com MaxVisibleGraphemes e expiração 4,5 segundos depois de revelar o texto. Notifications inicia com Enabled desativado e só é habilitada enquanto houver notificações ativas.

Validação no Studio:

- Inicie com as duas interfaces geradas e abra/feche Shop pela topbar, pelo X.
- Confira a janela em desktop e celular; em telas estreitas o catálogo usa uma coluna.
- Em uma conta sem Crown, tente comprar sem saldo: deve receber erro vermelho e manter saldo/inventário.
- Em uma sessão de teste, pelo servidor, use `require(game.ReplicatedStorage.Shared.Data).server[player].Gold(100000)` substituindo player pelo Player de teste. A compra deve zerar esse saldo, conceder uma Crown e mostrar sucesso verde. Esse saldo é persistente: use dados de teste.
- Clique repetidamente; não deve haver compra duplicada. Entre novamente e confira o inventário.
- Mate outro jogador: +10 ao saldo anterior. Mate NPC: nenhum gold. Aguarde cinco minutos: +25 e notificação.
- Repita em servidor privado/reservado: nenhuma recompensa de gold.
- Confira que a Crown adquirida equipa pelo Cosmetics e que o benefício VIP continua funcionando.

Foram consultados os docs fornecidos e a implementação local de DataServiceTyped 1.0.4. Não houve execução no Studio nesta sessão. O build Rojo não pôde rodar porque o binário configurado no Aftman não está instalado.

Os geradores atualizados usam textos em inglês e UTF-8 sem BOM. Shop ocupa 62% da largura e altura; a pilha de notificações ocupa 26% da largura. Para substituir a versão anterior, renomeie as ScreenGuis antigas e mova-as para ServerStorage como backup antes de executar novamente os dois geradores. Não deixe as versões antigas no StarterGui.

A Shop agora inclui a aba Robux (VIP, Early Access e Kill Sound), usa DeviceSafeInsets e n?o possui backdrop. N?o gere uma ScreenGui Store. Veja UI_REBUILD.md para os quatro geradores novos.
