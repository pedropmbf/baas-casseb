# Roteiro do vídeo: Circuito de Descobertas

**Integrantes:** P1, P2 e P3 (troque pelos nomes).
**Duração alvo:** 6 a 8 minutos.
**Como gravar:** OBS grava a tela, sem áudio. Depois cada um grava a narração da sua parte no celular, e tudo é juntado no Clipchamp.

---

## Antes de gravar (checklist, uns 10 minutos)

- [ ] **Check-ins de teste apagados**, para os totais começarem em 0. Em **Firestore → Dados → checkins**, clique nos ⋮ da coleção e escolha **Excluir coleção**. Ou rode no terminal do projeto: `firebase firestore:delete checkins --recursive --force`.
- [x] **App desinstalado do emulador.** Já feito.
- [x] **`missao_ativa` em `false`** no Remote Config. Já está.
- [ ] **Parede virtual da câmera com o QR do AçaíTech.** No emulador, abra **⋯ → Camera → Wall** e escolha `qr-codes\acaitech-ativo.png`.
- [ ] **Acesso ao GA4 com um Gmail pessoal**, porque a conta do CESUPA bloqueia o Analytics. Faça uma única vez:
  1. Com a conta do CESUPA, no console do Firebase, abra **⚙ → Usuários e permissões → Adicionar membro**, coloque o Gmail pessoal e escolha **Proprietário**.
  2. Aceite o convite no Gmail pessoal.
  3. Numa **janela anônima** do Chrome logada com esse Gmail, abra https://analytics.google.com, vá em **Relatórios → Tempo real** e deixe a aba aberta.
