# Circuito de Descobertas

Atividade prática de Laboratório de Programação Mobile (CESUPA). A organização do Amazon Hacking cadastra os estandes num **painel web** e lança uma **missão surpresa**. Os visitantes usam o **app Flutter** para fazer check-in nos estandes lendo um QR code.

| Pasta | O que é |
|---|---|
| `painel/` | Painel web da organização (React + Vite + Firebase JS SDK) |
| `app/` | App Android do visitante (Flutter) |
| `firestore.rules` | Regras de acesso do Cloud Firestore |
| `testes-regras/` | Testes automáticos das regras no emulador |
| `scripts/gerar-keystore.ps1` | Gera a chave que assina o APK |

Tudo funciona no **plano Spark** (gratuito, sem cartão).

## Serviços usados

| Serviço | Para quê |
|---|---|
| Authentication | Admin entra com e-mail e senha; visitante entra com sessão anônima |
| Cloud Firestore | Coleções `estandes`, `checkins` e `admins` |
| Remote Config | `missao_ativa` e `missao_estandes`, com atualização em tempo real (`onConfigUpdated`) |
| Google Analytics (GA4) | Eventos `missao_aberta` e `checkin_concluido` (parâmetro `estande_id`) |
| App Distribution | Entrega do APK assinado ao testador convidado |
| Hosting (opcional) | Hospedagem gratuita do painel |

### Modelo de dados

```
admins/{uid}                     { email }                      ← criado à mão no console
estandes/{id}                    { nome, descricao, localizacao, ativo, criadoEm, atualizadoEm }
checkins/{uid}_{estandeId}       { visitanteId, estandeId, criadoEm }
```

O ID composto `uid_estandeId` faz com que cada visitante só consiga registrar **uma visita por estande**. As regras recusam uma segunda gravação no mesmo documento. Os QR codes contêm `circuito://estande/<id>`.

### Regras de acesso (`firestore.rules`)
- Só administradores (UID presente em `admins/`) criam e editam estandes, e os campos são validados.
- Visitantes autenticados leem só os estandes **ativos** e criam check-in **só com o próprio UID**, apenas em estande ativo e com data do servidor.
- A organização lê todos os check-ins para calcular os totais. Check-ins não podem ser alterados nem apagados.

Para testar: `cd testes-regras && npm install && npm test` (são 13 testes no emulador).

---

## Configuração (uma vez só)

### 1. Projeto Firebase
1. Em <https://console.firebase.google.com>, crie um projeto com o **Google Analytics ativado** (crie uma conta do Analytics se pedir). Fica no plano Spark.
2. Em **Authentication → Método de login**, ative **E-mail/senha** e **Anônimo**.
3. Em **Authentication → Usuários**, adicione o usuário admin (ex.: `organizacao@circuito.dev`).
4. Em **Firestore Database → Criar banco de dados**, escolha o modo de produção e a região `southamerica-east1`.
5. Em **Firestore → Dados**, crie a coleção `admins` e um documento cujo **ID é o UID** do usuário admin (está na lista de usuários do Authentication), com o campo `email` (string).

### 2. Ligar o código ao projeto
Na raiz do repositório:

```powershell
firebase login
firebase use --add                     # escolha o projeto; cria o .firebaserc
firebase deploy --only firestore:rules

cd app
dart pub global run flutterfire_cli:flutterfire configure --platforms=android,web
```

O `flutterfire configure` cria o app Android (`br.cesupa.circuito.circuito_descobertas`) e um app Web no projeto. Ele também gera `app/lib/firebase_options.dart` e `google-services.json`.

### 3. Painel web
```powershell
cd painel
copy .env.example .env.local
npx firebase-tools apps:sdkconfig web   # cole os valores no .env.local
npm install
npm run dev                             # http://localhost:5173
```
Entre com o usuário admin e clique em **"Criar estandes de exemplo"**. São criados 4 estandes fictícios: 3 ativos e 1 inativo, para demonstrar a recusa no check-in.

Para hospedar de graça: `npm run build` e depois, na raiz, `firebase deploy --only hosting`.

