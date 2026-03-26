---
name: rails-lighthouse
description: Analyze and optimize a URL to achieve 100% Lighthouse score using Chrome DevTools. Use this skill when the user wants to improve Core Web Vitals, fix performance issues, or achieve perfect Lighthouse scores across Performance, Accessibility, Best Practices, and SEO.
---

This skill systematically analyzes and optimizes a web page to achieve **100% on all four Lighthouse categories**: Performance, Accessibility, Best Practices, and SEO. It uses Chrome DevTools MCP integration to run traces, analyze the page, identify issues, make code fixes, and iterate until all scores reach 100%.

The user provides a URL to optimize. The skill will analyze it across all Lighthouse categories, fix issues in the codebase, rebuild as needed, and re-test until perfect scores are achieved.

## Lighthouse Categories

To achieve 100% overall, all four categories must score 100%:

| Category | What it measures |
|----------|------------------|
| **Performance** | Core Web Vitals (LCP, CLS, INP), loading speed, interactivity |
| **Accessibility** | Screen reader support, keyboard navigation, color contrast, ARIA |
| **Best Practices** | Security, modern APIs, console errors, image aspects |
| **SEO** | Meta tags, crawlability, mobile-friendliness, structured data |

## Workflow Overview

1. **Navigate & Baseline**: Open the URL and run initial audits
2. **Configure Device**: Set up mobile viewport first (Lighthouse default), then desktop
3. **Audit All Categories**: Performance trace + SEO/A11y/BP checks via DOM inspection
4. **Fix Issues**: Make targeted code changes for each category
5. **Rebuild**: Rebuild the production container if code was changed
6. **Verify**: Re-run all audits on BOTH mobile and desktop to confirm improvements
7. **Iterate**: Repeat steps 2-6 until all categories reach 100% on both viewports

## Phase 1: Initial Analysis

### Navigate to the Target URL

Use the chrome-devtools MCP to navigate to the provided URL:

```
mcp__chrome-devtools__navigate_page with url: <target-url>
```

### Configure Device Viewport

**Important**: Run audits on BOTH mobile and desktop viewports. Mobile testing should be done first as it's Lighthouse's default and typically has more issues.

#### Mobile Configuration (Test First)

Set mobile viewport dimensions (matches Lighthouse mobile defaults):

```
mcp__chrome-devtools__resize_page with:
  - width: 412
  - height: 823
```

Enable mobile throttling to simulate real-world conditions:

```
mcp__chrome-devtools__emulate with:
  - cpuThrottlingRate: 4
  - networkConditions: "Fast 4G"
```

#### Desktop Configuration (Test Second)

Set desktop viewport dimensions:

```
mcp__chrome-devtools__resize_page with:
  - width: 1350
  - height: 940
```

Disable throttling for desktop testing:

```
mcp__chrome-devtools__emulate with:
  - cpuThrottlingRate: 1
  - networkConditions: "No emulation"
```

#### Device-Specific Considerations

| Aspect | Mobile | Desktop |
|--------|--------|---------|
| **Viewport** | 412x823 | 1350x940 |
| **CPU Throttling** | 4x slowdown | No throttling |
| **Network** | Fast 4G | No throttling |
| **Touch targets** | Min 48x48px required | Less strict |
| **Font size** | Min 16px for readability | More flexible |
| **Tap delay** | Avoid 300ms delay | N/A |

### Run Performance Trace

Start a performance trace with reload to capture the full page load:

```
mcp__chrome-devtools__performance_start_trace with:
  - reload: true
  - autoStop: true
```

This will:
- Reload the page while recording
- Capture Core Web Vitals (LCP, CLS, INP)
- Identify performance insights
- Auto-stop when page load completes

### Review Insights

The trace results will include:
- **Core Web Vitals scores**: LCP, CLS, INP ratings
- **Available insight sets**: Each insight set corresponds to a navigation or interaction
- **Performance issues**: Highlighted problems with severity

For each insight set, analyze specific insights using:

