/// Kigen — the colour system.
///
/// Three layers, each answering a different question:
///
/// ```
///   KigenPrimitives   "what colours exist"          66 fields   primary500 = #5465FF
///        │
///   KigenSemanticColors  "what is this colour for"  60 roles    textPrimary
///        │                                                      ↑ light/dark lives HERE
///   KigenComponentColors "what does this control use" 184 tokens buttonPrimaryBg
/// ```
///
/// Screen code names a role and lets the system pick the colour:
/// `context.colors.textPrimary`. It never learns whether that is black or
/// white, or what the brand colour is — so both can change without touching a
/// single widget. Drop to `.component` only when rebuilding a control Figma
/// drew; to `.primitives` only when no role fits, which should feel wrong.
///
/// The three token layers are generated — run `python3 tool/gen_kigen.py` after
/// a Figma re-export rather than editing them.
///
/// This folder imports nothing but `package:flutter/material.dart` and its own
/// siblings, by rule. That is what lets it be copied into another app whole.
library;

export 'kigen_colors.dart';
export 'kigen_component.dart';
export 'kigen_primitives.dart';
export 'kigen_semantic.dart';
export 'kigen_theme.dart';
