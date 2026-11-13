# Narração por tempo: Circuito de Descobertas

Vídeo: `2026-11-13 10-54-29.mp4` (8min15s). **Os tempos abaixo são do vídeo original, antes dos cortes.**

| Cena | Narrador | Trecho | Serviços |
|---|---|---|---|
| 1 | **Yuri** | 0:00 – 2:32 | App Distribution, Authentication, Firestore, painel e QR |
| 2 | **Pedro** | 2:32 – 6:57 | Remote Config e check-in |
| 3 | **Rath** | 6:57 – 8:15 | Analytics e fechamento |

---

## ⚠️ Antes de editar (obrigatório)

1. **CORTE de 1:03 a 1:20.** O Notepad++ mostra o e-mail e a **senha do admin** em texto aberto. Remova o trecho inteiro e, por segurança, **troque a senha** desse usuário em Firebase → Authentication → Usuários → ⋮ → Redefinir senha.
2. **Abertura com os 3:** antes do 0:00, coloque 3 a 5 segundos de cada um na câmera dizendo o nome. O PDF pede "apresente os integrantes".
3. Opcionais, para o vídeo ficar mais enxuto:
   - **3:22–3:29:** o console mostra "Ocorreu um erro geral", que é passageiro. Pode cortar.
   - **4:33–4:58** e **6:03–6:22:** troca da imagem da parede virtual. Pode acelerar 2x.

> Ritmo: fale com calma, cerca de 2,5 palavras por segundo. Se a fala passar do trecho, congele o último quadro na edição.

---

## CENA 1: Yuri (0:00 – 2:32)

| Tempo | O que aparece | Fala |
|---|---|---|
| 0:00 – 0:06 | Console do App Distribution com as versões 1.0.0 e 1.0.1 | "Olá! Eu sou o Yuri e vou começar pelo **Firebase App Distribution**. Aqui no console estão as versões do APK assinado que enviamos." |
| 0:06 – 0:16 | Emulador abre a página de testes, com a 1.0.1 disponível | "Eu fui convidado como testador. Pelo convite, acesso a página de testes do Circuito de Descobertas no Android e vejo a versão 1.0.1 disponível." |
| 0:16 – 0:29 | Download do APK | "Toco em baixar. O App Distribution é uma alternativa gratuita à Play Store: dá para distribuir o app para teste sem publicar na loja." |
| 0:29 – 0:42 | "Instalar este app?" e o aviso do Play Protect | "O Android pede confirmação, e o Play Protect avisa que o app não veio da loja. Isso é esperado num app de teste. Confirmo a instalação." |
| 0:42 – 0:52 | "App installed", depois o app aberto com a lista | "App instalado. Ao abrir, ele cria uma sessão anônima de visitante no **Firebase Authentication** e lista os estandes ativos, que vêm do **Cloud Firestore**." |
| 0:52 – 1:03 *(corte até 1:20)* – 1:22 | Login do painel web | "Agora o painel web da organização, feito em React. O administrador entra com e-mail e senha, e só ele pode alterar estandes, por causa das regras do Firestore." |
| 1:22 – 1:34 | Painel com métricas e tabela | "No painel vemos o total de estandes, os ativos e os check-ins confirmados, além da tabela com cada estande." |
| 1:34 – 1:53 | Preenchendo o formulário do LibrasJá | "Vou cadastrar um estande novo: LibrasJá, Tradutor de Libras, no Corredor A, estande 07, marcado como ativo." |
| 1:53 – 2:08 | O LibrasJá aparece no app | "Assim que eu salvo, ele já aparece no app do visitante, em tempo real, sem recarregar nada." |
| 2:08 – 2:32 | Página do QR code e prévia de impressão | "Cada estande tem um QR code gerado a partir do seu identificador. A página pode ser aberta em outra tela ou impressa para ficar no estande. Agora o Pedro mostra a missão surpresa." |

---

## CENA 2: Pedro (2:32 – 6:57)