```
mcp__chrome-devtools__performance_analyze_insight with:
  - insightSetId: <id from trace results>
  - insightName: <insight name like "LCPBreakdown", "DocumentLatency", "RenderBlocking">
```

## Phase 2: Common Performance Issues & Fixes

### Render-Blocking Resources

**Symptoms**: High "Render blocking requests" insight, slow FCP/LCP
**Fixes**:
- Add `async` or `defer` to non-critical scripts
- Inline critical CSS or use `<link rel="preload">`
- Move non-critical CSS to end of body or load async

### Large Contentful Paint (LCP) Issues

**Symptoms**: LCP > 2.5s, LCPBreakdown insight shows delays
**Fixes**:
- Preload LCP image: `<link rel="preload" as="image" href="...">`
- Optimize image size and format (WebP, AVIF)
- Remove lazy loading from above-the-fold images
- Reduce server response time (TTFB)
- Eliminate render-blocking resources before LCP element

### Cumulative Layout Shift (CLS) Issues

**Symptoms**: CLS > 0.1, layout shift clusters identified
**Fixes**:
- Add explicit `width` and `height` to images/videos
- Reserve space for dynamic content with CSS `aspect-ratio`
- Avoid inserting content above existing content
- Use CSS `contain` for components that resize

### Document Latency Issues

**Symptoms**: High TTFB, slow document fetch
**Fixes**:
- Enable compression (gzip/brotli)
- Add caching headers
- Optimize database queries
- Use CDN for static assets

### JavaScript Execution Issues

**Symptoms**: Long tasks, high scripting time
**Fixes**:
- Code split and lazy load non-critical JS
- Debounce/throttle event handlers
- Use Web Workers for heavy computation
- Remove unused JavaScript

### Image Optimization

**Symptoms**: Slow image loading, large transfer sizes
**Fixes**:
- Use modern formats (WebP, AVIF)
- Implement responsive images with `srcset`
- Lazy load below-the-fold images
- Compress images appropriately

## Phase 3: SEO Audit & Fixes

### Running SEO Checks

Use `evaluate_script` to extract and validate SEO elements:

```javascript
// Extract SEO data
mcp__chrome-devtools__evaluate_script with function:
() => {
  const getAttr = (sel, attr) => document.querySelector(sel)?.[attr] || document.querySelector(sel)?.getAttribute(attr);
  const getMeta = (name) => document.querySelector(`meta[name="${name}"]`)?.content || document.querySelector(`meta[property="${name}"]`)?.content;

  return {
    title: document.title,
    titleLength: document.title?.length,
    metaDescription: getMeta('description'),
    metaDescriptionLength: getMeta('description')?.length,
    canonical: getAttr('link[rel="canonical"]', 'href'),
    robots: getMeta('robots'),
    viewport: getMeta('viewport'),
    charset: document.characterSet,
    lang: document.documentElement.lang,
    h1Count: document.querySelectorAll('h1').length,
    h1Text: document.querySelector('h1')?.textContent?.trim(),
    headings: {
      h1: document.querySelectorAll('h1').length,
      h2: document.querySelectorAll('h2').length,
      h3: document.querySelectorAll('h3').length,
    },
    imagesWithoutAlt: [...document.querySelectorAll('img:not([alt])')].map(i => i.src),
    linksWithoutText: [...document.querySelectorAll('a:not([aria-label])')].filter(a => !a.textContent?.trim()).length,
    ogTitle: getMeta('og:title'),
    ogDescription: getMeta('og:description'),
    ogImage: getMeta('og:image'),
    twitterCard: getMeta('twitter:card'),
    structuredData: [...document.querySelectorAll('script[type="application/ld+json"]')].map(s => s.textContent),
    hreflang: [...document.querySelectorAll('link[hreflang]')].map(l => ({ lang: l.hreflang, href: l.href })),
  };
}
```

### SEO Checklist & Fixes

