# 🎬 Filmly

Um aplicativo moderno e elegante para descobrir e gerenciar seus filmes favoritos, desenvolvido com Flutter.

*Trabalho desenvolvido para as disciplinas de **Laboratório de Desenvolvimento de Dispositivos Móveis** e **Programação para Dispositivos Móveis II**.*

## ✨ Características

- **Design Moderno**: Interface limpa e intuitiva com cores inspiradas no Netflix
- **Integração com TMDB**: API real para buscar filmes populares com capas e descrições
- **Tela de Login**: Autenticação segura com validação de campos
- **Navegação Fluida**: BottomNavigationBar com 4 abas principais
- **Descoberta de Filmes**: Seções organizadas com sugestões, favoritos e filmes assistidos
- **Cartões de Filme**: Exibição de capas reais com descrições completas
- **Sistema de Favoritos**: Funcionalidade completa para marcar filmes como favoritos
- **Lista de Assistidos**: Acompanhamento de filmes assistidos com estatísticas
- **Busca Inteligente**: Campo de busca para encontrar filmes rapidamente
- **Perfil Personalizado**: Gerenciamento completo do perfil do usuário
- **Loading States**: Indicadores de carregamento e tratamento de erros

## 🚀 Funcionalidades

### 🔐 Tela de Login
- Logo personalizada do Filmly
- Validação de e-mail e senha
- Botão de "Esqueci minha senha"
- Opção para criar nova conta
- Loading state durante autenticação

### 🏠 Tela Principal
- AppBar com título e acesso ao perfil e lista dinâmica
- Barra de busca responsiva
- Seções de filmes com dados reais da API TMDB:
  - **Sugestões**: Filmes populares com capas e descrições reais
  - **Favoritos**: Seus filmes favoritos (dados simulados da API)
  - **Assistidos**: Filmes que você assistiu (dados simulados da API)
- Loading states e tratamento de erros
- Botão flutuante para adicionar novos filmes

### 📱 Navegação
- **Início**: Tela principal com todas as seções e dados reais da API
- **Favoritos**: Lista completa de filmes favoritos com capas e descrições
- **Assistidos**: Histórico de filmes assistidos com estatísticas dinâmicas
- **Perfil**: Configurações e informações do usuário

### 🎬 Lista Dinâmica de Filmes
- Tela dedicada com todos os filmes populares da API TMDB
- Cartões com capas reais e descrições completas
- Loading state durante carregamento
- Tratamento de erros com opção de tentar novamente
- Integração completa com a API The Movie Database

## 🎨 Design System

- **Cor Principal**: Vermelho Netflix (#E50914)
- **Tipografia**: Roboto com hierarquia clara
- **Cards**: Sombras suaves e bordas arredondadas
- **Ícones**: Material Design Icons
- **Layout**: Responsivo e acessível

## 🛠️ Tecnologias

- **Flutter**: Framework principal para desenvolvimento mobile
- **Dart**: Linguagem de programação
- **Material Design 3**: Sistema de design
- **HTTP**: Para requisições à API TMDB
- **TMDB API**: The Movie Database para dados de filmes
- **Intl**: Para internacionalização e formatação de datas

## 📦 Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada da aplicação
├── secrets.dart             # Configurações da API TMDB
├── theme/
│   └── app_theme.dart       # Tema e cores do app
├── models/
│   └── movie.dart           # Modelo de dados do filme
├── services/
│   └── tmdb_service.dart    # Serviço para integração com API TMDB
├── screens/
│   ├── login_screen.dart    # Tela de login
│   ├── home_screen.dart     # Tela principal com dados reais
│   ├── favorites_screen.dart # Tela de favoritos
│   ├── watched_screen.dart  # Tela de assistidos
│   ├── profile_screen.dart  # Tela de perfil
│   └── movies/
│       ├── lista.dart       # Lista dinâmica de filmes
│       └── formulario.dart  # Formulário para adicionar filmes
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

4. **Configure a API TMDB**:
   - Crie uma conta em [The Movie Database](https://www.themoviedb.org/)
   - Obtenha sua chave de API
   - Substitua a chave no arquivo `lib/secrets.dart`

5. **Execute o aplicativo**:
   ```bash
   flutter run
   ```

## 📱 Capturas de Tela

*Em breve: Screenshots das principais telas do aplicativo*

## ✅ Funcionalidades Implementadas

- [x] **Integração com API TMDB**: Carregamento de filmes populares com capas e descrições
- [x] **Sistema de Favoritos**: Marcar e desmarcar filmes como favoritos
- [x] **Lista de Assistidos**: Acompanhamento de filmes assistidos
- [x] **Loading States**: Indicadores de carregamento em todas as telas
- [x] **Tratamento de Erros**: Mensagens de erro com opção de tentar novamente
- [x] **Cartões de Filme**: Exibição de capas reais com descrições
- [x] **Navegação Completa**: Todas as telas funcionais
- [x] **Design Responsivo**: Interface adaptável e moderna

## 🔮 Próximas Funcionalidades

- [ ] Sistema de avaliações com estrelas
- [ ] Lista de desejos personalizada
- [ ] Busca de filmes por nome
- [ ] Filtros por gênero e ano
- [ ] Modo offline com cache local
- [ ] Sincronização com Firebase
- [ ] Notificações de novos lançamentos

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
