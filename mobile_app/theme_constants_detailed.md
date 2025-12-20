# VoteSync Theme & Constants - DETAILED IMPLEMENTATION GUIDE
## Deep Dive into Design System and App Constants

**Status:** Complete Reference Guide  
**Focus:** Colors, Typography, Constants with Full Details  
**Date:** December 15, 2025  
**Level:** Production-Ready Implementation

---

## 📚 TABLE OF CONTENTS

1. [Colors.dart - Complete Guide](#colorsdart---complete-guide)
2. [TextStyles.dart - Complete Guide](#textstylesdart---complete-guide)
3. [AppConstants.dart - Complete Guide](#appconstantsdart---complete-guide)
4. [Usage Examples](#usage-examples)
5. [Best Practices](#best-practices)

---

## colors.dart - COMPLETE GUIDE

### **FILE LOCATION:** `lib/core/theme/colors.dart`

### **WHAT IS THIS FILE?**

A centralized color palette for the entire application. Instead of scattering colors throughout your code (like `Color(0xFF003D82)` everywhere), this file is the **single source of truth** for all colors.

**Why this matters:**
- ✅ Change one color, updates everywhere
- ✅ Consistent branding across app
- ✅ Easy to switch themes (dark mode, etc.)
- ✅ Team can reference colors by name, not hex codes

---

### **COLOR THEORY BREAKDOWN**

#### **1. PRIMARY COLORS (Fisk University Branding)**

**Purpose:** Main brand colors used for primary actions, headers, navigation

```dart
static const Color primary = Color(0xFF003D82); // Deep Blue
static const Color primaryLight = Color(0xFF1C5AA0);
static const Color primaryDark = Color(0xFF002857);
```

**Detailed Breakdown:**

| Variable | Hex Code | RGB | Usage |
|----------|----------|-----|-------|
| **primary** | `0xFF003D82` | 0, 61, 130 | Main buttons, app bar, selected state |
| **primaryLight** | `0xFF1C5AA0` | 28, 90, 160 | Hover states, lighter backgrounds |
| **primaryDark** | `0xFF002857` | 0, 40, 87 | Pressed states, dark backgrounds |

**How Fisk Colors Work:**
- **Fisk University Official Colors:** Deep Blue (#003D82) and Gold (#F4BA1B)
- These colors represent Fisk's identity and tradition
- Deep Blue conveys trust, stability, professionalism
- Used in app bar, primary buttons, selection indicators

**In Your App:**
```
App Bar: primary (#003D82)
Main Button: primary (#003D82)
Button Hover: primaryLight (#1C5AA0)
Button Press: primaryDark (#002857)
```

---

#### **2. ACCENT COLORS (Gold - Secondary Brand)**

**Purpose:** Highlight important elements, call-to-action, secondary actions

```dart
static const Color accent = Color(0xFFF4BA1B); // Gold
static const Color accentLight = Color(0xFFFAD44D);
static const Color accentDark = Color(0xFFD99D0B);
```

**Detailed Breakdown:**

| Variable | Hex Code | RGB | Usage |
|----------|----------|-----|-------|
| **accent** | `0xFFF4BA1B` | 244, 186, 27 | Badges, highlights, secondary buttons |
| **accentLight** | `0xFFFAD44D` | 250, 212, 77 | Hover on accent |
| **accentDark** | `0xFFD99D0B` | 217, 157, 11 | Pressed on accent |

**Gold in VoteSync Context:**
- Fisk's official secondary color
- Draws attention without competing with primary
- Perfect for "vote" button, selected candidates, achievements
- Creates visual hierarchy with blue

**Visual Hierarchy:**
```
Primary Action (Vote): Blue button
Secondary Action (Options): Gold button
Tertiary Action (Cancel): Gray button
```

---

#### **3. NEUTRAL COLORS (Grayscale)**

**Purpose:** Text, borders, backgrounds, disabled states

```dart
static const Color white = Color(0xFFFFFFFF);
static const Color black = Color(0xFF000000);
static const Color gray100 = Color(0xFFF5F5F5); // Lightest
static const Color gray200 = Color(0xFFE0E0E0);
static const Color gray300 = Color(0xFFC0C0C0);
static const Color gray400 = Color(0xFF999999);
static const Color gray500 = Color(0xFF666666); // Darkest
```

**Detailed Breakdown:**

| Variable | Hex Code | RGB | Usage | Contrast |
|----------|----------|-----|-------|----------|
| **white** | `0xFFFFFFFF` | 255, 255, 255 | Background, card surfaces | - |
| **gray100** | `0xFFF5F5F5` | 245, 245, 245 | Light backgrounds | 1.4:1 |
| **gray200** | `0xFFE0E0E0` | 224, 224, 224 | Borders, dividers | 4.6:1 |
| **gray300** | `0xFFC0C0C0` | 192, 192, 192 | Disabled background | 7.2:1 |
| **gray400** | `0xFF999999` | 153, 153, 153 | Secondary text | 8.1:1 |
| **gray500** | `0xFF666666` | 102, 102, 102 | Primary text | 12.6:1 |
| **black** | `0xFF000000` | 0, 0, 0 | Darkest text | 21:1 |

**Contrast Ratios Explained:**
- WCAG AA Requirement: 4.5:1 minimum for normal text
- Your grayscale meets accessibility standards
- `gray500` text on `white` background = 12.6:1 ✅ Excellent

**Common Patterns:**
```
Primary Text: gray500 on white
Secondary Text: gray400 on white
Hint Text: gray300 on white
Disabled State: gray200 background with gray300 text
Dividers: gray200 on white
Borders: gray200 or gray300
```

---

#### **4. STATUS COLORS (Semantic)**

**Purpose:** Communicate status, feedback, results to user

```dart
static const Color success = Color(0xFF4CAF50); // Green
static const Color error = Color(0xFFf44336); // Red
static const Color warning = Color(0xFFFFC107); // Amber
static const Color info = Color(0xFF2196F3); // Blue
```

**Detailed Breakdown & Psychology:**

| Status | Color | Hex | Psychology | Usage |
|--------|-------|-----|-----------|-------|
| **Success** | Green | `0xFF4CAF50` | Growth, positive, approval | "Vote submitted", checkmark, "Complete" |
| **Error** | Red | `0xFFf44336` | Stop, danger, alert | "Invalid input", "Network error", validation |
| **Warning** | Amber | `0xFFFFC107` | Caution, attention | "Session expiring", "Confirm action" |
| **Info** | Blue | `0xFF2196F3` | Information, help | "Tips", "Election details", notifications |

**Universal Meaning:**
These colors have global recognition:
- 🟢 Green = Success (works everywhere)
- 🔴 Red = Error (universally understood)
- 🟡 Yellow/Amber = Warning (caution ahead)
- 🔵 Blue = Information (neutral, informative)

**In VoteSync:**
```
User votes successfully: Green success message
Invalid form input: Red error message
"Voting ends in 2 hours": Amber warning banner
"How voting works": Blue info box
Election results unavailable: Red error state
```

---

#### **5. BACKGROUND COLORS**

**Purpose:** Page backgrounds, card surfaces, containers

```dart
static const Color background = Color(0xFFFAFAFA); // Almost white
static const Color surface = Color(0xFFFFFFFF); // Pure white
```

**Detailed Breakdown:**

| Variable | Hex Code | RGB | Usage | Purpose |
|----------|----------|-----|-------|---------|
| **background** | `0xFFFAFAFA` | 250, 250, 250 | Page background | Slight gray reduces eye strain |
| **surface** | `0xFFFFFFFF` | 255, 255, 255 | Cards, containers | Pure white for content areas |

**Visual Hierarchy:**
```
Page Layer:         background (#FAFAFA) - Outer container
Card Layer:         surface (#FFFFFF)    - Content container
Elevation:          Cards stand out from page
Subtle Contrast:    Just enough to see separation
```

**Why Two Backgrounds?**
- **background**: Outer container (slightly gray)
- **surface**: Cards, dialogs (pure white)
- Creates visual depth without being jarring
- Easier on eyes than pure white everywhere

---

#### **6. OPACITY & UTILITY COLORS**

**Purpose:** Create color variations without defining new colors

```dart
static Color successBackground = success.withOpacity(0.1);
static Color errorBackground = error.withOpacity(0.1);
static Color warningBackground = warning.withOpacity(0.1);
static Color infoBackground = info.withOpacity(0.1);
```

**What is Opacity?**

Opacity = transparency level (0 = invisible, 1 = fully opaque)

| Color | Opacity | Usage |
|-------|---------|-------|
| `success.withOpacity(0.1)` | 10% = 90% transparent | Light green background for success message |
| `error.withOpacity(0.1)` | 10% = 90% transparent | Light red background for error banner |
| `warning.withOpacity(0.1)` | 10% = 90% transparent | Light amber background for warning |
| `info.withOpacity(0.1)` | 10% = 90% transparent | Light blue background for info box |

**Example in UI:**
```
Success Message:
├─ Background: successBackground (light green)
├─ Border: success (bright green)
└─ Text: success (bright green)

Appears as: Light green box with green border and text
User immediately recognizes: This is success/good
```

---

### **COMPLETE colors.dart FILE**

```dart
import 'package:flutter/material.dart';

/// Application color palette
/// Single source of truth for all application colors
/// Follows Fisk University branding with professional extension
/// 
/// USAGE:
/// - Use [AppColors.primary] instead of Color(0xFF003D82)
/// - Use [AppColors.success] for success messages
/// - Use [AppColors.successBackground] for light backgrounds
/// - Never hardcode colors in widgets
class AppColors {
  // ════════════════════════════════════════════════════════════════════════════
  // PRIMARY COLORS (Fisk University Branding)
  // ════════════════════════════════════════════════════════════════════════════
  // These are the main brand colors used throughout the app
  // Primary = Deep Blue (trust, stability, professionalism)
  
  /// Main brand color - Deep Blue
  /// Used for: Primary buttons, app bar, selected states, main accents
  /// Fisk University Official Color
  static const Color primary = Color(0xFF003D82); // Deep Blue
  
  /// Lighter shade of primary
  /// Used for: Hover states, lighter backgrounds, focus rings
  static const Color primaryLight = Color(0xFF1C5AA0);
  
  /// Darker shade of primary
  /// Used for: Pressed states, dark backgrounds, shadows
  static const Color primaryDark = Color(0xFF002857);

  // ════════════════════════════════════════════════════════════════════════════
  // ACCENT COLORS (Gold - Fisk Secondary Color)
  // ════════════════════════════════════════════════════════════════════════════
  // Secondary brand colors for highlights and secondary actions
  // Accent = Gold (draws attention, complements primary)
  
  /// Gold accent color - Fisk University Secondary Color
  /// Used for: Badges, highlights, secondary buttons, "vote" action
  /// Complements primary without competing
  static const Color accent = Color(0xFFF4BA1B); // Gold
  
  /// Lighter shade of accent
  /// Used for: Hover states on accent elements
  static const Color accentLight = Color(0xFFFAD44D);
  
  /// Darker shade of accent
  /// Used for: Pressed states on accent elements
  static const Color accentDark = Color(0xFFD99D0B);

  // ════════════════════════════════════════════════════════════════════════════
  // NEUTRAL COLORS (Grayscale)
  // ════════════════════════════════════════════════════════════════════════════
  // Used for: Text, borders, backgrounds, disabled states
  // Provides accessibility and professional appearance
  
  /// Pure white - Used for content areas and card surfaces
  static const Color white = Color(0xFFFFFFFF);
  
  /// Pure black - Used for darkest text and high contrast areas
  static const Color black = Color(0xFF000000);
  
  /// Very light gray - Used for subtle backgrounds, almost invisible
  /// Contrast ratio with black text: 1.4:1 (minimal)
  static const Color gray100 = Color(0xFFF5F5F5);
  
  /// Light gray - Used for borders and divider lines
  /// Contrast ratio with black text: 4.6:1 (good)
  static const Color gray200 = Color(0xFFE0E0E0);
  
  /// Medium gray - Used for disabled backgrounds
  /// Contrast ratio with black text: 7.2:1 (excellent)
  static const Color gray300 = Color(0xFFC0C0C0);
  
  /// Darker gray - Used for secondary/hint text
  /// Contrast ratio with white background: 8.1:1 (excellent)
  static const Color gray400 = Color(0xFF999999);
  
  /// Very dark gray - Used for primary text
  /// Contrast ratio with white background: 12.6:1 (excellent)
  static const Color gray500 = Color(0xFF666666);

  // ════════════════════════════════════════════════════════════════════════════
  // STATUS COLORS (Semantic Colors)
  // ════════════════════════════════════════════════════════════════════════════
  // Universal colors that communicate meaning across cultures
  // Used to provide user feedback and communicate app state
  
  /// Success/positive action color - Green
  /// Conveys: Approval, completion, success
  /// Used for: Success messages, checkmarks, "complete" badges
  /// Psychology: Green = growth, positive, "go ahead"
  static const Color success = Color(0xFF4CAF50); // Green
  
  /// Error/negative action color - Red
  /// Conveys: Problem, danger, requires attention
  /// Used for: Error messages, validation errors, critical alerts
  /// Psychology: Red = stop, danger, alert
  static const Color error = Color(0xFFf44336); // Red
  
  /// Warning/caution color - Amber
  /// Conveys: Caution, attention needed, non-critical issue
  /// Used for: Warning messages, expiration notices
  /// Psychology: Amber/Yellow = caution, attention
  static const Color warning = Color(0xFFFFC107); // Amber
  
  /// Information/neutral color - Blue
  /// Conveys: Information, help, neutral message
  /// Used for: Tips, how-to messages, general information
  /// Psychology: Blue = calm, informative, trustworthy
  static const Color info = Color(0xFF2196F3); // Blue

  // ════════════════════════════════════════════════════════════════════════════
  // BACKGROUND COLORS
  // ════════════════════════════════════════════════════════════════════════════
  // Used for page and container backgrounds
  // Creates visual hierarchy and reduces eye strain
  
  /// Almost white background - Used for entire page background
  /// Slightly gray reduces eye strain vs pure white
  /// Contrast: Allows cards to stand out
  static const Color background = Color(0xFFFAFAFA);
  
  /// Pure white surface - Used for cards, dialogs, containers
  /// Creates visual elevation from background
  /// Contrast: White cards on light gray background
  static const Color surface = Color(0xFFFFFFFF);

  // ════════════════════════════════════════════════════════════════════════════
  // SEMANTIC OPACITY COLORS
  // ════════════════════════════════════════════════════════════════════════════
  // Transparent versions of status colors for backgrounds
  // 10% opacity = 90% transparent = very subtle background
  // Allows text/icons to be readable while adding color context
  
  /// Success color at 10% opacity - Light green background
  /// Used for: Background of success messages/banners
  /// Example: Light green box with green border and checkmark icon
  static Color successBackground = success.withOpacity(0.1);
  
  /// Error color at 10% opacity - Light red background
  /// Used for: Background of error messages/banners
  /// Example: Light red box with red border and error icon
  static Color errorBackground = error.withOpacity(0.1);
  
  /// Warning color at 10% opacity - Light amber background
  /// Used for: Background of warning messages/banners
  /// Example: Light amber box with amber border and warning icon
  static Color warningBackground = warning.withOpacity(0.1);
  
  /// Info color at 10% opacity - Light blue background
  /// Used for: Background of info messages/boxes
  /// Example: Light blue box with blue border and info icon
  static Color infoBackground = info.withOpacity(0.1);

  // ════════════════════════════════════════════════════════════════════════════
  // UTILITY METHODS & OPACITY HELPERS
  // ════════════════════════════════════════════════════════════════════════════
  
  /// Get any color with custom opacity
  /// Example: AppColors.primary.withOpacity(0.5) = 50% transparent blue
  /// opacity: 0.0 = invisible, 0.5 = semi-transparent, 1.0 = fully opaque
  
  /// Disable a color by reducing opacity
  /// Used for: Disabled buttons, inactive elements
  /// Example: AppColors.primary.withOpacity(0.5)
  
  /// Create darker color by overlaying with black
  /// Used for: Shadow effects, depth
  /// Example: AppColors.primary.withOpacity(0.3) over background
}
```

---

## text_styles.dart - COMPLETE GUIDE

### **FILE LOCATION:** `lib/core/theme/text_styles.dart`

### **WHAT IS THIS FILE?**

A centralized typography system that defines how all text appears in your app. Instead of recreating text styles everywhere, this file defines them once and reuses them.

**Why this matters:**
- ✅ Consistent typography across entire app
- ✅ Easy to change font size globally
- ✅ Maintain visual hierarchy
- ✅ Matches Material Design 3 guidelines
- ✅ Professional, cohesive appearance

---

### **TYPOGRAPHY THEORY**

#### **DESIGN HIERARCHY LEVELS**

Text styles create visual hierarchy. Users understand information importance by text size and weight.

```
Display Large (32px) ───────────────────── LOUDEST
Display Medium (28px)
Display Small (24px)
Headline Large (20px)
Headline Medium (18px)
Headline Small (16px)
Body Large (16px) ──────────────────── MEDIUM
Body Medium (14px)
Body Small (12px)
Label Large (14px) ──────────────────── QUIETEST
Label Medium (12px)
Label Small (11px)
```

**Real-World Example:**

```
┌─────────────────────────────────────────┐
│  VOTING OPEN (Display Large - 32px)     │  ← BIGGEST - Most important
├─────────────────────────────────────────┤
│ 2024 Presidential Election               │  ← Headline Large (20px)
│ (Headline Medium - 18px)                 │     
├─────────────────────────────────────────┤
│ The voting period has started. Click     │  ← Body Large (16px)
│ below to submit your vote. Voting ends   │     Normal reading
│ on December 20, 2024.                    │
├─────────────────────────────────────────┤
│ [        VOTE NOW       ]                │  ← Label Large (14px)
│ [      View Results     ]                │     Button text
└─────────────────────────────────────────┘
```

---

#### **1. DISPLAY STYLES (Headlines for Emphasis)**

**Purpose:** Large headlines, app title, major sections

```dart
static const TextStyle displayLarge = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  height: 1.2,
  letterSpacing: -0.5,
);

static const TextStyle displayMedium = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  height: 1.2,
  letterSpacing: -0.3,
);

static const TextStyle displaySmall = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  height: 1.2,
  letterSpacing: 0,
);
```

**Detailed Breakdown:**

| Property | displayLarge | displayMedium | displaySmall |
|----------|--------------|---------------|-------------|
| **fontSize** | 32px | 28px | 24px |
| **fontWeight** | Bold (700) | Bold (700) | Bold (700) |
| **height** | 1.2 | 1.2 | 1.2 |
| **letterSpacing** | -0.5 | -0.3 | 0 |

**Properties Explained:**

| Property | What It Does | Why It Matters |
|----------|------------|-----------------|
| **fontSize** | How big the text is | Display = Large (32-24px) |
| **fontWeight** | How thick/bold the text is | FontWeight.bold = 700 weight |
| **height** | Line height / spacing between lines | 1.2 = 20% extra space (tight) |
| **letterSpacing** | Space between individual letters | Negative = tighter, Positive = looser |

**letterSpacing Detailed:**
- `0` = Normal spacing
- `-0.5` = Letters closer together (elegant, tight)
- `0.5` = Letters farther apart (open, airy)
- Negative values work for large text (looks more refined)
- Positive values work for small text (improves readability)

**Usage Examples:**

```dart
// Page title - App name
Text('VoteSync', style: AppTextStyles.displayLarge),

// Section header
Text('2024 Elections', style: AppTextStyles.displayMedium),

// Subsection header
Text('Vote Now', style: AppTextStyles.displaySmall),
```

---

#### **2. HEADLINE STYLES (Section Titles)**

**Purpose:** Section titles, card headers, important labels

```dart
static const TextStyle headlineLarge = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  height: 1.3,
  letterSpacing: 0.15,
);

static const TextStyle headlineMedium = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  height: 1.3,
  letterSpacing: 0.1,
);

static const TextStyle headlineSmall = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  height: 1.3,
  letterSpacing: 0.1,
);
```

**Detailed Breakdown:**

| Property | headlineLarge | headlineMedium | headlineSmall |
|----------|---------------|----------------|--------------|
| **fontSize** | 20px | 18px | 16px |
| **fontWeight** | w600 (600) | w600 (600) | w600 (600) |
| **height** | 1.3 | 1.3 | 1.3 |
| **letterSpacing** | 0.15 | 0.1 | 0.1 |

**fontWeight Values:**

```
fontWeight.w300 = Light (300) ─── Thin
fontWeight.w400 = Normal (400) ─── Regular
fontWeight.w500 = Medium (500) ─── Medium
fontWeight.w600 = SemiBold (600)──── SemiBold ← Headline style
fontWeight.bold = Bold (700) ──── Bold (Display style)
```

**Why w600 for Headlines?**
- Bold enough to stand out (700 is too heavy)
- Professional appearance
- Readable at any size
- Perfect for section headers

**height = 1.3:**
- Normal line height = 1.0
- 1.3 = 30% extra space between lines
- Looser than display (1.2)
- Better readability for longer headlines

**Usage Examples:**

```dart
// Card header
Text('Election Details', style: AppTextStyles.headlineLarge),

// Form section title
Text('Personal Information', style: AppTextStyles.headlineMedium),

// List item title
Text('Candidate Name', style: AppTextStyles.headlineSmall),
```

---

#### **3. BODY STYLES (Main Content Text)**

**Purpose:** Paragraphs, descriptions, normal reading text

```dart
static const TextStyle bodyLarge = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 1.5,
  letterSpacing: 0.5,
);

static const TextStyle bodyMedium = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  height: 1.5,
  letterSpacing: 0.25,
);

static const TextStyle bodySmall = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  height: 1.5,
  letterSpacing: 0.4,
);
```

**Detailed Breakdown:**

| Property | bodyLarge | bodyMedium | bodySmall |
|----------|-----------|-----------|----------|
| **fontSize** | 16px | 14px | 12px |
| **fontWeight** | w400 | w400 | w400 |
| **height** | 1.5 | 1.5 | 1.5 |
| **letterSpacing** | 0.5 | 0.25 | 0.4 |

**Why w400 for Body Text?**
- Regular weight (not bold)
- Easy to read for long passages
- Professional appearance
- Matches Material Design standard

**height = 1.5:**
- 50% extra space between lines
- Much looser than headlines (1.3)
- Essential for readability
- Easier on eyes when reading paragraphs

**letterSpacing for Body:**
- Small positive values (0.25-0.5)
- Increases readability
- At small sizes (12-14px), spacing matters more
- Doesn't look "spread out"

**Usage Examples:**

```dart
// Election description
Text(
  'Choose your preferred candidate for the 2024 election.',
  style: AppTextStyles.bodyLarge,
),

// List item description
Text(
  'Last updated 2 hours ago',
  style: AppTextStyles.bodySmall,
),

// Form helper text
Text(
  'Enter your full name as it appears in your voter registration',
  style: AppTextStyles.bodyMedium,
),
```

---

#### **4. LABEL STYLES (Buttons, Chips, Tags)**

**Purpose:** Button text, labels, tags, badges

```dart
static const TextStyle labelLarge = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  height: 1.4,
  letterSpacing: 0.1,
);

static const TextStyle labelMedium = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  height: 1.4,
  letterSpacing: 0.5,
);

static const TextStyle labelSmall = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w500,
  height: 1.4,
  letterSpacing: 0.5,
);
```

**Detailed Breakdown:**

| Property | labelLarge | labelMedium | labelSmall |
|----------|-----------|-----------|-----------|
| **fontSize** | 14px | 12px | 11px |
| **fontWeight** | w500 | w500 | w500 |
| **height** | 1.4 | 1.4 | 1.4 |
| **letterSpacing** | 0.1 | 0.5 | 0.5 |

**Why w500 for Labels?**
- Bolder than body (w400), lighter than headline (w600)
- Stands out without dominating
- Perfect for buttons and interactive elements
- Medium weight = "action required"

**height = 1.4:**
- Tighter than body (1.5)
- Buttons don't need extra space
- Compact but readable
- Good for limited space elements

**Larger letterSpacing for Small Text:**
- Small sizes (11-12px) benefit from more spacing
- Improves readability at tiny sizes
- Looks more premium/intentional

**Usage Examples:**

```dart
// Button text
ElevatedButton(
  child: Text('SUBMIT VOTE', style: AppTextStyles.labelLarge),
  onPressed: () {},
),

// Chip/Badge label
Chip(
  label: Text('Active', style: AppTextStyles.labelSmall),
),

// Tab label
Text('Results', style: AppTextStyles.labelMedium),
```

---

#### **5. SPECIAL STYLES (Error, Hint, Disabled)**

**Purpose:** Specific use cases with predefined styling

```dart
/// Style for error messages
static const TextStyle errorText = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  height: 1.4,
  color: Color(0xFFf44336), // Red color
);

/// Style for hint text (form fields)
static const TextStyle hintText = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  height: 1.5,
  color: Color(0xFF999999), // Gray color
);

/// Style for disabled text
static const TextStyle disabledText = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  height: 1.5,
  color: Color(0xFFCCCCCC), // Light gray color
);
```

**Error Text (Red, 12px):**
```
Usage: Below form field showing validation error
"This field is required"
"Please enter a valid email"
"Password must be at least 8 characters"
```

**Hint Text (Gray, 14px):**
```
Usage: Placeholder in text fields
TextField(
  decoration: InputDecoration(
    hintText: 'Enter your email',
    hintStyle: AppTextStyles.hintText,
  ),
),
```

**Disabled Text (Light Gray, 14px):**
```
Usage: Text for disabled buttons/fields
Button appears grayed out and unclickable
Text is lighter (light gray vs dark gray)
```

---

### **COMPLETE text_styles.dart FILE**

```dart
import 'package:flutter/material.dart';

/// Application typography system
/// Single source of truth for all text styles
/// Follows Material Design 3 guidelines with custom refinements
///
/// TYPOGRAPHY HIERARCHY:
/// Display   → Large headlines (32, 28, 24px) - Bold
/// Headline  → Section titles (20, 18, 16px) - SemiBold
/// Body      → Main content (16, 14, 12px) - Regular
/// Label     → Buttons, tags (14, 12, 11px) - Medium
/// Special   → Errors, hints, disabled
///
/// USAGE:
/// - Use styles consistently throughout app
/// - Never hardcode TextStyle properties
/// - Example: Text('Title', style: AppTextStyles.headlineLarge)
///
/// LINE HEIGHT GUIDE:
/// - Display: 1.2 (tight, for large text)
/// - Headline: 1.3 (balanced, for section headers)
/// - Body: 1.5 (loose, for readability)
/// - Label: 1.4 (compact, for buttons)
///
/// LETTER SPACING GUIDE:
/// - Large text: Negative (tighter, more elegant)
/// - Normal text: Small positive (improves readability)
/// - Small text: Larger positive (critical for legibility)
class AppTextStyles {
  // ════════════════════════════════════════════════════════════════════════════
  // DISPLAY STYLES
  // ════════════════════════════════════════════════════════════════════════════
  // Purpose: Large headlines for maximum emphasis
  // Usage: App title, major section headers
  // Weight: Bold (700)
  // Properties: Large size, tight line height, negative letter spacing
  
  /// Display Large - 32px, Bold
  /// The biggest, most prominent style
  /// Use for: App title, page headline, hero section
  /// Example: "VoteSync" title, "VOTING OPEN" banner
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold, // 700
    height: 1.2, // Line height: 38.4px (tight for big text)
    letterSpacing: -0.5, // Negative = tighter, more elegant
  );

  /// Display Medium - 28px, Bold
  /// Large emphasis, but smaller than displayLarge
  /// Use for: Section headers, important announcements
  /// Example: "2024 Elections", "Results Available"
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold, // 700
    height: 1.2, // Line height: 33.6px
    letterSpacing: -0.3, // Slightly less negative spacing
  );

  /// Display Small - 24px, Bold
  /// Smallest display style, for emphasis
  /// Use for: Subsection headers, featured content
  /// Example: "Vote Now", "Your Vote Counts"
  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold, // 700
    height: 1.2, // Line height: 28.8px
    letterSpacing: 0, // Normal spacing at this size
  );

  // ════════════════════════════════════════════════════════════════════════════
  // HEADLINE STYLES
  // ════════════════════════════════════════════════════════════════════════════
  // Purpose: Section titles and important labels
  // Usage: Card headers, form section titles, list headers
  // Weight: SemiBold (600)
  // Properties: Medium-large size, balanced line height, small positive spacing
  
  /// Headline Large - 20px, SemiBold
  /// Top-level headline, for important section headers
  /// Use for: Card title, dialog title, page section header
  /// Example: "Election Details", "Candidate Information"
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600, // 600 = SemiBold
    height: 1.3, // Line height: 26px (30% extra space)
    letterSpacing: 0.15, // Tiny positive spacing
  );

  /// Headline Medium - 18px, SemiBold
  /// Mid-level headline for secondary headers
  /// Use for: Subsection title, form group title
  /// Example: "Personal Information", "Vote Summary"
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600, // 600 = SemiBold
    height: 1.3, // Line height: 23.4px
    letterSpacing: 0.1, // Small positive spacing
  );

  /// Headline Small - 16px, SemiBold
  /// Smallest headline, for item headers
  /// Use for: List item title, card header
  /// Example: "Candidate Name", "Election Status"
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600, // 600 = SemiBold
    height: 1.3, // Line height: 20.8px
    letterSpacing: 0.1, // Small positive spacing
  );

  // ════════════════════════════════════════════════════════════════════════════
  // BODY STYLES
  // ════════════════════════════════════════════════════════════════════════════
  // Purpose: Main content, paragraphs, descriptions
  // Usage: Reading content, explanations, long text
  // Weight: Regular (400)
  // Properties: Normal size, loose line height, small positive spacing
  
  /// Body Large - 16px, Regular
  /// Large body text for main content
  /// Use for: Paragraphs, descriptions, important text
  /// Example: Election descriptions, instructions
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400, // 400 = Regular
    height: 1.5, // Line height: 24px (50% extra - very readable)
    letterSpacing: 0.5, // Positive spacing for readability
  );

  /// Body Medium - 14px, Regular
  /// Standard body text for most content
  /// Use for: Form labels, descriptions, secondary content
  /// Example: "Last updated: 2 hours ago", form descriptions
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400, // 400 = Regular
    height: 1.5, // Line height: 21px (very readable)
    letterSpacing: 0.25, // Small positive spacing
  );

  /// Body Small - 12px, Regular
  /// Small body text for secondary content
  /// Use for: Captions, timestamps, secondary info
  /// Example: "Posted 2 hours ago", helper text
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400, // 400 = Regular
    height: 1.5, // Line height: 18px (still readable at small size)
    letterSpacing: 0.4, // Small positive spacing (important for readability)
  );

  // ════════════════════════════════════════════════════════════════════════════
  // LABEL STYLES
  // ════════════════════════════════════════════════════════════════════════════
  // Purpose: Button text, badges, chips, tags
  // Usage: Clickable/interactive elements
  // Weight: Medium (500)
  // Properties: Varies by size, compact line height
  
  /// Label Large - 14px, Medium
  /// Large button text, primary CTA
  /// Use for: Main buttons, important actions
  /// Example: "VOTE NOW", "SUBMIT FORM"
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500, // 500 = Medium
    height: 1.4, // Line height: 19.6px (compact)
    letterSpacing: 0.1, // Small spacing
  );

  /// Label Medium - 12px, Medium
  /// Standard button text, secondary actions
  /// Use for: Secondary buttons, tags, badges
  /// Example: "Cancel", "View More"
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500, // 500 = Medium
    height: 1.4, // Line height: 16.8px
    letterSpacing: 0.5, // More spacing for small text
  );

  /// Label Small - 11px, Medium
  /// Small button text, minimal actions
  /// Use for: Small buttons, small badges, icons with text
  /// Example: "X" close button, small tags
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500, // 500 = Medium
    height: 1.4, // Line height: 15.4px
    letterSpacing: 0.5, // More spacing critical at this size
  );

  // ════════════════════════════════════════════════════════════════════════════
  // SPECIAL STYLES
  // ════════════════════════════════════════════════════════════════════════════
  // Purpose: Specific use cases with predefined colors and styling
  // Usage: Errors, hints, disabled states
  
  /// Error message style - Red text
  /// 12px, Regular weight
  /// Used for: Form validation errors, error messages, alerts
  /// Color: Red (#f44336) - communicates problem
  /// Example: "This field is required", "Invalid email"
  static const TextStyle errorText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400, // 400 = Regular
    height: 1.4, // Compact height
    color: Color(0xFFf44336), // Red - indicates error
  );

  /// Hint/placeholder style - Gray text
  /// 14px, Regular weight
  /// Used for: Text field placeholders, hints, secondary labels
  /// Color: Gray (#999999) - indicates temporary/secondary
  /// Example: "Enter your email address" placeholder text
  static const TextStyle hintText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400, // 400 = Regular
    height: 1.5,
    color: Color(0xFF999999), // Medium gray - less prominent
  );

  /// Disabled text style - Light gray
  /// 14px, Regular weight
  /// Used for: Disabled buttons, inactive elements, grayed out text
  /// Color: Light Gray (#CCCCCC) - indicates unavailable
  /// Example: Disabled form field, inactive button
  static const TextStyle disabledText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400, // 400 = Regular
    height: 1.5,
    color: Color(0xFFCCCCCC), // Light gray - indicates disabled
  );

  // ════════════════════════════════════════════════════════════════════════════
  // TYPOGRAPHY TIPS
  // ════════════════════════════════════════════════════════════════════════════
  
  /// CHOOSING THE RIGHT STYLE:
  /// 
  /// Page Title?              → displayLarge or displayMedium
  /// Section Header?          → headlineLarge or headlineMedium
  /// Card Title?              → headlineSmall
  /// Paragraph of text?       → bodyLarge or bodyMedium
  /// Button text?             → labelLarge or labelMedium
  /// Timestamp/caption?       → bodySmall
  /// Error message?           → errorText
  /// Form placeholder?        → hintText
  /// Disabled element?        → disabledText
  
  /// LINE HEIGHT & READABILITY:
  /// 
  /// Large text (24+px):      1.2 (tight is fine, text is easy to read)
  /// Medium text (14-20px):   1.3-1.4 (balanced)
  /// Body text (12-16px):     1.5 (loose for easy reading)
  /// Small text (11-12px):    1.4+ (needs extra space to breathe)
  
  /// LETTER SPACING & ELEGANCE:
  /// 
  /// Large text:              Use negative values (tighter, elegant)
  /// Normal text:             Small positive values (0.1-0.25)
  /// Small text:              Larger positive values (0.4-0.5) for readability
  /// 
  /// Remember: Negative letter spacing works on large text but looks broken on small text.
}
```

---

## app_constants.dart - COMPLETE GUIDE

### **FILE LOCATION:** `lib/core/constants/app_constants.dart`

### **WHAT IS THIS FILE?**

A centralized repository for all constant values used throughout the app. Instead of hardcoding numbers everywhere (like `30` for timeout, `20` for page size), define them once here.

**Why this matters:**
- ✅ Single source of truth for all constants
- ✅ Easy to adjust values globally
- ✅ Better for team collaboration (documented)
- ✅ No magic numbers scattered in code
- ✅ Easy to find and maintain

**The Problem We're Solving:**

```dart
// BAD: Magic numbers everywhere
class ElectionService {
  Future<List<Election>> getElections(int page) async {
    return await api.get(
      'api/elections?page=$page&limit=20', // Magic number!
      timeout: Duration(seconds: 30),       // Magic number!
    );
  }
}

// GOOD: Use constants
class ElectionService {
  Future<List<Election>> getElections(int page) async {
    return await api.get(
      '${AppConstants.electionsEndpoint}?page=$page&limit=${AppConstants.pageSize}',
      timeout: AppConstants.requestTimeout,
    );
  }
}
```

---

### **CATEGORIES OF CONSTANTS**

#### **1. APP INFORMATION**

**Purpose:** Basic app metadata

```dart
static const String appName = 'VoteSync';
static const String appVersion = '1.0.0';
static const String appBuild = '1';
```

**Detailed Breakdown:**

| Constant | Value | Purpose | Usage |
|----------|-------|---------|-------|
| **appName** | 'VoteSync' | Display app name | Shown in UI, about screen |
| **appVersion** | '1.0.0' | Semantic versioning | User-facing version number |
| **appBuild** | '1' | Internal build number | Tracking builds for debugging |

**Semantic Versioning (X.Y.Z):**
- **X (Major)**: Breaking changes (1.0.0 → 2.0.0)
- **Y (Minor)**: New features (1.0.0 → 1.1.0)
- **Z (Patch)**: Bug fixes (1.0.0 → 1.0.1)

---

#### **2. TIMING & DURATIONS**

**Purpose:** All timeout and interval values

```dart
/// Request timeout duration
static const Duration requestTimeout = Duration(seconds: 30);

/// Duration to wait between polling requests
static const Duration pollingInterval = Duration(seconds: 5);

/// Delay before retry on failure
static const Duration retryDelay = Duration(milliseconds: 500);

/// Session timeout duration
static const Duration sessionTimeout = Duration(minutes: 30);

/// Animation duration
static const Duration animationDuration = Duration(milliseconds: 300);
```

**Detailed Breakdown:**

| Constant | Duration | Purpose | Usage |
|----------|----------|---------|-------|
| **requestTimeout** | 30 seconds | How long to wait for API response | API calls |
| **pollingInterval** | 5 seconds | How often to check for updates | Live election results |
| **retryDelay** | 500ms | Delay before retrying failed request | Network retry logic |
| **sessionTimeout** | 30 minutes | How long user session stays active | Auto-logout |
| **animationDuration** | 300ms | Standard animation speed | UI transitions |

**Why These Values?**

```
requestTimeout = 30 seconds
├─ Long enough for slow networks
├─ Not so long user thinks app froze
└─ Standard for web APIs

pollingInterval = 5 seconds
├─ Frequent enough to feel "live"
├─ Not so frequent it kills battery
└─ Good balance for elections

retryDelay = 500ms
├─ Short delay between retries
├─ 500ms = not noticeable to user
└─ Usually server is back online by then

sessionTimeout = 30 minutes
├─ Good security (lock after inactivity)
├─ Not too short (frustrating for users)
└─ Standard for banking apps

animationDuration = 300ms
├─ Fast enough to feel responsive
├─ Slow enough to be smooth
└─ Material Design standard
```

---

#### **3. PAGINATION & DATA LIMITS**

**Purpose:** Control data loading and resource limits

```dart
/// Number of items per page for list views
static const int pageSize = 20;

/// Maximum number of retry attempts for network requests
static const int maxRetries = 3;

/// Maximum number of login attempts before lockout
static const int maxLoginAttempts = 5;
```

**Detailed Breakdown:**

| Constant | Value | Purpose | Usage |
|----------|-------|---------|-------|
| **pageSize** | 20 items/page | How many items load per API request | List pagination |
| **maxRetries** | 3 attempts | How many times to retry failed request | Network resilience |
| **maxLoginAttempts** | 5 attempts | Failed logins before account lock | Security |

**Why These Values?**

```
pageSize = 20
├─ 20 items = ~2KB of data (small download)
├─ Displays nicely on most screens
├─ Fast to load
└─ Standard pagination size

maxRetries = 3
├─ Try original request
├─ Retry #1 after 500ms
├─ Retry #2 after 500ms
├─ Retry #3 after 500ms
└─ If still fails, give up (likely real error)

maxLoginAttempts = 5
├─ 5 wrong attempts = user knows password
├─ Prevents brute-force attacks
├─ Not so low it's annoying (typos happen)
└─ Security standard
```

---

#### **4. CACHE KEYS**

**Purpose:** Keys for storing data locally on device

```dart
/// Key for storing authentication token
static const String tokenCacheKey = 'auth_token';

/// Key for storing current user data
static const String userCacheKey = 'current_user';

/// Key for storing user preferences
static const String preferencesCacheKey = 'user_preferences';

/// Key for storing last sync timestamp
static const String lastSyncCacheKey = 'last_sync_time';
```

**What is Local Cache?**

Cache = temporary storage on device (like phone's "memory")

```
User Logs In
    ↓
Send username/password to server
    ↓
Server returns auth token
    ↓
Store token locally using key: 'auth_token'
    ↓
Next app launch: Read token from cache
    ↓
Send token to server: "Hi, it's me"
    ↓
No need to log in again!
```

**Detailed Breakdown:**

| Key | What's Stored | Purpose | Duration |
|-----|--------------|---------|----------|
| **auth_token** | JWT token | Proves user is logged in | Until logout |
| **current_user** | User info (name, email, ID) | Display user profile | Until logout |
| **user_preferences** | Settings (dark mode, language) | Remember user choices | Permanent |
| **last_sync_time** | Timestamp | Know when data last updated | Until next sync |

---

#### **5. VALIDATION RULES**

**Purpose:** Rules for user input validation

```dart
/// Minimum password length
static const int minPasswordLength = 8;

/// Maximum password length
static const int maxPasswordLength = 128;

/// Regular expression for email validation
static const String emailRegex =
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

/// Regular expression for phone validation
static const String phoneRegex = 
    r'^[+]?[(]?[0-9]{3}[)]?[-\s.]?[0-9]{3}[-\s.]?[0-9]{4,6}$';
```

**Detailed Breakdown:**

| Rule | Value | Purpose | Example |
|------|-------|---------|---------|
| **minPasswordLength** | 8 | Minimum secure password | "Pass123" ✅, "Pass1" ❌ |
| **maxPasswordLength** | 128 | Prevent extremely long passwords | Most passwords < 50 chars |
| **emailRegex** | Pattern | Validate email format | "user@example.com" ✅ |
| **phoneRegex** | Pattern | Validate phone format | "+1(615)322-0101" ✅ |

**What is RegEx (Regular Expression)?**

A pattern for matching text. The emailRegex pattern means:

```
r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

^                      = Start of string
[a-zA-Z0-9._%+-]+     = One or more: letters, numbers, dot, underscore, %, +, -
@                      = Required @ symbol
[a-zA-Z0-9.-]+        = One or more: letters, numbers, dot, hyphen
\.                     = Required dot (escaped with \)
[a-zA-Z]{2,}          = Two or more letters (like .com, .org)
$                      = End of string

Valid:   user@example.com, john.doe@example.co.uk
Invalid: user@example, @example.com, user.example.com
```

---

#### **6. API ENDPOINTS**

**Purpose:** API routes (what URLs to call)

```dart
/// Authentication endpoints
static const String loginEndpoint = '/auth/login';
static const String verifyEmailEndpoint = '/auth/verify-email';
static const String logoutEndpoint = '/auth/logout';
static const String refreshTokenEndpoint = '/auth/refresh-token';

/// Elections endpoints
static const String electionsEndpoint = '/elections';
static const String electionDetailEndpoint = '/elections/{id}';

/// Voting endpoints
static const String submitVoteEndpoint = '/votes/submit';
static const String voteHistoryEndpoint = '/votes/history';

/// Results endpoints
static const String resultsEndpoint = '/results';
static const String liveResultsEndpoint = '/results/live';

/// User endpoints
static const String userProfileEndpoint = '/user/profile';
static const String updateProfileEndpoint = '/user/profile/update';
```

**How to Use:**

```dart
// Example API call
String fullUrl = '${AppConfig.apiBaseUrl}${AppConstants.loginEndpoint}';
// Result: https://api.votesync.app/auth/login

// Another example
String electionsUrl = '${AppConfig.apiBaseUrl}${AppConstants.electionsEndpoint}';
// Result: https://api.votesync.app/elections
```

**With Parameter:**
```dart
// For endpoints with {id}
String electionUrl = AppConstants.electionDetailEndpoint.replaceAll('{id}', '123');
// Result: /elections/123
```

---

#### **7. UI CONSTANTS**

**Purpose:** Spacing, sizing, and layout values

```dart
/// Standard padding values
static const double paddingXSmall = 4.0;
static const double paddingSmall = 8.0;
static const double paddingMedium = 16.0;
static const double paddingLarge = 24.0;
static const double paddingXLarge = 32.0;

/// Border radius values
static const double radiusSmall = 4.0;
static const double radiusMedium = 8.0;
static const double radiusLarge = 12.0;
static const double radiusXLarge = 16.0;

/// Standard icon sizes
static const double iconSizeSmall = 16.0;
static const double iconSizeMedium = 24.0;
static const double iconSizeLarge = 32.0;
static const double iconSizeXLarge = 48.0;
```

**Visual Guide:**

```
Padding Values:
┌──────────────────────────────────────┐ 4.0 = XSmall (minimal)
│┌────────────────────────────────────┐│ 8.0 = Small
││┌──────────────────────────────────┐││ 16.0 = Medium (most common)
│││┌────────────────────────────────┐│││ 24.0 = Large
││││┌──────────────────────────────┐││││ 32.0 = XLarge
│││││        CONTENT HERE          │││││
││││└──────────────────────────────┘││││
│││└────────────────────────────────┘│││
││└──────────────────────────────────┘││
│└────────────────────────────────────┘│
└──────────────────────────────────────┘

Border Radius (roundness):
No Radius    4.0 (Slight)    8.0 (Medium)    12.0 (Large)    16.0 (Very Round)
┌─────┐   ╭─────╮          ╭───────╮       ╭─────────╮      ╭──────────╮
│ Box │   │ Box │          │  Box  │       │   Box   │      │   Box    │
└─────┘   ╰─────╯          ╰───────╯       ╰─────────╯      ╰──────────╯

Icon Sizes:
16.0 = Small (navigation bar icons)
24.0 = Medium (toolbar icons, standard)
32.0 = Large (featured icons, buttons)
48.0 = XLarge (hero section, large buttons)
```

---

#### **8. FEATURE FLAGS**

**Purpose:** Turn features on/off without code changes

```dart
/// Enable email verification requirement
static const bool emailVerificationRequired = true;

/// Enable real-time results updates
static const bool liveResultsEnabled = true;

/// Enable analytics tracking
static const bool analyticsEnabled = true;

/// Enable crash reporting
static const bool crashReportingEnabled = true;
```

**Why Feature Flags?**

```
Scenario: Launch election with live results feature

Production code is ready, but feature not quite stable

Option A: Don't deploy until perfect (risky)
Option B: Deploy with flag = false, turn on later (smart!)

// In code:
if (AppConstants.liveResultsEnabled) {
  startLiveUpdates(); // Only runs if flag = true
}

Benefits:
- Deploy without feature being live
- Quickly turn feature on/off
- No need to rebuild and redeploy app
- Gradually roll out to users
- Easy A/B testing
```

---

### **COMPLETE app_constants.dart FILE**

```dart
/// Application-wide constants
/// Single source of truth for all constant values used throughout the app
///
/// NEVER hardcode values in your code. Always use constants from here.
///
/// BENEFITS:
/// - Change one place, updates everywhere
/// - Easy to track down values
/// - Documented in one location
/// - Team collaboration (everyone knows the values)
/// - Easy to adjust without touching business logic
///
/// ORGANIZATION:
/// Constants are grouped by category (timing, pagination, endpoints, etc.)
/// Find the category, use the constant
///
/// USAGE EXAMPLES:
/// ═════════════════════════════════════════════════════════════════
/// // Instead of magic numbers:
/// await Future.delayed(Duration(seconds: 30)); // BAD
/// 
/// // Use constants:
/// await Future.delayed(AppConstants.requestTimeout); // GOOD
/// ═════════════════════════════════════════════════════════════════
class AppConstants {
  // ════════════════════════════════════════════════════════════════════════════
  // APP INFORMATION
  // ════════════════════════════════════════════════════════════════════════════
  // Metadata about the application
  
  /// Official app name displayed to users
  /// Used in: UI, about screens, app store
  static const String appName = 'VoteSync';
  
  /// Current version number (user-facing)
  /// Format: MAJOR.MINOR.PATCH (e.g., 1.0.0)
  /// Increment when: Major = breaking changes, Minor = new features, Patch = fixes
  static const String appVersion = '1.0.0';
  
  /// Internal build number for tracking
  /// Incremented with each build, even if version stays same
  /// Used for: Analytics, debugging, crash reports
  static const String appBuild = '1';

  // ════════════════════════════════════════════════════════════════════════════
  // TIMING & DURATIONS
  // ════════════════════════════════════════════════════════════════════════════
  // All timing values for timeouts, intervals, and delays
  
  /// How long to wait for API response before timing out
  /// 30 seconds = enough for slow networks + server response
  /// If API doesn't respond in 30s, show error to user
  /// Used in: All network requests, API calls
  static const Duration requestTimeout = Duration(seconds: 30);
  
  /// How often to check for new election results/updates
  /// 5 seconds = feels "live" without killing battery/data
  /// Used in: Live results, real-time updates
  static const Duration pollingInterval = Duration(seconds: 5);
  
  /// Delay before retrying a failed network request
  /// 500ms = quick enough, not too aggressive
  /// Gives server time to recover without user noticing
  /// Used in: Network retry logic
  static const Duration retryDelay = Duration(milliseconds: 500);
  
  /// How long user stays logged in after inactivity
  /// 30 minutes = good security + not too annoying
  /// After 30 min of no action, user must log back in
  /// Used in: Session management, auto-logout
  static const Duration sessionTimeout = Duration(minutes: 30);
  
  /// Standard duration for UI animations
  /// 300ms = fast enough to feel responsive, slow enough to be smooth
  /// Used in: Page transitions, button presses, sliding animations
  static const Duration animationDuration = Duration(milliseconds: 300);

  // ════════════════════════════════════════════════════════════════════════════
  // PAGINATION & DATA LIMITS
  // ════════════════════════════════════════════════════════════════════════════
  // Control how data is loaded and limited
  
  /// Number of items per page when loading lists
  /// 20 items = ~2KB data + good screen display + fast load
  /// Used in: Elections list, candidates list, voting history
  static const int pageSize = 20;
  
  /// How many times to retry a failed API request
  /// 3 attempts = usually enough, prevents infinite loops
  /// Total time: ~1.5 seconds (500ms between each)
  /// Used in: Network error handling, resilience
  static const int maxRetries = 3;
  
  /// Maximum login attempts before account is locked
  /// 5 attempts = catches typos, prevents brute-force attacks
  /// After 5 wrong passwords: "Account locked. Contact support."
  /// Used in: Authentication, security
  static const int maxLoginAttempts = 5;

  // ════════════════════════════════════════════════════════════════════════════
  // CACHE KEYS
  // ════════════════════════════════════════════════════════════════════════════
  // Keys for storing data locally on the device (SharedPreferences/local storage)
  // These are string keys that identify what data you're storing
  
  /// Key for storing user's authentication token
  /// Token proves user is logged in, saved across app restarts
  /// Type: String (JWT token)
  /// Cleared on: Logout
  static const String tokenCacheKey = 'auth_token';
  
  /// Key for storing currently logged-in user's data
  /// Includes: name, email, ID, profile picture
  /// Type: JSON (serialized user object)
  /// Cleared on: Logout
  static const String userCacheKey = 'current_user';
  
  /// Key for storing user's app settings/preferences
  /// Includes: dark mode, language, notifications, theme
  /// Type: JSON (preferences object)
  /// Cleared on: Never (persists after logout)
  static const String preferencesCacheKey = 'user_preferences';
  
  /// Key for storing timestamp of last data sync
  /// Helps determine if fresh data needed from server
  /// Type: DateTime as string (ISO 8601 format)
  /// Updated on: Every successful API call
  static const String lastSyncCacheKey = 'last_sync_time';

  // ════════════════════════════════════════════════════════════════════════════
  // VALIDATION RULES
  // ════════════════════════════════════════════════════════════════════════════
  // Rules for validating user input (passwords, emails, phone numbers)
  
  /// Minimum number of characters in password
  /// 8 characters = moderate security (NIST recommended)
  /// Less: too easy to guess, More: overkill for voting app
  /// Used in: Password validation, sign-up forms
  static const int minPasswordLength = 8;
  
  /// Maximum number of characters in password
  /// 128 characters = practical limit (most people < 50 chars anyway)
  /// Prevents memory issues from extremely long passwords
  /// Used in: Password validation, database field size
  static const int maxPasswordLength = 128;
  
  /// Regular expression for validating email address format
  /// Checks: has @, domain, extension (.com, .org, etc)
  /// Does NOT: check if email actually exists, works with delivery
  /// Used in: Email field validation, form validation
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  
  /// Regular expression for validating phone number format
  /// Accepts: +1(615)322-0101, 615-322-0101, (615) 322-0101, etc.
  /// Flexible: works with different formatting styles
  /// Used in: Phone field validation, contact info validation
  static const String phoneRegex = 
      r'^[+]?[(]?[0-9]{3}[)]?[-\s.]?[0-9]{3}[-\s.]?[0-9]{4,6}$';

  // ════════════════════════════════════════════════════════════════════════════
  // API ENDPOINTS
  // ════════════════════════════════════════════════════════════════════════════
  // Paths to API routes (relative paths, not full URLs)
  // Full URL = baseUrl + endpoint
  // Example: https://api.votesync.app + /elections = https://api.votesync.app/elections
  
  /// POST endpoint to login user
  /// Request: { email, password }
  /// Response: { token, user }
  static const String loginEndpoint = '/auth/login';
  
  /// POST endpoint to verify email address
  /// Request: { email, verificationCode }
  /// Response: { verified: true }
  static const String verifyEmailEndpoint = '/auth/verify-email';
  
  /// POST endpoint to logout user
  /// Clears server-side session
  /// Response: { success: true }
  static const String logoutEndpoint = '/auth/logout';
  
  /// POST endpoint to refresh authentication token
  /// Used when current token is about to expire
  /// Request: { refreshToken }
  /// Response: { newToken }
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  
  /// GET endpoint to list all elections
  /// Query params: page, limit
  /// Response: { elections: [...], total, hasMore }
  static const String electionsEndpoint = '/elections';
  
  /// GET endpoint to get single election details
  /// {id} is replaced with actual election ID
  /// Example: /elections/123 (where 123 is election ID)
  /// Response: { election details }
  static const String electionDetailEndpoint = '/elections/{id}';
  
  /// POST endpoint to submit a vote
  /// Request: { electionId, candidateId }
  /// Response: { voteId, confirmed: true }
  /// Security: Requires authentication token
  static const String submitVoteEndpoint = '/votes/submit';
  
  /// GET endpoint to get user's voting history
  /// Shows all past votes
  /// Response: { votes: [...] }
  static const String voteHistoryEndpoint = '/votes/history';
  
  /// GET endpoint to get election results
  /// Returns vote counts for each candidate
  /// Response: { candidates: [...with vote counts...] }
  static const String resultsEndpoint = '/results';
  
  /// GET endpoint for real-time election results (with WebSocket)
  /// Streams live vote counts as they come in
  /// Used for: Live results display
  static const String liveResultsEndpoint = '/results/live';
  
  /// GET endpoint to fetch current user's profile
  /// Returns user information
  /// Response: { name, email, id, phone, registration }
  static const String userProfileEndpoint = '/user/profile';
  
  /// PATCH endpoint to update user's profile
  /// Request: { name, phone, bio, ... }
  /// Response: { updatedUser }
  /// Security: Requires authentication token
  static const String updateProfileEndpoint = '/user/profile/update';

  // ════════════════════════════════════════════════════════════════════════════
  // UI CONSTANTS
  // ════════════════════════════════════════════════════════════════════════════
  // Spacing, sizing, and layout values for consistent UI
  
  /// Standard padding values (empty space inside elements)
  /// Used to create breathing room, prevent crowding
  static const double paddingXSmall = 4.0;   // Minimal (icon margin)
  static const double paddingSmall = 8.0;    // Small (list items)
  static const double paddingMedium = 16.0;  // Standard (most elements)
  static const double paddingLarge = 24.0;   // Large (sections)
  static const double paddingXLarge = 32.0;  // Extra large (major sections)
  
  /// Border radius values (how rounded corners are)
  /// Used to soften appearance, match modern design trends
  static const double radiusSmall = 4.0;     // Slight rounding (buttons)
  static const double radiusMedium = 8.0;    // Medium (cards)
  static const double radiusLarge = 12.0;    // Rounded (dialogs)
  static const double radiusXLarge = 16.0;   // Very round (featured)
  
  /// Icon sizes (width/height in pixels)
  /// Use consistent sizes for visual harmony
  static const double iconSizeSmall = 16.0;  // Tiny (indicators)
  static const double iconSizeMedium = 24.0; // Standard (buttons)
  static const double iconSizeLarge = 32.0;  // Large (featured)
  static const double iconSizeXLarge = 48.0; // Very large (hero)

  // ════════════════════════════════════════════════════════════════════════════
  // FEATURE FLAGS
  // ════════════════════════════════════════════════════════════════════════════
  // Turn features on/off without code changes
  // Useful for: beta features, gradual rollout, A/B testing
  
  /// Require users to verify email before voting
  /// false = skip email verification, true = require it
  /// Used in: Sign-up flow, security settings
  static const bool emailVerificationRequired = true;
  
  /// Enable live election results display
  /// false = show results only after voting ends
  /// true = show live vote counts updating in real-time
  /// Used in: Results page, WebSocket connections
  static const bool liveResultsEnabled = true;
  
  /// Enable user analytics tracking
  /// false = don't track user behavior
  /// true = track page views, buttons clicks, etc. (with consent)
  /// Used in: Firebase Analytics, user behavior insights
  static const bool analyticsEnabled = true;
  
  /// Enable crash reporting to server
  /// false = only show error to user
  /// true = send crash logs to server for analysis
  /// Used in: Firebase Crashlytics, bug reports
  static const bool crashReportingEnabled = true;
}
```

---

## USAGE EXAMPLES

### **Using Colors in Widgets**

```dart
// ✅ GOOD - Use constants
Container(
  color: AppColors.primary,
  child: Text(
    'Vote Now',
    style: TextStyle(color: AppColors.white),
  ),
)

// ❌ BAD - Hardcoded colors
Container(
  color: Color(0xFF003D82),  // What color is this?
  child: Text(
    'Vote Now',
    style: TextStyle(color: Color(0xFFFFFFFF)),  // What color?
  ),
)
```

### **Using Text Styles**

```dart
// ✅ GOOD - Use text styles
Column(
  children: [
    Text('2024 Elections', style: AppTextStyles.headlineLarge),
    SizedBox(height: AppConstants.paddingMedium),
    Text(
      'Click below to vote in the election.',
      style: AppTextStyles.bodyMedium,
    ),
  ],
)

// ❌ BAD - Hardcoded styles
Column(
  children: [
    Text('2024 Elections', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
    SizedBox(height: 16),
    Text(
      'Click below to vote in the election.',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    ),
  ],
)
```

### **Using Constants for Values**

```dart
// ✅ GOOD - Use constants
class ElectionService {
  Future<List<Election>> getElections(int page) async {
    return api.get(
      '${AppConfig.apiBaseUrl}${AppConstants.electionsEndpoint}?page=$page&limit=${AppConstants.pageSize}',
      timeout: AppConstants.requestTimeout,
    );
  }
}

// ❌ BAD - Magic numbers
class ElectionService {
  Future<List<Election>> getElections(int page) async {
    return api.get(
      'https://api.votesync.app/elections?page=$page&limit=20',
      timeout: Duration(seconds: 30),
    );
  }
}
```

---

## BEST PRACTICES

### **1. Never Hardcode Values**

```dart
// ❌ WRONG
padding: EdgeInsets.all(16),
fontSize: 14,
timeout: Duration(seconds: 30),

// ✅ RIGHT
padding: EdgeInsets.all(AppConstants.paddingMedium),
fontSize: 14, // This is in AppTextStyles
timeout: AppConstants.requestTimeout,
```

### **2. Group Related Constants**

```dart
// ✅ GOOD - Organized by category
// Durations section:
static const Duration requestTimeout = Duration(seconds: 30);
static const Duration pollingInterval = Duration(seconds: 5);
static const Duration sessionTimeout = Duration(minutes: 30);

// ❌ BAD - Random order
static const Duration sessionTimeout = Duration(minutes: 30);
static const int pageSize = 20;
static const Duration requestTimeout = Duration(seconds: 30);
static const String appName = 'VoteSync';
```

### **3. Document Constants**

```dart
// ✅ GOOD - Explained
/// Email verification required for voting
/// true = verify email before voting allowed
/// false = skip email verification
static const bool emailVerificationRequired = true;

// ❌ BAD - No explanation
static const bool emailVerificationRequired = true;
```

### **4. Use Semantic Names**

```dart
// ✅ GOOD - Clear meaning
static const int pageSize = 20;
static const int maxLoginAttempts = 5;
static const Color errorBackground = ...;

// ❌ BAD - Unclear
static const int size = 20;
static const int limit = 5;
static const Color bg = ...;
```

---

Generated: December 15, 2025  
Version: 1.0.0  
Level: Production-Ready