| Check | Requirement | Fix |
|-------|-------------|-----|
| **Title** | Present, 30-60 chars | Add `<title>` in `<head>`, keep concise |
| **Meta Description** | Present, 120-160 chars | Add `<meta name="description" content="...">` |
| **Canonical URL** | Present, absolute URL | Add `<link rel="canonical" href="...">` |
| **Viewport** | `width=device-width, initial-scale=1` | Add viewport meta tag |
| **Lang attribute** | Present on `<html>` | Add `<html lang="en">` or appropriate locale |
| **Single H1** | Exactly one H1 per page | Ensure only one `<h1>`, use `<h2>` for others |
| **Heading hierarchy** | Logical order (h1 > h2 > h3) | Don't skip heading levels |
| **Image alt text** | All images have `alt` | Add descriptive `alt` attributes |
| **Link text** | Descriptive, not "click here" | Use meaningful anchor text |
| **robots.txt** | Accessible, not blocking content | Check `/robots.txt` allows crawling |
| **Structured Data** | Valid JSON-LD | Add schema.org markup for content type |

### Open Graph & Social

```html
<!-- Minimum OG tags for 100% SEO -->
<meta property="og:title" content="Page Title">
<meta property="og:description" content="Page description">
<meta property="og:image" content="https://example.com/image.jpg">
<meta property="og:url" content="https://example.com/page">
<meta property="og:type" content="website">

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
```

### Structured Data (JSON-LD)

Add appropriate schema.org markup:

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebPage",
  "name": "Page Title",
  "description": "Page description"
}
</script>
```

## Phase 4: Accessibility Audit & Fixes

### Running Accessibility Checks

Use `evaluate_script` to audit accessibility:

```javascript
mcp__chrome-devtools__evaluate_script with function:
() => {
  const issues = [];

  // Images without alt
  document.querySelectorAll('img:not([alt])').forEach(img => {
    issues.push({ type: 'missing-alt', element: img.outerHTML.slice(0, 100) });
  });

  // Form inputs without labels
  document.querySelectorAll('input:not([type="hidden"]):not([type="submit"]):not([type="button"])').forEach(input => {
    const id = input.id;
    const hasLabel = id && document.querySelector(`label[for="${id}"]`);
    const hasAriaLabel = input.getAttribute('aria-label') || input.getAttribute('aria-labelledby');
    if (!hasLabel && !hasAriaLabel) {
      issues.push({ type: 'missing-label', element: input.outerHTML.slice(0, 100) });
    }
  });

  // Buttons without accessible names
  document.querySelectorAll('button').forEach(btn => {
    if (!btn.textContent?.trim() && !btn.getAttribute('aria-label')) {
      issues.push({ type: 'button-no-name', element: btn.outerHTML.slice(0, 100) });
    }
  });

  // Links without href or with empty href
  document.querySelectorAll('a:not([href]), a[href=""], a[href="#"]').forEach(a => {
    if (!a.getAttribute('role') === 'button') {
      issues.push({ type: 'invalid-link', element: a.outerHTML.slice(0, 100) });
    }
  });

  // Check for skip link
  const hasSkipLink = !!document.querySelector('a[href="#main"], a[href="#content"], .skip-link');

  // Check color contrast (basic - look for very light text)
  const lowContrastElements = [];

  // Check focus indicators
  const focusableElements = document.querySelectorAll('a, button, input, select, textarea, [tabindex]');

  return {
    issues,
    hasSkipLink,
    focusableCount: focusableElements.length,
    htmlLang: document.documentElement.lang,
    hasMainLandmark: !!document.querySelector('main, [role="main"]'),
    hasNavLandmark: !!document.querySelector('nav, [role="navigation"]'),
    tabindex: [...document.querySelectorAll('[tabindex]')].map(el => ({
      tabindex: el.tabIndex,
      element: el.tagName
    })),
  };
}
```

### Accessibility Checklist & Fixes

| Check | Requirement | Fix |
|-------|-------------|-----|
| **Alt text** | All images have descriptive alt | Add `alt="description"` to all `<img>` |
| **Form labels** | All inputs have associated labels | Use `<label for="id">` or `aria-label` |
| **Button names** | All buttons have accessible names | Add text content or `aria-label` |
| **Language** | `<html lang="...">` set | Add language attribute |
| **Landmarks** | Use semantic HTML | Use `<main>`, `<nav>`, `<header>`, `<footer>` |
| **Heading order** | No skipped levels | Go h1 > h2 > h3 sequentially |
| **Focus visible** | Focus indicator visible | Ensure `:focus` styles are visible |
| **Skip link** | Skip to main content link | Add skip link as first focusable element |
| **Color contrast** | 4.5:1 for text, 3:1 for large text | Adjust colors to meet WCAG AA |
| **Touch targets** | Min 44x44px on mobile | Increase button/link padding |
| **ARIA** | Valid ARIA usage | Use correct roles, states, properties |

### Common Accessibility Fixes

```html
<!-- Skip link (first in body) -->
<a href="#main" class="skip-link">Skip to main content</a>

