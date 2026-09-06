# M1 effects

Assets atuais: `ReplicatedStorage.Resources.M1Effects.Eclipse.Lunar`, com filhos `1`, `2`, `3`, `4`.

O servidor dispara `M1Effect` no marcador `hit`, usando a configuração capturada no começo do golpe. Todos os clientes reproduzem a mesma etapa. O efeito independe de acertar um alvo. O perfil Lunar não tem entradas Uppercut, Downslam ou Empowered, então esses golpes não reproduzem os novos efeitos. Os efeitos de impacto anteriores continuam funcionando.

Perfis ficam em `src/Shared/Modules/M1Effects/Profiles`. Cada ModuleScript exporta Path, Offset, Lifetime e Steps. O nome do módulo é o EffectProfile definido na configuração do M1 no servidor. Solar e Shattered não têm EffectProfile configurado.

O comportamento padrão aceita BasePart, Model ou Attachment. Clona o asset, posiciona no CFrame do golpe com offset local de 3 studs à frente, emite usando Utility("Particles") e remove após 2 segundos. As partes não colidem. Assets ausentes são ignorados. EmitCount, EmitDelay e EmitDuration usam o helper existente.

Cada entrada de Steps pode sobrescrever Asset, Offset, Lifetime e Play. Play também pode ser definido no perfil inteiro. Para lógica especial, use uma função `Play(context, playDefault)`. Ela recebe Character, Step, Template, CFrame, Lifetime, Emit e Debris. Chame `playDefault(context)` para criar o efeito padrão e receber `effect, container`, depois aplique tweens ou lógica adicional. Pode também substituir completamente a criação; nesse caso, agende a limpeza dos próprios objetos com context.Debris.

Para adicionar outra runa/modo: crie um módulo em Profiles, configure seu Path e Steps e defina EffectProfile na configuração correspondente de M1Handler. Para uppercut/downslam futuros, adicione explicitamente Steps.Uppercut ou Steps.Downslam ao perfil.

Validação pendente no Studio: executar os quatro M1s do Lunar, inclusive sem alvo; verificar posição, emissão e remoção; conferir que Solar, Shattered, uppercut e downslam não reproduzem estes assets. Não houve execução visual nesta sessão.