# HabiTrack — App de Hábitos (Flutter)

[![Flutter CI](https://github.com/Tyago03/AppHabitos/actions/workflows/flutter.yml/badge.svg)](https://github.com/Tyago03/AppHabitos/actions/workflows/flutter.yml)

**Reconstrução de um projeto acadêmico antigo em Flutter.**

O projeto original foi desenvolvido com Flutter/Firebase para gerenciar hábitos e notificações. Os arquivos originais de plataforma e configuração foram perdidos; apenas o `main.dart` antigo e um ícone sobreviveram. Em novembro de 2026, a aplicação foi **reescrita com assistência de IA**, mantendo o código histórico como referência.

> **Estado:** nova implementação de portfólio com funcionamento **offline e armazenamento local**, sem Firebase ou cadastro. Esta reconstrução **não recupera dados de contas antigas** nem afirma reproduzir todas as funcionalidades do protótipo original. A nova entrada da aplicação é `lib/main.dart`; o `main.dart` da raiz é histórico.

## Funcionalidades da reconstrução

| Recurso | Estado |
| --- | --- |
| Criar, editar e excluir hábitos | Implementado |
| Frequência diária, semanal ou mensal | Implementado |
| Marcar uma ocorrência como concluída por data | Implementado |
| Visualizar hábitos da data selecionada | Implementado |
| Resumo dos últimos sete dias e progresso | Implementado |
| Persistência local em JSON com `shared_preferences` | Implementado (uso demonstrativo) |
| Horário preferido | Salvo no hábito; **não** gera notificações |
| Autenticação com Firebase e sincronização Firestore | **Não implementadas nesta reconstrução** |
| Notificações locais programadas | **Não implementadas nesta reconstrução** |
| Versões Android/Web | Scaffolding Android/Web gerado no CI e **build Web aprovado**; Android ainda não foi compilado/testado em aparelho. |

## Tecnologias

**Flutter + Dart**, Material Design 3 e `shared_preferences` (persistência local). Sem API de IA embutida, servidor, conta ou serviços pagos. A IA foi utilizada como apoio no processo de reconstrução, não como funcionalidade do aplicativo.

## Executar no Windows

Instale o [Flutter SDK](https://docs.flutter.dev/get-started/install) e configure um ambiente Android ou navegador para Flutter Web. No PowerShell:

```powershell
git clone https://github.com/Tyago03/AppHabitos.git
cd AppHabitos
flutter create --platforms=android,web --project-name=habittrack .
flutter pub get
flutter run -d chrome
```

O comando `flutter create` **regera apenas os arquivos de plataforma ausentes**, porque eles não sobreviveram ao projeto original. Para Android, com emulador ou celular configurado, use `flutter run` e selecione o dispositivo.

> O arquivo `lib/main.dart` é a entrada atual. Não execute o `main.dart` histórico na raiz; ele depende do Firebase e de arquivos que não existem mais.

### Testes

```powershell
flutter analyze
flutter test
flutter build web
```

Em **11/11/2026**, o [GitHub Actions](.github/workflows/flutter.yml) confirmou **11 testes aprovados**, análise estática sem problemas e **compilação Flutter Web concluída**. Isso não substitui testes em dispositivos Android reais.

## Organização

```text
AppHabitos/
├── lib/
│   ├── main.dart                   # Aplicação Flutter atual
│   ├── models/habit.dart           # Recorrência, conclusão por data, JSON
│   ├── data/habit_repository.dart  # Persistência local e repositório de teste
│   ├── controllers/habit_controller.dart
│   └── ui/                         # Telas e editor de hábitos
├── test/                           # Testes unitários e de widgets
├── .github/workflows/flutter.yml   # CI Flutter
├── pubspec.yaml                    # Dependências
├── main.dart                       # Código legado, preservado para estudo
├── ic_launcher.png                 # Ícone legado
├── LICENSE                         # MIT para novo código, conforme NOTICE
└── NOTICE.md                       # Escopo da licença e direitos antigos
```

## Segurança, privacidade e limitações

A versão nova não possui login nem envia hábitos a um servidor. O conteúdo fica no armazenamento local do aplicativo, sem criptografia específica; **não use para guardar dados sensíveis**. `shared_preferences` é apropriado para uma demonstração simples, mas não é um banco transacional nem garante persistência de informações críticas. A limpeza de dados do navegador ou do aplicativo pode apagar registros. Não há exportação ou migração automática de dados antigos.

Horários preferidos são apenas informativos; programar notificações Android/iOS exige configuração de permissões e implementação adicional. Um dia mensal como 31 só ocorre em meses que têm dia 31. Não há autenticação, sincronização multi-dispositivo, publicação nas lojas ou certificação de segurança.

## Origem e licença

Reescrita de portfólio de Tyago Vitorino Ferreira com auxílio de ferramentas de IA. Os arquivos atuais são distintos do código acadêmico antigo, que foi preservado para referência. A licença [MIT](LICENSE) é válida para o **código novo da reconstrução**. Leia [NOTICE.md](NOTICE.md): o `main.dart` e o ícone históricos estão excluídos até esclarecer os direitos de eventuais colaboradores. Bibliotecas e marcas de terceiros seguem suas próprias licenças.