<!-- Proper form labeling -->
<label for="email">Email address</label>
<input type="email" id="email" name="email">

<!-- Or with aria-label -->
<input type="search" aria-label="Search the site">

<!-- Icon button with accessible name -->
<button aria-label="Close menu">
  <svg>...</svg>
</button>

<!-- Image with alt -->
<img src="photo.jpg" alt="A red bicycle parked against a brick wall">

<!-- Decorative image -->
<img src="decoration.svg" alt="" role="presentation">
```

### Focus Styles

Ensure visible focus indicators:

```css
/* Never do this without replacement */
/* :focus { outline: none; } */

/* Good focus styles */
:focus-visible {
  outline: 2px solid var(--focus-color);
  outline-offset: 2px;
}
```

## Phase 5: Best Practices Audit & Fixes

### Running Best Practices Checks

Use `evaluate_script` and `list_console_messages` to check best practices:

```javascript
mcp__chrome-devtools__evaluate_script with function:
() => {
  return {
    // HTTPS
    isHttps: location.protocol === 'https:',

    // Doctype
    hasDoctype: document.doctype !== null,
    doctypeHtml5: document.doctype?.name === 'html',

    // Charset
    charset: document.characterSet,
    hasCharsetMeta: !!document.querySelector('meta[charset]'),

    // Images
    imagesWithIncorrectAspect: [...document.querySelectorAll('img')].filter(img => {
      if (!img.naturalWidth || !img.width) return false;
      const displayAspect = img.width / img.height;
      const naturalAspect = img.naturalWidth / img.naturalHeight;
      return Math.abs(displayAspect - naturalAspect) > 0.05;
    }).map(img => img.src),

    // Deprecated APIs
    usesDocumentWrite: document.body.innerHTML.includes('document.write'),

    // Mixed content
    httpResources: [...document.querySelectorAll('[src^="http:"], [href^="http:"]')].map(el => el.src || el.href),

    // Vulnerable libraries (basic check)
    jqueryVersion: window.jQuery?.fn?.jquery,

    // Permissions policy / feature policy
    hasPermissionsPolicy: !!document.querySelector('meta[http-equiv="Permissions-Policy"]'),

    // CSP
    hasCSP: !!document.querySelector('meta[http-equiv="Content-Security-Policy"]'),
  };
}
```

Also check console for errors:

```
mcp__chrome-devtools__list_console_messages with types: ["error", "warn"]
```

### Best Practices Checklist & Fixes

| Check | Requirement | Fix |
|-------|-------------|-----|
| **HTTPS** | Site served over HTTPS | Configure SSL/TLS |
| **No console errors** | No JS errors in console | Fix all JavaScript errors |
| **Doctype** | HTML5 doctype | `<!DOCTYPE html>` at start |
| **Charset** | UTF-8, declared early | `<meta charset="utf-8">` in `<head>` |
| **No mixed content** | No HTTP resources on HTTPS | Update all URLs to HTTPS |
| **Image aspect ratio** | Display matches natural | Set correct width/height or use CSS |
| **No vulnerable libraries** | Up-to-date dependencies | Update outdated packages |
| **No deprecated APIs** | Avoid document.write, etc. | Use modern alternatives |
| **No browser errors** | No 404s, no failed requests | Fix broken links/resources |
| **Geolocation on user gesture** | Request only after interaction | Move permission requests to click handlers |
| **Notification on user gesture** | Request only after interaction | Move permission requests to click handlers |

### Security Headers (Server-Side)

For Rails, add to `config/application.rb` or controller:

```ruby
# Content Security Policy
config.content_security_policy do |policy|
  policy.default_src :self
  policy.script_src :self
  policy.style_src :self, :unsafe_inline
  policy.img_src :self, :data
