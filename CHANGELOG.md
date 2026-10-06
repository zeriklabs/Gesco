# Changelog - GESCO v0.0.2 Alpha

All notable changes to the GESCO (Sistema Integral de Gestión Escolar del IPN) Flutter application are documented in this file.

## [0.0.2 Alpha] - 2025-02-23

### Added
- **Student Photo Upload Step (`PasoFoto`):** Integrated a dedicated photo capture/upload step in the registration wizard featuring an avatar preview, simulated file picker / camera options, and official IPN credential photo requirements.
- **Dynamic Birthplace Municipality Fallback:** Enhanced `PasoPersonales` to automatically display the official Zacatecas municipality dropdown when Zacatecas is derived from the CURP, or seamlessly switch to a free-text input field for any other Mexican state.
- **Editable CURP-derived RFC:** Made the RFC field in personal data prefill automatically from the entered CURP while remaining fully editable by the user.
- **Academic Period & Semester Calculation Banner:** Added academic period indicators (`2025-2`) and automated next semester calculation in the reinscription summary and wizard.

### Enhanced & Redesigned
- **Streamlined 3-Step Reinscription Wizard:** Rebuilt the reinscription flow into a clean 3-step process (Step 1: Student Data & Address, Step 2: Tutor Data & Address, Step 3: Verification, Avatar, PDF download, and completion).
- **Floating Card Panels & M3 Design:** Modernized authentication, dashboard, and wizard screens with frosted glassmorphism, responsive card layouts, and the official IPN Guinda (`#731C24`) and Dorado (`#D49A2A`) palette.
- **Codebase Architecture:** Harmonized local UI enhancements with the modular `lib/features/` architecture and robust widget testing suite.

### Verified
- **Automated Testing:** All 34 unit and widget tests executed and passed successfully (`All tests passed!`).
