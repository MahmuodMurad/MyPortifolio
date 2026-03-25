# Portfolio App - Memory & Design Reference

## 🎨 Design System

### Color Palette
| Token | Hex | Usage |
|-------|-----|-------|
| Background | `#0A0E21` | Main dark background |
| Surface | `#1A1F3A` | Cards, containers |
| Accent Primary | `#00D9FF` | Cyan/teal — CTAs, highlights |
| Accent Secondary | `#7B2FFF` | Purple — gradients, accents |
| Text Primary | `#FFFFFF` | Headings |
| Text Secondary | `#8D8DAA` | Body text, labels |
| Glow | `#00D9FF` at 30% | Card hover glow, borders |

### Typography
- **Headings**: Outfit (Google Fonts) — Bold, modern geometric
- **Body**: Poppins (Google Fonts) — Clean, readable

### Glassmorphism Cards
- Background: `Surface` with 60% opacity
- Border: 1px `Accent Primary` at 15% opacity
- Blur: `BackdropFilter` with `sigmaX: 10, sigmaY: 10`
- Border radius: 20px

---

## ✨ Animations Reference

### Splash Screen
- **Rotating Wheel**: Profile photo in a `ClipOval`, uses `AnimationController` with `Transform.rotate`. Duration: ~2s per rotation.
- **Smoke Effect**: `CustomPainter` with 30-50 particle instances, each with random velocity/opacity. Particles drift upward and fade.
- **Slide Right**: After 2 rotations, wheel slides right using `SlideTransition` (Curves.easeOutCubic, 1s).
- **Name Writing**: `AnimatedTextKit` typewriter effect after wheel stops.

### Section Entrance Animations
- **Trigger**: `VisibilityDetector` fires when 30%+ visible.
- **Effect**: `SlideTransition` from bottom (offset 0.3) + `FadeTransition` (0→1). Duration: 600ms, staggered 100ms per item.

### Project & Contact Cards — Waving Animation
- Uses `Transform.rotate` with a small angle oscillation: `sin(controller.value * 2π) * 0.02 radians`
- Continuous subtle waving, amplified on hover to `0.04 radians`
- Duration: 2s per cycle, `repeat()` with `Curves.easeInOut`

### Skill Bars
- Animated width from 0% → target using `Tween<double>` over 1.2s with `Curves.easeOutCubic`.
- Gradient fill: Accent Primary → Accent Secondary.

### Background Particles
- 40-60 floating dots with random size (2-5px), speed, and opacity.
- Rendered via `CustomPainter`, updated each frame via `AnimationController`.

---

## 📁 Assets

### Images
- `assets/images/myimage.jpeg` — Profile photo (used in splash wheel + about section)

### Data
- `assets/data/cv_data.json` — All CV content (personal info, experience, projects, skills)

---

## 🏗 Architecture

### Feature-Based Structure
```
lib/
├── main.dart                          # Entry point
├── app/
│   ├── app.dart                       # MaterialApp with theme
│   └── theme/                         # Colors, theme data
├── core/
│   ├── data/cv_data_provider.dart     # JSON loader
│   ├── widgets/                       # Reusable animated widgets
│   └── utils/responsive.dart          # Breakpoints
├── features/
│   ├── splash/                        # Splash with Cubit
│   ├── home/                          # Home with NavigationCubit
│   ├── about/                         # About section
│   ├── experience/                    # Timeline experience
│   ├── projects/                      # Project cards + Cubit
│   ├── skills/                        # Skill bars + Cubit
│   └── contact/                       # Contact cards
```

### State Management
- Each feature with dynamic state uses a dedicated **Cubit**.
- `SplashCubit` → controls splash animation phases
- `NavigationCubit` → tracks active section on scroll
- `ProjectsCubit` → manages project data from JSON
- `SkillsCubit` → manages skill data with animation triggers

---

## 📱 Responsive Breakpoints
| Size | Width | Layout |
|------|-------|--------|
| Mobile | < 600px | Single column, stacked |
| Tablet | 600–1024px | 2-column grid |
| Desktop | > 1024px | Multi-column, sidebar nav |
