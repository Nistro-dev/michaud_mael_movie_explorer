# 🎬 Movie Explorer — Michaud Maël

Application Flutter de découverte de films utilisant l'API TMDB, développée dans le cadre du cours de développement mobile à l'ESIEA.

---

## Fonctionnalités

- **API REST TMDB** — récupération de films via `http` avec `async/await`
- **JSON → Modèles Dart** — désérialisation via `Movie.fromJson()` / `Movie.toJson()`
- **Affichage ListView** — liste scrollable avec mise à jour réactive
- **Gestion des erreurs et état de chargement** — états loading / error / data

### Supplémentaires
- 🔍 **Recherche** — recherche en temps réel avec debounce (300ms)
- ❤️ **Favoris** — ajout/suppression, persistés localement
- ⭐ **Notation utilisateur** — note sur 5 étoiles, persistée localement
- 📜 **Historique** — 30 derniers films consultés, effaçable
- 📄 **Pagination infinie** — chargement automatique à l'approche du bas
- 🔄 **Pull-to-refresh** — actualisation par glissement
- 💀 **Skeleton loading** — placeholders animés pendant le chargement
- 🎭 **Filtrage par genre** — chips horizontaux dans l'accueil
- 📈 **Onglets** — Populaires / Tendances / Mieux notés
- 🗂️ **Cache API** — mise en cache des réponses (TTL 5 minutes)

---

## Architecture

```
lib/
├── constants/
│   └── colors.dart                  # Palette de couleurs centralisée
├── models/
│   └── movie.dart                   # Modèle Movie (fromJson / toJson)
├── services/
│   └── tmdb_service.dart            # Appels API REST + cache in-memory
├── providers/                       # État global (Riverpod)
│   ├── shared_preferences_provider.dart
│   ├── movie_providers.dart         # Listes de films + filtrage
│   ├── search_provider.dart         # Recherche avec debounce
│   ├── favorites_provider.dart      # Favoris persistés
│   ├── rating_provider.dart         # Notes utilisateur persistées
│   └── history_provider.dart        # Historique de navigation persisté
├── screens/
│   ├── main_screen.dart             # Navigation principale (BottomNavigationBar)
│   ├── home_screen.dart             # Accueil (onglets + genres + scroll infini)
│   ├── search_screen.dart           # Recherche
│   ├── favorites_screen.dart        # Favoris
│   ├── history_screen.dart          # Historique
│   └── movie_detail_screen.dart     # Détail d'un film
└── widgets/
    ├── movie_card.dart              # Carte film réutilisable
    └── skeleton_card.dart           # Placeholder de chargement animé
```

### Couches
```
API TMDB → TmdbService → Providers (Riverpod) → Screens / Widgets
```

---

## State Management — Riverpod

| Provider | Type | Rôle |
|---|---|---|
| `tmdbServiceProvider` | `Provider` | Singleton du service API |
| `popularMoviesProvider` | `StateNotifierProvider` | Films populaires + pagination |
| `trendingMoviesProvider` | `StateNotifierProvider` | Films tendance + pagination |
| `topRatedMoviesProvider` | `StateNotifierProvider` | Films mieux notés + pagination |
| `currentMoviesProvider` | `Provider` | Films filtrés selon l'onglet et le genre |
| `searchProvider` | `StateNotifierProvider` | Recherche avec debounce |
| `favoritesProvider` | `StateNotifierProvider` | Favoris (persistés SharedPreferences) |
| `ratingsProvider` | `StateNotifierProvider` | Notes (persistées SharedPreferences) |
| `historyProvider` | `StateNotifierProvider` | Historique (persisté SharedPreferences) |

---

## Navigation

- **`IndexedStack`** — BottomNavigationBar avec 4 onglets persistants (état conservé au changement d'onglet)
- **`Navigator.push`** — navigation vers le détail d'un film (stack standard Flutter)

---

## Animations

| Animation | Widget | Technique |
|---|---|---|
| Transition liste → détail | `MovieCard` + `MovieDetailScreen` | `Hero` sur le poster |
| Ajout/retrait favori | `MovieCard` | `AnimatedSwitcher` + `ScaleTransition` |
| Skeleton de chargement | `SkeletonCard` | `AnimationController` (shimmer) |

---

## StatelessWidget vs StatefulWidget

| Widget | Type | Raison |
|---|---|---|
| `MyApp` | `StatelessWidget` | Aucun état, configure `MaterialApp` |
| `SkeletonCard` | `StatefulWidget` | `AnimationController` nécessite un cycle de vie |
| `FavoritesScreen`, `HistoryScreen`, `MovieCard` | `ConsumerWidget` | Lecture Riverpod uniquement, pas d'état local |
| `HomeScreen`, `MainScreen`, `SearchScreen`, `MovieDetailScreen` | `ConsumerStatefulWidget` | État local (contrôleurs, index) + accès Riverpod |

> `ConsumerWidget` et `ConsumerStatefulWidget` sont les équivalents Riverpod de `StatelessWidget` et `StatefulWidget`.

---

## Installation

### Prérequis
- Flutter 3.x
- Xcode (pour iOS)
- Un appareil iOS ou un simulateur

### Lancer le projet

```bash
# Installer les dépendances
flutter pub get

# Lancer sur un appareil connecté
flutter run

# Build iOS (sans signature)
flutter build ios --no-codesign
```

---

## Dépendances

| Package | Version | Usage |
|---|---|---|
| `flutter_riverpod` | ^2.6.1 | State management |
| `shared_preferences` | ^2.3.2 | Persistance locale (favoris, notes, historique) |
| `http` | — | Appels API REST |

---

## API

Ce projet utilise l'[API TMDB](https://www.themoviedb.org/documentation/api).

Endpoints utilisés :
- `GET /movie/popular`
- `GET /trending/movie/week`
- `GET /movie/top_rated`
- `GET /search/movie`
- `GET /movie/{id}/credits`
