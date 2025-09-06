# 🎬 Filmly

Um aplicativo moderno e elegante para descobrir e gerenciar seus filmes favoritos, desenvolvido com Flutter.

*Trabalho desenvolvido para a disciplina de Laboratório de Desenvolvimento de Dispositivos Móveis.*

## ✨ Características

- **Design Moderno**: Interface limpa e intuitiva com cores inspiradas no Netflix
- **Tela de Login**: Autenticação segura com validação de campos
- **Navegação Fluida**: BottomNavigationBar com 4 abas principais
- **Descoberta de Filmes**: Seções organizadas com sugestões, favoritos e filmes assistidos
- **Busca Inteligente**: Campo de busca para encontrar filmes rapidamente
- **Perfil Personalizado**: Gerenciamento completo do perfil do usuário

## 🚀 Funcionalidades

### 🔐 Tela de Login
- Logo personalizada do Filmly
- Validação de e-mail e senha
- Botão de "Esqueci minha senha"
- Opção para criar nova conta
- Loading state durante autenticação

### 🏠 Tela Principal
- AppBar com título e acesso ao perfil
- Barra de busca responsiva
- Seções de filmes:
  - **Sugestões**: Filmes recomendados
  - **Favoritos**: Seus filmes favoritos
  - **Meus Filmes**: Filmes que você assistiu

### 📱 Navegação
- **Início**: Tela principal com todas as seções
- **Favoritos**: Lista completa de filmes favoritos
- **Assistidos**: Histórico de filmes assistidos com estatísticas
- **Perfil**: Configurações e informações do usuário

## 🎨 Design System

- **Cor Principal**: Vermelho Netflix (#E50914)
- **Tipografia**: Roboto com hierarquia clara
- **Cards**: Sombras suaves e bordas arredondadas
- **Ícones**: Material Design Icons
- **Layout**: Responsivo e acessível

## 🛠️ Tecnologias

- **Flutter**: Framework principal
- **Material Design 3**: Sistema de design
- **Dart**: Linguagem de programação

## 📦 Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada da aplicação
├── theme/
│   └── app_theme.dart       # Tema e cores do app
├── screens/
│   ├── login_screen.dart    # Tela de login
│   ├── home_screen.dart     # Tela principal
│   ├── favorites_screen.dart # Tela de favoritos
│   ├── watched_screen.dart  # Tela de assistidos
│   └── profile_screen.dart  # Tela de perfil
└── widgets/
    ├── movie_card.dart      # Card de filme reutilizável
    └── movie_section.dart   # Seção de filmes
```

## 🚀 Como Executar

1. **Instale o Flutter**: [Guia de Instalação](https://docs.flutter.dev/get-started/install)

2. **Clone o repositório**:
   ```bash
   git clone <repository-url>
   cd filmly
   ```

3. **Instale as dependências**:
   ```bash
   flutter pub get
   ```

4. **Execute o aplicativo**:
   ```bash
   flutter run
   ```

## 📱 Capturas de Tela

*Em breve: Screenshots das principais telas do aplicativo*

## 🔮 Próximas Funcionalidades

- [ ] Integração com API de filmes (TMDB)
- [ ] Sistema de avaliações
- [ ] Modo escuro
- [ ] Notificações push
- [ ] Compartilhamento de filmes
- [ ] Lista de desejos
- [ ] Histórico de visualizações

## 🤝 Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou enviar pull requests.

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