| Tempo | O que aparece | Fala |
|---|---|---|
| 2:32 – 2:40 | Abrindo o Remote Config | "Eu sou o Pedro e vou mostrar o **Firebase Remote Config**, que controla a missão surpresa. Repare que no app ela começa desligada: esse é o padrão local." |
| 2:40 – 2:51 | Editar `missao_ativa` → true → Publicar | "No console, mudo o parâmetro `missao_ativa` para verdadeiro e publico. O parâmetro `missao_estandes` guarda os estandes destacados." |
| 2:51 – 3:02 | A missão aparece no app | "Sem recompilar e sem reinstalar, o mesmo app recebeu a mudança em tempo real: surgiu a chamada da missão, e o AçaíTech e o EcoRota ganharam destaque." |
| 3:02 – 3:12 | Marcando os estandes no painel e copiando o valor | "No painel eu marco quais estandes quero na missão e copio o valor pronto para colar no Remote Config." |
| 3:12 – 3:37 | `missao_ativa` → false → Publicar; a chamada some | "Desligo a missão e publico. A chamada sai do app na hora." |
| 3:37 – 3:58 | Colar a nova lista em `missao_estandes`, ligar `true` e publicar | "Agora colo a nova lista de estandes, ligo a missão de novo e publico." |
| 3:58 – 4:14 | O app mostra 4 estandes na missão, "0 de 4" | "E o app se atualiza sozinho: agora são quatro estandes participantes, incluindo o LibrasJá que acabamos de cadastrar. A chamada mostra o progresso, zero de quatro." |
| 4:14 – 4:31 | Permissão da câmera, leitura do QR e "Check-in confirmado!" | "Toco em Fazer check-in, permito a câmera e leio o QR do AçaíTech. O app confere se o estande existe e está ativo, grava o check-in e confirma o sucesso." |
| 4:31 – 5:05 | Troca do QR na parede virtual e check-in no EcoRota | "Como estamos no emulador, o QR fica numa parede virtual da câmera. Troco para o QR do EcoRota e faço o segundo check-in." |
| 5:05 – 5:13 | Os dois estandes como "Visitado" | "Os dois aparecem como visitados." |
| 5:13 – 5:19 | Painel: 2 check-ins e "Últimos check-ins" | "No painel, o total é calculado a partir dos registros no Firestore: dois check-ins confirmados, um no AçaíTech e um no EcoRota." |
| 5:19 – 5:31 | Remote Config: a missão volta para 2 estandes | "Ajusto a missão para esses dois estandes e publico." |
| 5:31 – 5:40 | Abrindo a missão: "Missão completa!" | "Abro a missão: aparecem os participantes e o progresso, missão completa! Essa abertura gera o evento `missao_aberta` no Analytics." |
| 5:40 – 5:56 | QR do EcoRota de novo → "Visita já registrada" | "Se eu tento o mesmo estande de novo, o app avisa: visita já registrada. Cada visitante registra só uma visita por estande, usando uma chave composta pelo visitante e pelo estande." |
| 5:56 – 6:30 | QR do Visão Amazônica → "Estande inativo" | "Agora o QR de um estande inativo, o Visão Amazônica. O app recusa, e nada é gravado." |
| 6:30 – 6:47 | `missao_ativa` → false → Publicar | "Para terminar, desligo a missão no Remote Config e publico." |
| 6:47 – 6:57 | O app sem chamada nem destaques | "A chamada e os destaques saem, mas a lista e o check-in continuam funcionando. Agora o Rath mostra o Analytics." |

---

## CENA 3: Rath (6:57 – 8:15)

| Tempo | O que aparece | Fala |
|---|---|---|
| 6:57 – 7:15 | Relatório Tempo real (mapa e usuários ativos) | "Eu sou o Rath e vou mostrar o **Google Analytics para Firebase**. Este é o relatório Tempo real do GA4, com os usuários ativos nos últimos 30 minutos." |
| 7:15 – 7:23 | Cartão "Contagem de eventos por nome do evento" | "No cartão de eventos aparecem os que o app registrou: `missao_aberta`, quando a missão foi aberta, e `checkin_concluido`, a cada check-in bem-sucedido." |
| 7:23 – 7:39 | Clique em `checkin_concluido` e depois em `estande_id` | "Abro o evento `checkin_concluido` e escolho o parâmetro `estande_id`." |
| 7:39 – 7:58 | Alternando entre o GA4 e o painel | "Os valores são os identificadores dos estandes. Comparando com o painel: GrUVF… é o AçaíTech, e 456xPw… é o EcoRota, exatamente os dois check-ins que fizemos." |
| 7:58 – 8:15 | Painel com o ID do AçaíTech destacado | "Resumindo: o estande cadastrado no painel apareceu no app, o Remote Config ligou e desligou a missão no mesmo APK, o check-in atualizou o painel e o evento chegou ao Analytics. Tudo no plano gratuito do Firebase. Obrigado!" |

---

## Montagem no Clipchamp

1. Abertura: os clipes de Yuri, Pedro e Rath, cerca de 15 s no total.
2. Vídeo da tela com o **corte de 1:03 a 1:20** feito.
3. Áudios: Yuri sobre a cena 1, Pedro sobre a cena 2 e Rath sobre a cena 3. Alinhe cada fala ao começo do seu trecho.
4. Opcional: uma legenda no canto em cada cena, por exemplo "App Distribution · Yuri", "Remote Config · Pedro" e "Analytics · Rath".
5. Exporte em 1080p. **Cada um dos três envia o mesmo vídeo individualmente.**
