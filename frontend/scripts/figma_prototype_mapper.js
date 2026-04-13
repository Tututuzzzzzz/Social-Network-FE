const fs = require('fs');
const path = require('path');

const FIGMA_FILE_KEY = 'vvS5OPF4v6aT1SMrFH6f4k';
const TARGET_PAGE = 'Prototype';

function readToken() {
  if (process.env.FIGMA_API_KEY) return process.env.FIGMA_API_KEY;
  if (process.env.FIGMA_TOKEN) return process.env.FIGMA_TOKEN;

  const envPath = path.resolve('.env');
  if (!fs.existsSync(envPath)) return null;

  const txt = fs.readFileSync(envPath, 'utf8');
  const direct = txt.match(/^\s*(FIGMA_API_KEY|FIGMA_TOKEN)\s*=\s*(.+)\s*$/m);
  if (direct && direct[2]) {
    return direct[2].trim().replace(/^"|"$/g, '').replace(/^'|'$/g, '');
  }

  const legacy = txt.match(/figd_[A-Za-z0-9_-]+/);
  return legacy ? legacy[0] : null;
}

function normalizeText(input) {
  return (input || '')
    .replace(/đ/g, 'd')
    .replace(/Đ/g, 'D')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase();
}

function kebabCase(input) {
  const normalized = normalizeText(input);
  const slug = normalized
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .replace(/-{2,}/g, '-');
  return slug || 'screen';
}

function snakeCase(input) {
  return kebabCase(input).replace(/-/g, '_');
}

function pascalCase(input) {
  return kebabCase(input)
    .split('-')
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join('');
}

function classifyModule(screenName, screenPath = '') {
  const n = normalizeText(`${screenName} ${screenPath}`);

  const authKeys = ['authorization', 'login', 'register', 'welcome', 'otp', 'verify', 'xac-thuc', 'dang-nhap', 'dang-ky'];
  const reelsKeys = ['reels', 'story', 'picture shot', 'quay', 'camera'];
  const chatKeys = [
    'direct messages',
    'chat',
    'nhom',
    'nickname',
    'mickname',
    'nick name',
    'ten nhom',
    'chon anh nhom',
    'tao nhom',
    'inbox',
    'message',
  ];
  const profileKeys = [
    'profile',
    'cover',
    'dai dien',
    'anh dai dien',
    'rieng tu',
    'cong khai',
    'han che',
    'chan',
    'bo chan',
    'trang da han che',
    'trang da chan',
  ];

  if (authKeys.some((k) => n.includes(k))) return 'auth';
  if (reelsKeys.some((k) => n.includes(k))) return 'reels';
  if (chatKeys.some((k) => n.includes(k))) return 'chat';
  if (profileKeys.some((k) => n.includes(k))) return 'profile';
  return 'home';
}

function buildRouteInfo(frame) {
  const moduleName = classifyModule(frame.name, frame.path || '');
  const idPart = frame.id.replace(/[^0-9]+/g, '-').replace(/^-+|-+$/g, '');
  const baseSlug = kebabCase(frame.name);
  const baseSnake = snakeCase(frame.name);
  const routePath = `/${moduleName}/${baseSlug}-${idPart}`;
  const routeName = `${moduleName}_${baseSnake}_${idPart.replace(/-/g, '_')}`;
  const pageClass = `${pascalCase(frame.name)}Page`;
  const pageFile = `lib/src/features/${moduleName}/presentation/pages/${baseSnake}_page.dart`;

  return {
    module: moduleName,
    routePath,
    routeName,
    pageClass,
    pageFile,
  };
}

function shouldKeepAsRealScreen(frame) {
  if (!frame.absoluteBoundingBox) return false;

  const w = frame.absoluteBoundingBox.width;
  const h = frame.absoluteBoundingBox.height;
  if (!(w >= 320 && w <= 430 && h >= 640 && h <= 940)) return false;

  const nameNorm = normalizeText(frame.name);
  const genericNamePattern = /^(frame(\s+\d+)?|bottom|top|add|logotext|time style)$/i;
  if (genericNamePattern.test(nameNorm)) return false;

  const pathNorm = normalizeText(frame.path);
  const ignoredPathHints = [
    'bars / status bar',
    'bars / home indicator',
    'profile image',
    'post / top',
    'post / bottom',
    'thanh bar',
  ];
  if (ignoredPathHints.some((k) => pathNorm.includes(k))) return false;

  return true;
}

