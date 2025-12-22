# 🎨 Wanderlust UI - Design & Component Guide

## Component Library

### 1. TripCard
**Location**: `lib/widgets/trip_card.dart`

**Features**:
- Destination name with ellipsis overflow
- Date range display
- Status badge (UPCOMING/DRAFT/COMPLETED)
- Favorite toggle button
- Quick action icons for budget/calendar/itinerary
- Gradient backgrounds for upcoming trips
- Smooth tap animations

**Usage**:
```dart
TripCard(
  trip: Trip(...),
  onTap: () => Navigator.push(...),
  onFavoriteTap: (isFavorite) => updateFavorite(),
)
```

**Styling**:
- Background: Card color with optional gradient
- Border: 1px blue (0.1 alpha) for subtle outline
- Padding: 16px all sides
- Border Radius: 20px
- Shadow: 10px blur, 2px offset, 0.1 black opacity

---

### 2. ActivityCard
**Location**: `lib/widgets/activity_card.dart`

**Features**:
- Left colored border (4px) indicating period
- Activity title with truncation
- Location display with icon
- Time display with formatted time
- Period badge with color coding
- Edit/Delete menu
- Color coding:
  - Morning: Orange 🌅
  - Afternoon: Amber ☀️
  - Evening: Purple 🌆
  - Night: Indigo 🌙

**Usage**:
```dart
ActivityCard(
  activity: Activity(...),
  onTap: () => showDetails(),
  onEdit: () => editActivity(),
  onDelete: () => deleteActivity(),
)
```

**Styling**:
- Border Left: 4px colored bar
- Background: Card color
- Padding: 16px
- Border Radius: 16px
- Icon size: 50x50px container

---

### 3. ExpenseCard
**Location**: `lib/widgets/expense_card.dart`

**Features**:
- Category icon in colored container (50x50px)
- Expense title and category badge
- Date display
- Amount in blue, formatted currency
- Category-based colors:
  - Transport: Blue 🚗
  - Accommodation: Green 🏨
  - Food: Orange 🍽️
  - Activities: Purple 🎉
  - Shopping: Pink 🛍️
  - Other: Gray 📦
- Edit/Delete menu

**Usage**:
```dart
ExpenseCard(
  expense: Expense(...),
  onTap: () => viewDetails(),
  onEdit: () => editExpense(),
  onDelete: () => deleteExpense(),
)
```

**Styling**:
- Icon container: 50x50px with 12px border radius
- Amount text: Bold, 16px, primary blue
- Badge: 8px horizontal, 4px vertical padding
- Border Radius: 16px
- Icon colors: Match category

---

## Layout Patterns

### 1. List with Cards
```
┌─────────────────────────────┐
│  Section Header             │
├─────────────────────────────┤
│ ┌───────────────────────────┐│
│ │ Trip Card 1              ││
│ └───────────────────────────┘│
│ ┌───────────────────────────┐│
│ │ Trip Card 2              ││
│ └───────────────────────────┘│
└─────────────────────────────┘
```

### 2. Form Screen
```
┌─────────────────────────────┐
│  AppBar (Close button)      │
├─────────────────────────────┤
│ ┌───────────────────────────┐│
│ │ Header Card with Gradient ││
│ │ Title & Subtitle          ││
│ └───────────────────────────┘│
│                             │
│ Form Fields:                │
│ ├─ Text Input              │
│ ├─ Date Picker             │
│ ├─ Dropdown               │
│ └─ Submit Button           │
└─────────────────────────────┘
```

### 3. Tab Navigation
```
┌─────────────────────────────┐
│  My Trips   Favorites  Past │
├─────────────────────────────┤
│                             │
│  [Tab Content Here]         │
│                             │
└─────────────────────────────┘
```

---

## Color Applications

### Trip Status Colors
- **UPCOMING**: Blue gradient background
- **DRAFT**: Plain background, muted badge
- **COMPLETED**: Gray badge, no gradient

