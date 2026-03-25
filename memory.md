# Portfolio App - Memory & Design Reference

## 🎨 Design System

### Color Palette
| Token | Hex | Usage |
|-------|-----|-------|
| Background | `#0A0E21` | Main dark background |
| Surface | `#1A1F3A` | Cards, containers (50-70% opacity) |
| Accent Primary | `#00D9FF` | Cyan/teal — CTAs, highlights, Skill bar tips |
| Accent Secondary | `#7B2FFF` | Purple — gradients, accents |
| Text Primary | `#FFFFFF` | Headings |
| Text Secondary | `#8D8DAA` | Body text, labels |
| Glow | `#00D9FF` at 30-50% | Card hover glow, borders, Tech chips | 

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

### Splash Screen (Native HTML/CSS)
- **Pulse Entrance**: The profile wheel appears with a scale (0.8 -> 1.0) and fade-in pulse effect.
- **Glowing Atmosphere**: Intense cyan outer glow (`box-shadow`) that pulses with the wheel.
- **Burning Smoke**: 4 layers of rising smoke particles beneath the wheel.
- **Typewriter Text**: JS-driven letter-by-letter reveal for "Mahmoud Murad", followed by a fade-in for the role.
- **Lifecycle**: ~4.8s total duration to allow completion of the typewriter effect before fading out.

### Section Entrance Animations (Cyber-Modern Reveal)
- **Experience Timeline**: Staggered slide-up + fade-in. Horizontal hover drift (+12px) and glowing vertical side-bar.
- **Skill Bars**: Animated width (1.5s) with a glowing sphere at the progress tip.
- **Tech Stack Cloud**: Dynamic collection of chips pulled from JSON. Interactive: Scale up (1.1x) + Outer glow on hover.
- **Waving Animation**: Project & Contact cards feature a smooth `sin()` oscillation amplified on hover.

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
| Mobile | < 600px | Single column, stacked, 130px wheel |
| Tablet | 600–1024px | 2-column grid |
| Desktop | > 1024px | Multi-column, sidebar nav, 160px wheel |

---

## 🚀 Deployment (GitHub Pages)
- **Base Href**: Must be set to `"/MyPortifolio/"`.
- **Renderer**: `--web-renderer html` used for fast initial loads.
- **Native Splash**: Splash screen logic moved to `index.html` (CSS/JS) to eliminate white flash and provide 3s branded loading.
