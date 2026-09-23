/// Inline stroke icons (24x24 view box) used by the web test menu.
library;

import 'package:web/web.dart';

const _svgNs = 'http://www.w3.org/2000/svg';

/// Trash can.
const iconTrash = 'M3 6h18M8 6V4h8v2M6 6l1 14h10l1-14M10 11v5M14 11v5';

/// Sun (switch to light).
const iconSun =
    'M12 8a4 4 0 1 0 0 8a4 4 0 1 0 0-8M12 2v2M12 20v2M4.9 4.9l1.4 1.4'
    'M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4';

/// Moon (switch to dark).
const iconMoon = 'M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z';

/// Arrow right (send).
const iconSend = 'M5 12h14M13 6l6 6-6 6';

/// Chevron up (previous command).
const iconUp = 'M6 15l6-6 6 6';

/// Chevron down (next command).
const iconDown = 'M6 9l6 6 6-6';

/// Build an svg icon element from a path.
Element svgIcon(String path) {
  final svg = document.createElementNS(_svgNs, 'svg')
    ..setAttribute('viewBox', '0 0 24 24')
    ..setAttribute('aria-hidden', 'true');
  final pathElement = document.createElementNS(_svgNs, 'path')
    ..setAttribute('d', path);
  svg.appendChild(pathElement);
  return svg;
}
