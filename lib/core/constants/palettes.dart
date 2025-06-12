import 'package:flutter/material.dart';

final palettes = [
  {
    'name': 'Surprise Me',
    'colors': [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
    ],
  },
  {
    'name': 'Millennial Gray',
    'colors': [
      Colors.grey[50]!,
      Colors.grey[200]!,
      Colors.grey[400]!,
      Colors.grey[600]!,
      Colors.grey[800]!,
    ],
  },
  {
    'name': 'Terracotta Mirage',
    'colors': [
      Color(0xFFFFF3EC),
      Color(0xFFFFE5D9),
      Color(0xFFFEB89F),
      Color(0xFFFF8552),
      Color(0xFFD94F2A),
    ],
  },
  {
    'name': 'Neon Sunset',
    'colors': [
      Color(0xFFFF5E78),
      Color(0xFFFF914D),
      Color(0xFFFFC700),
      Color(0xFFB857FF),
      Color(0xFF5C00FF),
    ],
  },
  {
    'name': 'Forest Hues',
    'colors': [
      Color(0xFF002B1F), // Deep Forest Green
      Color(0xFF014D40), // Dark Emerald
      Color(0xFF02735E), // Rich Teal Green
      Color(0xFF03A678), // Lush Leaf Green
      Color(0xFF8AE3B2), // Mint Green
    ],
  },

  {
    'name': 'Peach Orchard',
    'colors': [
      Color(0xFFFFF3EC),
      Color(0xFFFFDFD3),
      Color(0xFFFFC4B2),
      Color(0xFFFFA78C),
      Color(0xFFFF8A65),
    ],
  },
  {
    'name': 'Fuschia Blossom',
    'colors': [
      Colors.pink[50]!,
      Colors.pink[200]!,
      Colors.pink[400]!,
      Colors.pink[600]!,
      Colors.pink[800]!,
    ],
  },
  {
    'name': 'Emerald Gem',
    'colors': [
      Color(0xFF014D40), // Deep Emerald
      Color(0xFF02675E), // Classic Emerald
      Color(0xFF04A777), // Bright Jade
      Color(0xFF06D6A0), // Mint Emerald
      Color(0xFFB2F7EF), // Soft Mint Glow
    ],
  },

  {
    'name': 'Pastel Breeze',
    'colors': [
      Colors.teal[50]!,
      Colors.purple[50]!,
      Colors.yellow[50]!,
      Colors.blue[50]!,
      Colors.green[50]!,
    ],
  },
  {
    'name': 'Desert Sand',
    'colors': [
      Color(0xFFFFEFD5),
      Color(0xFFFFE4C4),
      Color(0xFFF5DEB3),
      Color(0xFFD2B48C),
      Color(0xFFC19A6B),
    ],
  },
  {
    'name': 'Royal Navy',
    'colors': [
      Color(0xFF001F3F),
      Color(0xFF003366),
      Color(0xFF004080),
      Color(0xFF336699),
      Color(0xFF6699CC),
    ],
  },
  {
    'name': 'Luxury Gold',
    'colors': [
      Color(0xFFFFF8DC),
      Color(0xFFFFE699),
      Color(0xFFFFD700),
      Color(0xFFFFC300),
      Color(0xFFFFA500),
    ],
  },
  {
    'name': 'Scandinavian',
    'colors': [
      Color(0xFFF7F7F7),
      Color(0xFFECECEC),
      Color(0xFFB0BEC5),
      Color(0xFF90A4AE),
      Color(0xFF607D8B),
    ],
  },
  {
    'name': 'Ocean Breeze',
    'colors': [
      Color(0xFFE0F7FA),
      Color(0xFFB2EBF2),
      Color(0xFF4DD0E1),
      Color(0xFF00BCD4),
      Color(0xFF0097A7),
    ],
  },
  {
    'name': 'Minimal Beige',
    'colors': [
      Color(0xFFFDF6EC),
      Color(0xFFF5F5DC),
      Color(0xFFECE5C7),
      Color(0xFFD5C4A1),
      Color(0xFFBDA27F),
    ],
  },
  {
    'name': 'Japanese Zen',
    'colors': [
      Color(0xFFFAF9F7),
      Color(0xFFF4F1EE),
      Color(0xFFDBD3C9),
      Color(0xFFB7AFA3),
      Color(0xFF8C837A),
    ],
  },
  {
    'name': 'Cotton Candy',
    'colors': [
      Color(0xFFFFE6EC),
      Color(0xFFFFD1DC),
      Color(0xFFFFB3BA),
      Color(0xFFFF9AA2),
      Color(0xFFFEC8D8),
    ],
  },
  {
    'name': 'Winter Frost',
    'colors': [
      Color(0xFFE0F7FA),
      Color(0xFFB2EBF2),
      Color(0xFF80DEEA),
      Color(0xFF4DD0E1),
      Color(0xFF26C6DA),
    ],
  },
  {
    'name': 'Rosewood',
    'colors': [
      Color(0xFF3E1F0E),
      Color(0xFF7B3F00),
      Color(0xFF8B4513),
      Color(0xFFA0522D),
      Color(0xFFCD853F),
    ],
  },
  {
    'name': 'Elegant Black',
    'colors': [
      Colors.black,
      Colors.black87,
      Colors.black54,
      Colors.black38,
      Colors.black26,
    ],
  },
  {
    'name': 'Olive Grove',
    'colors': [
      Color(0xFF3D5229),
      Color(0xFF556B2F),
      Color(0xFF6B8E23),
      Color(0xFF8FBC8F),
      Color(0xFFBDB76B),
    ],
  },
  {
    'name': 'Vintage Blue',
    'colors': [
      Color(0xFF0D1B2A),
      Color(0xFF1B263B),
      Color(0xFF32465A),
      Color(0xFF415A77),
      Color(0xFF778DA9),
    ],
  },
  {
    'name': 'French Lavender',
    'colors': [
      Color(0xFFF8F0FA),
      Color(0xFFE6E6FA),
      Color(0xFFD8BFD8),
      Color(0xFFDDA0DD),
      Color(0xFFBA55D3),
    ],
  },
  {
    'name': 'Coral Reef',
    'colors': [
      Color(0xFFFFA07A),
      Color(0xFFFF7F50),
      Color(0xFFFF6347),
      Color(0xFFFF4500),
      Color(0xFFCD5C5C),
    ],
  },
];