function walkFrames(node, currentPath, out) {
  const nextPath = [...currentPath, node.name || node.type || 'Unnamed'];

  if (node.type === 'FRAME') {
    out.push({
      id: node.id,
      name: node.name,
      type: node.type,
      path: nextPath.join(' / '),
      depth: nextPath.length,
      absoluteBoundingBox: node.absoluteBoundingBox || null,
    });
  }

  if (Array.isArray(node.children)) {
    for (const child of node.children) {
      walkFrames(child, nextPath, out);
    }
  }
}

function parseTopLevelScreensFile(filePath) {
  const txt = fs.readFileSync(filePath, 'utf8');
  return txt
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const match = line.match(/^\d+\.\s+\[([^\]]+)\]\s+(.+)$/);
      if (!match) return null;
      return { id: match[1], name: match[2] };
    })
    .filter(Boolean);
}

function writeText(filePath, lines) {
  fs.writeFileSync(filePath, lines.join('\n'), 'utf8');
}

function buildMarkdownReport(data) {
  const {
    fileName,
    pageName,
    topLevelMappings,
    deepCandidates,
    moduleCounts,
  } = data;

  const lines = [];
  lines.push('# Figma Prototype -> Flutter Mapping');
  lines.push('');
  lines.push(`- Figma file: ${fileName}`);
  lines.push(`- Page: ${pageName}`);
  lines.push(`- Top-level screens mapped: ${topLevelMappings.length}`);
  lines.push(`- Deep real-screen candidates (from recursive frames): ${deepCandidates.length}`);
  lines.push('');
  lines.push('## Proposed Flutter Modules');
  lines.push('');
  lines.push('- auth: login/register/onboarding/authorization flows');
  lines.push('- home: feed/search/notifications/post settings/general app surfaces');
  lines.push('- reels: reels/story/camera flows');
  lines.push('- chat: direct messages/group/chat profile/chat settings');
  lines.push('- profile: profile/edit/avatar/privacy/block/restriction flows');
  lines.push('');
  lines.push('## Module Distribution (Top-level 91)');
  lines.push('');
  lines.push('| Module | Count |');
  lines.push('|---|---:|');
  for (const moduleName of ['auth', 'home', 'reels', 'chat', 'profile']) {
    lines.push(`| ${moduleName} | ${moduleCounts[moduleName] || 0} |`);
  }
  lines.push('');
  lines.push('## Full Top-level Screen Mapping');
  lines.push('');
  lines.push('| # | Figma ID | Figma Name | Module | Route Path | Page Class | Page File |');
  lines.push('|---:|---|---|---|---|---|---|');

  topLevelMappings.forEach((item, idx) => {
    lines.push(
      `| ${idx + 1} | ${item.id} | ${item.name.replace(/\|/g, '\\|')} | ${item.module} | ${item.routePath} | ${item.pageClass} | ${item.pageFile} |`
    );
  });

  lines.push('');
  lines.push('## Suggested Route Files (Next Coding Step)');
  lines.push('');
  lines.push('- lib/src/routes/app_route_path.dart: keep global route enum names and paths.');
  lines.push('- lib/src/routes/app_route_conf.dart: register module route trees via GoRouter.');
  lines.push('- lib/src/features/auth/presentation/pages/*.dart');
  lines.push('- lib/src/features/home/presentation/pages/*.dart');
  lines.push('- lib/src/features/reels/presentation/pages/*.dart');
  lines.push('- lib/src/features/chat/presentation/pages/*.dart');
  lines.push('- lib/src/features/profile/presentation/pages/*.dart');

  return lines.join('\n');
}