- [ ] **Janelas organizadas lado a lado:**
  - **Esquerda:** o emulador Android.
  - **Direita:** o Chrome com três abas: o painel (http://localhost:5173, já logado como admin), o **Remote Config** do console e o **GA4 Tempo real** (na janela anônima).
- [ ] **OBS:** "Captura de tela" do monitor inteiro, em 1080p e 30 fps, **com o microfone desligado**.

> Dica: entre uma etapa e outra, pare dois segundos sem mexer em nada. Assim fica fácil cortar e encaixar a narração depois.

---

## ABERTURA: os 3 integrantes (cerca de 20 s)

Cada integrante grava 5 segundos de webcam ou celular, olhando para a câmera:

> "Olá, eu sou **[nome]**, e junto com [nomes] vamos apresentar o Circuito de Descobertas."

Na edição, coloque os três clipes em sequência no começo do vídeo. Isso cobre o "apresente os integrantes" e mostra que todos participaram.

---

## PARTE 1: P1 narra. App Distribution e painel (≈ 2 min)

### 1.1 Instalação pelo App Distribution (vale 1,0 pt)

| Ação na tela | O que P1 narra |
|---|---|
| No emulador, abrir o app **App Tester** (ícone do Firebase) | "O APK assinado foi distribuído pelo **Firebase App Distribution**, uma alternativa gratuita à Play Store. Eu fui convidado como testador." |
| Mostrar o app **Circuito de Descobertas, versão 1.0.1** na lista | "Aqui está a versão disponível para mim, a 1.0.1." |
| Tocar em **Baixar** e depois em **Instalar**, permitindo apps desconhecidos se pedir | "Vou baixar e instalar essa versão." |
| Tocar em **Abrir** | "O app abre, cria uma sessão anônima de visitante e já lista os estandes ativos da feira." |

### 1.2 Cadastro no painel → aparece no app

| Ação na tela | O que P1 narra |
|---|---|
| No Chrome, mostrar o painel logado | "Este é o **painel web da organização**, feito em React. O administrador entra com e-mail e senha pelo **Firebase Authentication**." |
| Preencher **Novo estande**: Nome `LibrasJá — Tradutor de Libras`, Descrição `App que traduz frases em português para Libras com avatar 3D.`, Localização `Corredor A · Estande 07`, com **Ativo** marcado. Clicar em **Cadastrar estande** | "Vou cadastrar um estande novo. Ele é gravado no **Cloud Firestore**." |
| Voltar ao emulador e mostrar o estande novo na lista | "Sem recarregar nada, o estande novo já aparece no app do visitante." |
| No painel, clicar em **QR code ↗** do LibrasJá | "Cada estande tem um QR code gerado a partir do seu identificador. Esta página pode ser aberta em outra tela ou impressa." |

---

## PARTE 2: P2 narra. Remote Config e check-in (≈ 2 min 30)

### 2.1 Ligar a missão (vale 1,0 pt)

| Ação na tela | O que P2 narra |
|---|---|
| Mostrar o app **sem** a chamada de missão | "Agora vou mostrar o **Firebase Remote Config**. Hoje a missão surpresa está desligada, que é o padrão local do app." |
| Na aba do Remote Config: lápis em `missao_ativa`, mudar para **true**, **Salvar** e depois **Publicar alterações** | "No console eu mudo `missao_ativa` para verdadeiro e publico. O parâmetro `missao_estandes` define quais estandes participam." |
| Voltar ao emulador **sem fechar o app** e esperar uns 5 segundos até a chamada aparecer | "Sem recompilar e sem reinstalar, o mesmo app recebeu a mudança em tempo real. Apareceu a chamada da missão, e os estandes participantes ganharam a estrela de destaque." |

### 2.2 Abrir a missão e fazer o check-in

| Ação na tela | O que P2 narra |
|---|---|
| Tocar no cartão **Missão surpresa!** | "Abro a missão e vejo os estandes participantes e o meu progresso. Essa abertura gera o evento `missao_aberta` no Analytics." |
| Tocar em **Fazer check-in**. Na câmera, segurar **Alt** e usar **W A S D** e o mouse até enquadrar o QR na parede | "Agora leio o QR code do estande **AçaíTech** pela câmera." |
| Aparece **Check-in confirmado!** Tocar em **OK** | "O app validou que o estande existe e está ativo, gravou o check-in e confirmou o sucesso. O progresso da missão subiu." |
| Ir ao painel: o **AçaíTech** aparece com total **1**, a linha pisca, e o check-in aparece em "Últimos check-ins" | "No painel da organização, o total de check-ins do AçaíTech subiu para 1. Ele é calculado a partir dos registros no Firestore." |

### 2.3 Retornos de erro (opcional, cerca de 30 s)

| Ação na tela | O que P2 narra |
|---|---|
| **Fazer check-in** de novo no mesmo QR → **Visita já registrada** | "Cada visitante só registra uma visita por estande." |
| *(pausar)* Trocar a parede para `visao-amazonica-INATIVO.png` e ler → **Estande inativo** | "Um estande inativo é recusado." |
| *(pausar)* Trocar a parede para `qr-invalido.png` e ler → **QR inválido** | "E um QR que não é do circuito também é recusado." |

> Volte a parede para `acaitech-ativo.png` no final, para não confundir numa regravação.

### 2.4 Desligar a missão

| Ação na tela | O que P2 narra |
|---|---|
| No Remote Config, mudar `missao_ativa` para **false**, **Salvar** e **Publicar** | "Agora desligo a missão no console." |
| No emulador, mostrar a chamada e as estrelas sumindo, e rolar a lista | "A chamada e os destaques saíram, mas a lista normal e o check-in continuam funcionando." |

---

## PARTE 3: P3 narra. Analytics e fechamento (≈ 1 min 30)

### 3.1 GA4 Tempo real (vale 1,0 pt)

> ⏸ Se os eventos ainda não apareceram, **pause a gravação** e retome quando aparecerem (o PDF permite). Costuma levar de 1 a 5 minutos.

| Ação na tela | O que P3 narra |
|---|---|
| Na janela anônima, abrir **GA4 → Relatórios → Tempo real** | "Agora o **Google Analytics para Firebase**. Este é o relatório Tempo real do GA4." |
| No cartão **"Contagem de eventos por nome do evento"**, apontar `missao_aberta` e `checkin_concluido` | "Aqui estão os dois eventos que o app registrou: `missao_aberta`, quando abrimos a missão, e `checkin_concluido`, quando o check-in deu certo." |
| Clicar em `checkin_concluido` e depois no parâmetro **`estande_id`** | "Abrindo o evento de check-in, vemos o parâmetro `estande_id`…" |
| Mostrar o valor `GrUVFjnxg8Habjyw3QQ6` e, no painel, o mesmo ID embaixo do nome **AçaíTech** | "…com o valor `GrUVFjnxg8Habjyw3QQ6`, que é exatamente o identificador do estande AçaíTech no painel. Todos os dados são fictícios." |

### 3.2 Fechamento: demonstração integrada (vale 0,5 pt)

| Ação na tela | O que P3 narra |
|---|---|
| Mostrar rapidamente o painel, depois o app, depois o GA4 | "Recapitulando o percurso completo: o estande cadastrado no painel apareceu no app, a missão foi ligada e desligada pelo Remote Config, o check-in atualizou o total no painel, e o evento correspondente chegou ao Analytics. Tudo no plano gratuito Spark do Firebase. Obrigado!" |

---

## Edição (Clipchamp)

1. Importe a gravação da tela, os 3 clipes de abertura e os 3 áudios de narração.
2. Ordem: abertura (P1, P2, P3), depois a Parte 1 com o áudio de P1, a Parte 2 com o áudio de P2 e a Parte 3 com o áudio de P3.
3. Corte as esperas, principalmente a do GA4. Se quiser, acelere a parte do download do APK.
4. Opcional: coloque um texto no canto em cada parte, com o serviço e o narrador (por exemplo, "Remote Config · narração: P2").
5. Exporte em 1080p. **Cada integrante envia o mesmo vídeo individualmente.**

## Se algo der errado na hora

| Problema | Solução |
|---|---|
| A missão não aparece depois de publicar | Espere 10 s. Se não vier, minimize o app e abra de novo (ele busca a configuração ao voltar). |
| A câmera não acha o QR | Com Alt + W, chegue mais perto da parede. Confira em **⋯ → Camera** se a imagem certa está na Wall. |
| "Visita já registrada" no primeiro check-in | O check-in desse visitante já existe. Use outro estande da missão (EcoRota: `ecorota-ativo.png`). |
| Os eventos não aparecem no GA4 | Pause a gravação e espere até 5 min. Eles chegam. |