### Period Colors (Activities)
- **Morning**: Orange (#FF9800)
- **Afternoon**: Amber (#FFC107)
- **Evening**: Purple (#9C27B0)
- **Night**: Indigo (#3F51B5)

### Category Colors (Expenses)
- **Transport**: Blue (#2196F3)
- **Accommodation**: Green (#4CAF50)
- **Food**: Orange (#FF9800)
- **Activities**: Purple (#9C27B0)
- **Shopping**: Pink (#E91E63)
- **Other**: Gray (#757575)

---

## Typography Hierarchy

```
DISPLAY (36px Bold)
Page titles, splash screen

HEADER (24px Bold)
Form headers, section titles

TITLE (18px Bold)
Card titles, trip destination

SUBTITLE (16px Semi-bold)
Secondary information

BODY (14px Regular)
Main content, descriptions

CAPTION (12px Regular)
Labels, dates, hints, badges

OVERLINE (11px Bold)
Status badges, category labels
```

---

## Spacing Guide

```
4px   - Minimal gaps between elements
8px   - Small padding, icon spacing
12px  - Medium spacing
16px  - Standard card padding, gaps
20px  - Screen horizontal padding
24px  - Header card padding
32px  - Section separator spacing
```

### Card Spacing Example
```
┌────────────────────────────────┐
│  [16px padding all sides]      │
│                                │
│  Title              [Icon 22px]│
│  [8px gap]                     │
│  Subtitle                      │
│  [12px gap]                    │
│  [Badge]  [Spacer]  [Icons]    │
│                                │
└────────────────────────────────┘
```

---

## Animation Guidelines

### Recommended Animations
1. **Card Tap**: 200ms scale fade
2. **Favorite Toggle**: 300ms icon color change
3. **Tab Switch**: 200ms fade
4. **Modal Open**: 300ms slide up
5. **Loading**: Continuous spinner

### Avoid
- Over-complicated animations
- Animations > 500ms
- Jank/frame drops
- Parallax effects (unless necessary)

---

## Accessibility

### Colors
- Text contrast: Minimum WCAG AA (4.5:1 for normal text)
- Don't rely on color alone (use icons + text)
- Colorblind-friendly palette

### Touch Targets
- Minimum 48x48 dp for interactive elements
- Cards: Minimum 56px height
- Icons: Minimum 24x24 dp

### Text
- Maximum line length: 65-80 characters
- Minimum font size: 12px
- Proper heading hierarchy

---

## Component Variants

### TripCard States
```
[Normal] → [Hovered] → [Pressed]
  |          |          |
Gray       Brighten   Darken
border     shadows    highlight
```

### Favorite Button
```
☆ (Unfavorite)  →  ♥ (Favorite)
Gray color          Red color
```

### Status Badges
```
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ UPCOMING     │  │ DRAFT        │  │ COMPLETED    │
│ Blue bg      │  │ Gray bg      │  │ Gray bg      │
│ Blue text    │  │ Gray text    │  │ Gray text    │
└──────────────┘  └──────────────┘  └──────────────┘
```

---

## Error & Empty States

### Empty Trip List
```
   ✈️
No trips yet
Create your first trip to get started
```

### No Activities
```
    📝
No activities for this day
Use the form above to add one
```

### Error Loading Data
```
⚠️
Error loading trips
[Specific error message...]
```

---

## Performance Tips

1. **Use const constructors** where possible
2. **ListView** for scrollable lists
3. **StreamBuilder** for real-time data
4. **SingleChildScrollView** for limited content
5. **Avoid nested Columns/Rows**
6. **Use Expanded wisely**

---

## Testing Your UI

### Visual Checks
- [ ] All text is readable
- [ ] Colors are consistent
- [ ] Spacing is uniform
- [ ] Icons are properly aligned
- [ ] No text overflow
- [ ] Shadows look natural

### Responsive Checks
- [ ] Works on 320px screens
- [ ] Works on 600px tablets
- [ ] Works on landscape mode
- [ ] Buttons are tappable
- [ ] Text is readable at all sizes

### Interaction Checks
- [ ] Buttons respond to taps
- [ ] Cards navigate correctly
- [ ] Forms validate inputs
- [ ] Errors display properly
- [ ] Loading states appear
- [ ] Animations are smooth

---

## Future Enhancement Ideas

1. **Dark/Light Mode**: Toggle theme
2. **Custom Themes**: User-selectable color schemes
3. **Animations**: Staggered list animations
4. **Gestures**: Swipe to delete, drag to reorder
5. **Widgets**: Custom date picker, budget gauge
6. **Effects**: Parallax scrolling, hero animations

---

**Your UI is now beautifully crafted and following Material Design principles!** 🎨✨