async function main() {
  const offlineRequested = process.env.FIGMA_OFFLINE === '1';
  let figmaFileName = 'Unknown Figma File';
  let deepUnique = [];

  if (!offlineRequested) {
    const token = readToken();
    if (!token) {
      console.error('Missing FIGMA_API_KEY/FIGMA_TOKEN in environment or .env');
      process.exit(2);
    }

    const response = await fetch(`https://api.figma.com/v1/files/${FIGMA_FILE_KEY}`, {
      headers: {
        'X-Figma-Token': token,
      },
    });

    if (response.ok) {
      const figmaFile = await response.json();
      figmaFileName = figmaFile.name;
      const page = (figmaFile.document?.children || []).find((p) => p.name === TARGET_PAGE);
      if (!page) {
        console.error(`Page not found: ${TARGET_PAGE}`);
        process.exit(4);
      }

      const allFrames = [];
      for (const child of page.children || []) {
        walkFrames(child, [TARGET_PAGE], allFrames);
      }

      const deepCandidates = allFrames
        .filter(shouldKeepAsRealScreen)
        .map((frame) => ({
          id: frame.id,
          name: frame.name,
          path: frame.path,
          depth: frame.depth,
          width: Math.round(frame.absoluteBoundingBox.width),
          height: Math.round(frame.absoluteBoundingBox.height),
          ...buildRouteInfo(frame),
        }));

      const seen = new Set();
      for (const item of deepCandidates) {
        if (seen.has(item.id)) continue;
        seen.add(item.id);
        deepUnique.push(item);
      }
    } else {
      const body = await response.text();
      if (response.status !== 429) {
        console.error(`Figma API error ${response.status}: ${body.slice(0, 600)}`);
        process.exit(3);
      }
      console.log('Figma API rate limited (429). Falling back to offline mode using existing extracted files.');
    }
  }

  const topLevelFile = path.resolve('prototype-top-level-screens.txt');
  if (!fs.existsSync(topLevelFile)) {
    console.error('Missing prototype-top-level-screens.txt. Run the extractor first.');
    process.exit(5);
  }

  if (deepUnique.length === 0) {
    const deepFile = path.resolve('prototype-real-screen-candidates.json');
    if (!fs.existsSync(deepFile)) {
      console.error('Missing prototype-real-screen-candidates.json for offline fallback.');
      process.exit(6);
    }
    const existing = JSON.parse(fs.readFileSync(deepFile, 'utf8'));
    figmaFileName = existing.file || figmaFileName;
    deepUnique = (existing.candidates || []).map((item) => ({
      id: item.id,
      name: item.name,
      path: item.path,
      depth: item.depth,
      width: item.width,
      height: item.height,
      ...buildRouteInfo(item),
    }));
  }

  const topLevelScreens = parseTopLevelScreensFile(topLevelFile);
  const topLevelMappings = topLevelScreens.map((screen) => ({
    ...screen,
    ...buildRouteInfo(screen),
  }));

  const moduleCounts = topLevelMappings.reduce((acc, item) => {
    acc[item.module] = (acc[item.module] || 0) + 1;
    return acc;
  }, {});

  fs.writeFileSync(
    path.resolve('prototype-module-route-map.json'),
    JSON.stringify(
      {
        file: figmaFileName,
        page: TARGET_PAGE,
        totalTopLevelScreens: topLevelMappings.length,
        moduleCounts,
        mappings: topLevelMappings,
      },
      null,
      2
    ),
    'utf8'
  );

  writeText(
    path.resolve('prototype-module-route-map.txt'),
    topLevelMappings.map(
      (item, idx) =>
        `${String(idx + 1).padStart(3, '0')}. [${item.id}] ${item.name} => module=${item.module}; route=${item.routePath}; class=${item.pageClass}; file=${item.pageFile}`
    )
  );

  fs.writeFileSync(
    path.resolve('prototype-real-screen-candidates.json'),
    JSON.stringify(
      {
        file: figmaFileName,
        page: TARGET_PAGE,
        filter: 'mobile-sized frame, excludes generic component/frame names and status/nav bars',
        totalCandidates: deepUnique.length,
        candidates: deepUnique,
      },
      null,
      2
    ),
    'utf8'
  );

  writeText(
    path.resolve('prototype-real-screen-candidates.txt'),
    deepUnique.map(
      (item, idx) =>
        `${String(idx + 1).padStart(4, '0')}. [${item.id}] ${item.name} (${item.width}x${item.height}, depth=${item.depth}) | module=${item.module} | route=${item.routePath} | ${item.path}`
    )
  );

  const docsDir = path.resolve('docs', 'figma');
  fs.mkdirSync(docsDir, { recursive: true });
  fs.writeFileSync(
    path.join(docsDir, 'prototype_flutter_mapping.md'),
    buildMarkdownReport({
      fileName: figmaFileName,
      pageName: TARGET_PAGE,
      topLevelMappings,
      deepCandidates: deepUnique,
      moduleCounts,
    }),
    'utf8'
  );

  console.log('Generated:');
  console.log('- prototype-module-route-map.json');
  console.log('- prototype-module-route-map.txt');
  console.log('- prototype-real-screen-candidates.json');
  console.log('- prototype-real-screen-candidates.txt');
  console.log('- docs/figma/prototype_flutter_mapping.md');
  console.log(`Top-level mapped: ${topLevelMappings.length}`);
  console.log(`Deep candidates: ${deepUnique.length}`);
  console.log(`Module counts: ${JSON.stringify(moduleCounts)}`);
}

main().catch((error) => {
  console.error(error && error.stack ? error.stack : String(error));
  process.exit(1);
});
