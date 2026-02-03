# HabiTrack - Monitorador de Hábitos

Aplicativo mobile desenvolvido como projeto acadêmico para gerenciamento e acompanhamento de hábitos diários, semanais e mensais. O projeto foi criado utilizando Flutter e Firebase, com foco em notificações programadas e visualização de estatísticas.

## Sobre o Projeto

O HabiTrack é um aplicativo de rastreamento de hábitos que permite aos usuários criar, organizar e monitorar seus hábitos de forma intuitiva. Este projeto foi desenvolvido como atividade acadêmica com o objetivo de aplicar conceitos de desenvolvimento mobile, integração com backend e gerenciamento de notificações.

## Funcionalidades

### Gerenciamento de Usuários
- Sistema de autenticação completo com Firebase Authentication
- Cadastro de novos usuários com validação de dados
- Login seguro com email e senha
- Recuperação de senha via email
- Perfil do usuário com informações personalizadas

### Gerenciamento de Hábitos
- Criação de hábitos personalizados com nome e descrição
- Configuração de frequência de lembretes (diária, semanal ou mensal)
- Definição de horários específicos para notificações
- Seleção de dias da semana para hábitos semanais
- Seleção de dias do mês para hábitos mensais
- Personalização de cores para cada hábito
- Edição e exclusão de hábitos existentes

### Organização e Visualização
- Visualização de todos os hábitos organizados por frequência
- Tela dedicada "Hoje" mostrando apenas hábitos do dia atual
- Agrupamento automático em categorias: Diários, Semanais e Mensais
- Marcação de hábitos como concluídos
- Separação visual entre hábitos pendentes e concluídos

### Notificações
- Sistema de notificações locais programadas
- Lembretes automáticos baseados na frequência configurada
- Notificações persistentes mesmo com o app fechado

### Estatísticas
- Gráfico de pizza mostrando hábitos completos vs incompletos
- Gráfico de barras com distribuição de hábitos por frequência
- Visualização clara do progresso geral
- Contagem total de hábitos cadastrados

## Tecnologias Utilizadas

### Framework e Linguagem
- Flutter
- Dart

### Backend e Banco de Dados
- Firebase Core
- Firebase Authentication (autenticação de usuários)
- Cloud Firestore (armazenamento de dados)

### Bibliotecas e Pacotes
- **google_fonts** - Tipografia personalizada (Indie Flower)
- **intl** - Formatação de datas e internacionalização (pt-BR)
- **flutter_local_notifications** - Sistema de notificações locais
- **timezone** - Gerenciamento de fusos horários para notificações
- **permission_handler** - Solicitação de permissões do sistema
- **fl_chart** - Gráficos estatísticos (pizza e barras)

## Estrutura do Projeto

O aplicativo está organizado em diferentes telas e componentes:

### Telas Principais
- **LoginPage** - Autenticação de usuários
- **RegisterPage** - Cadastro de novos usuários
- **ForgotPasswordPage** - Recuperação de senha
- **MainPage** - Navegação principal com bottom navigation bar
- **HabitList** - Lista completa de hábitos
- **TodayHabits** - Hábitos do dia atual
- **HabitStatistics** - Estatísticas e gráficos
- **ProfilePage** - Perfil do usuário
- **AddHabitScreen** - Criação de novos hábitos
- **EditHabitScreen** - Edição de hábitos existentes

### Componentes
- **HabitTile** - Card individual de hábito com expansão
- **Habit** - Modelo de dados para hábitos

## Requisitos

Para executar este projeto, você precisa ter instalado:

- Flutter SDK (versão 2.0 ou superior)
- Dart SDK
- Android Studio ou VS Code com extensões Flutter
- Dispositivo Android/iOS ou emulador configurado
- Conta Firebase com projeto configurado

## Configuração do Firebase

Antes de executar o aplicativo, é necessário:

1. Criar um projeto no Firebase Console
2. Adicionar o aplicativo Android/iOS ao projeto Firebase
3. Baixar o arquivo de configuração:
   - `google-services.json` para Android
   - `GoogleService-Info.plist` para iOS
4. Habilitar Authentication (Email/Password)
5. Criar banco de dados Firestore
6. Configurar as regras de segurança do Firestore

## Como Executar

1. Clone este repositório:

```bash
git clone https://github.com/Tyago03/AppHabitos.git
```

2. Acesse a pasta do projeto:

```bash
cd AppHabitos
```

3. Instale as dependências:

```bash
flutter pub get
```

4. Configure o Firebase seguindo as instruções da seção anterior

5. Execute o aplicativo:

```bash
flutter run
```

## Estrutura de Dados

### Coleção Users
```
users/
  {userId}/
    - name: string
    - email: string
```

### Coleção Habits
```
habits/
  {habitId}/
    - userId: string
    - title: string
    - description: string
    - reminderTime: string
    - reminderFrequency: string
    - color: int
    - weekDays: array<boolean>
    - weekendDays: array<boolean>
    - monthDays: array<boolean>
    - nextReminder: timestamp
    - isCompleted: boolean
```

## Aprendizados

Durante o desenvolvimento deste projeto foram aplicados conhecimentos de:

- Desenvolvimento mobile multiplataforma com Flutter
- Integração com Firebase (Authentication e Firestore)
- Gerenciamento de estado com StatefulWidget
- Navegação entre telas e passagem de dados
- Sistema de notificações locais agendadas
- Manipulação de datas e horários
- Criação de gráficos e visualizações de dados
- Organização de código e componentização
- Interface de usuário responsiva e intuitiva
- Persistência de dados em tempo real
- Validação de formulários e tratamento de erros

## Licença

Este projeto foi desenvolvido para fins educacionais como parte de um trabalho acadêmico.