end

# Other security headers (via middleware or web server)
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY
# Referrer-Policy: strict-origin-when-cross-origin
```

## Phase 6: Making Code Changes

When making fixes, use Serena MCP tools for semantic code navigation and precise editing:

### File & Symbol Discovery

- `find_file` - Locate files by name pattern
- `list_dir` - Browse directory contents
- `search_for_pattern` - Regex-based search across the codebase
- `get_symbols_overview` - Quick overview of symbols in a file
- `find_symbol` - Locate specific classes, methods, or functions

### Reading Code

- `find_symbol` with `include_body=True` - Get the implementation of a specific symbol
- `find_symbol` with `include_info=True` - Get docstrings and signatures

### Editing Code

- `replace_symbol_body` - Replace entire method/class/function implementations
- `replace_content` with `mode="regex"` - Targeted changes using pattern matching
- `insert_after_symbol` / `insert_before_symbol` - Add code relative to existing symbols

### Workflow

1. **Locate the code**: Use `find_file` and `find_symbol` to find relevant files and symbols
2. **Read before editing**: Use `find_symbol` with `include_body=True` to understand current implementation
3. **Make precise edits**: Use `replace_symbol_body` for whole-symbol changes or `replace_content` for partial changes
4. **Verify impact**: Use `find_referencing_symbols` to check for side effects
5. **Track changes**: Use TodoWrite to track each fix

### Rails-Specific Locations

Common files to edit:
- Layout/head: `app/views/layouts/application.html.erb`
- Asset optimization: `config/environments/production.rb`
- View optimizations: `app/views/`
- CSS optimizations: `app/assets/stylesheets/`
- JavaScript: `app/javascript/`
- Image handling: `app/assets/images/`

## Phase 7: Rebuild & Re-test

After making code changes, rebuild the production container:

```bash
docker compose -f docker-compose.local.yml build && docker compose -f docker-compose.local.yml up -d
```

**Important**: Do NOT use `--no-cache` - Docker will detect file changes and rebuild appropriately.

Wait for the container to be ready, then re-run all audits:

1. Navigate to the URL again (may need to wait for server startup)
2. Run performance trace
3. Run SEO, Accessibility, and Best Practices checks
4. Compare all scores to baseline
5. If any category is not 100%, analyze remaining issues and repeat

## Phase 8: Iteration Strategy

Track progress using TodoWrite:

```
[ ] Determine if page is public or private (affects SEO requirements)
[ ] Configure mobile viewport (412x823) with throttling
[ ] Run initial mobile audits (all 4 categories)
[ ] Configure desktop viewport (1350x940) without throttling
[ ] Run initial desktop audits (all 4 categories)
[ ] Fix Performance issues (addressing both viewports)
[ ] Fix SEO issues (skip for private pages - just verify noindex meta tag)
[ ] Fix Accessibility issues (especially touch targets for mobile)
[ ] Fix Best Practices issues
[ ] Rebuild container
[ ] Re-test mobile viewport - verify all scores improved
[ ] Re-test desktop viewport - verify all scores improved
[ ] Iterate until all categories reach 100% on BOTH viewports (SEO optional for private pages)
```

### When to Stop

Continue iterating until ALL four Lighthouse categories reach 100% on **BOTH mobile and desktop**.

**Exception for Private Pages**: SEO does not need to reach 100% for authenticated/private pages (e.g., dashboards, settings, admin panels). These pages should not be indexed by search engines. For private pages, ensure:
- `<meta name="robots" content="noindex, nofollow">` is present
- Focus on Performance, Accessibility, and Best Practices reaching 100%

**Mobile viewport (412x823 with throttling):**
- **Performance**: 100 (LCP < 2.5s, CLS < 0.1, INP < 200ms under throttled conditions)
- **Accessibility**: 100 (WCAG AA, touch targets ≥48x48px, readable fonts ≥16px)
- **Best Practices**: 100 (No console errors, HTTPS, correct doctype)
- **SEO**: 100 for public pages (Meta tags, viewport, mobile-friendly layout, structured data) | N/A for private pages

**Desktop viewport (1350x940 without throttling):**
- **Performance**: 100 (LCP < 2.5s, CLS < 0.1, INP < 200ms)
- **Accessibility**: 100 (WCAG AA, focus visible, keyboard navigable)
- **Best Practices**: 100 (No console errors, HTTPS, correct doctype)
- **SEO**: 100 for public pages (Meta tags, headings, canonical URLs, structured data) | N/A for private pages

### Debugging Tips

If scores aren't improving:
- Check that rebuild completed successfully
- Clear browser cache or use incognito
- Verify the container is running the latest code
- Check for server-side issues: `docker compose -f docker-compose.local.yml logs web`
- Check network requests for 404s or failed resources

## Key Chrome DevTools MCP Tools

| Tool | Purpose |
|------|---------|
| `navigate_page` | Go to URL |
| `resize_page` | Set viewport dimensions (mobile: 412x823, desktop: 1350x940) |
| `emulate` | Configure CPU/network throttling for device simulation |
| `performance_start_trace` | Start performance recording |
| `performance_stop_trace` | Stop recording (if not autoStop) |
| `performance_analyze_insight` | Deep dive on specific insight |
| `evaluate_script` | Run JS to audit SEO/A11y/BP |
| `take_snapshot` | Get page structure (a11y tree) |
| `take_screenshot` | Visual verification |
| `list_network_requests` | Check resource loading |
| `list_console_messages` | Check for JS errors |

## Success Criteria

The optimization is complete when ALL Lighthouse scores reach **100% on BOTH mobile and desktop viewports**:

### Mobile (412x823, 4x CPU throttle, Fast 4G)

| Category | Score | Key Metrics |
|----------|-------|-------------|
| **Performance** | 100 | LCP < 2.5s, CLS < 0.1, INP < 200ms |
| **Accessibility** | 100 | WCAG AA compliant, touch targets ≥48x48px, proper ARIA |
| **Best Practices** | 100 | No errors, HTTPS, modern APIs only |
| **SEO** | 100 | Meta tags, viewport configured, mobile-friendly, structured data |

### Desktop (1350x940, no throttling)

| Category | Score | Key Metrics |
|----------|-------|-------------|
| **Performance** | 100 | LCP < 2.5s, CLS < 0.1, INP < 200ms |
| **Accessibility** | 100 | WCAG AA compliant, proper ARIA, focus visible |
| **Best Practices** | 100 | No errors, HTTPS, modern APIs only |
| **SEO** | 100 | Meta tags, headings, alt text, canonical URLs, structured data |

### Final Checklist

**For public pages:**
- [ ] Mobile Performance: 100
- [ ] Mobile Accessibility: 100
- [ ] Mobile Best Practices: 100
- [ ] Mobile SEO: 100
- [ ] Desktop Performance: 100
- [ ] Desktop Accessibility: 100
- [ ] Desktop Best Practices: 100
- [ ] Desktop SEO: 100

**For private/authenticated pages** (dashboards, settings, admin):
- [ ] Mobile Performance: 100
- [ ] Mobile Accessibility: 100
- [ ] Mobile Best Practices: 100
- [ ] Mobile SEO: N/A (ensure `noindex, nofollow` meta tag is present)
- [ ] Desktop Performance: 100
- [ ] Desktop Accessibility: 100
- [ ] Desktop Best Practices: 100
- [ ] Desktop SEO: N/A (ensure `noindex, nofollow` meta tag is present)

Document all changes made and their impact on each category's score for both viewports.