> Sem um projeto real, dá para testar com os emuladores: na raiz, `firebase emulators:start --project demo-circuito`; depois, em `painel/`, `npm run dev:emulador`.

### 4. Remote Config (missão surpresa)
Em **Remote Config → Criar configuração**, adicione:

| Parâmetro | Tipo | Valor inicial |
|---|---|---|
| `missao_ativa` | Booleano | `false` |
| `missao_estandes` | String | IDs separados por vírgula. Marque os estandes na tabela do painel e clique em **Copiar valor** |
| `missao_titulo` | String (opcional) | `Missão surpresa!` |
| `missao_descricao` | String (opcional) | texto livre |

Clique em **Publicar alterações**. O app já vem com `missao_ativa = false` como padrão local.

### 5. APK assinado e App Distribution
A chave de assinatura já foi gerada (`app/android/app/upload-keystore.jks` + `app/android/key.properties`, fora do git). **Faça backup desses dois arquivos.** Se precisar recriar a chave: `powershell -ExecutionPolicy Bypass -File scripts\gerar-keystore.ps1`.

```powershell
cd app
flutter build apk --release
# APK: app\build\app\outputs\flutter-apk\app-release.apk
```

No console, abra **App Distribution** (menu Executar/Run), escolha o app Android, clique em **Começar**, arraste o `app-release.apk`, adicione o e-mail do testador e distribua. O testador recebe um convite por e-mail, aceita, baixa e instala o app (precisa permitir "instalar apps desconhecidos").

Alternativa pela linha de comando:
```powershell
firebase appdistribution:distribute app\build\app\outputs\flutter-apk\app-release.apk --app <ID-do-app-Android> --testers "email@exemplo.com" --release-notes "Circuito de Descobertas v1"
```

### 6. Analytics em tempo real
Em **Analytics → Relatórios → Tempo real** (ou no GA4 em analytics.google.com), o cartão **"Contagem de eventos por nome do evento"** mostra `missao_aberta` e `checkin_concluido`. Clique em `checkin_concluido` para ver o parâmetro `estande_id`. Os eventos podem levar alguns minutos para aparecer.

---

## Roteiro do vídeo (equipe)

> Cada integrante precisa aparecer ou narrar uma parte. Sugestão de divisão para três pessoas: **A** cuida dos passos 1 e 2, **B** do passo 3, **C** do passo 4 e do encerramento. Todos enviam o mesmo vídeo individualmente.

1. **Apresentação e App Distribution (A).** Apresente a equipe. No celular, abra o e-mail de convite do App Distribution, aceite, mostre a versão disponível, baixe, instale e abra o app.
2. **Painel → app (A).** No painel, cadastre um estande novo e mostre que ele aparece na lista do app. Clique em **QR code** e mostre o QR gerado em outra aba.
3. **Remote Config e check-in (B).**
   - No painel, marque os estandes da missão e copie o valor.
   - No console do Remote Config, cole em `missao_estandes`, mude `missao_ativa` para `true` e publique. **Sem fechar o app**, mostre a chamada da missão e os destaques aparecendo.
   - Abra a missão (gera `missao_aberta`) e faça o check-in lendo o QR (gera `checkin_concluido`).
   - Mostre o total subindo no painel.
   - Mostre os retornos de erro: o mesmo QR de novo ("visita já registrada"), o QR do estande inativo e um QR qualquer ("QR inválido").
   - Volte ao Remote Config, mude `missao_ativa` para `false` e publique. Mostre a chamada e os destaques sumindo, com a lista e o check-in ainda funcionando.
4. **Analytics (C).** No GA4, abra **Relatórios → Tempo real**. No cartão de eventos, mostre `missao_aberta` e `checkin_concluido`, clique no check-in e mostre o valor de `estande_id`. Se os eventos demorarem, pause a gravação e retome quando aparecerem.
5. **Fechamento (C).** Recapitule o percurso: estande criado no painel → aparece no app → check-in → total no painel → evento no Analytics.

Use apenas dados fictícios.
